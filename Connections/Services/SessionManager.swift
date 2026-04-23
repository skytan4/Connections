//
//  SessionManager.swift
//  Connections
//

import Foundation
import SwiftUI

// MARK: - Prompt Interaction Tracking

struct PromptInteraction {
    let promptID: UUID
    let promptText: String
    let topic: Topic
    var totalTimeSpent: TimeInterval = 0
    var goDeeperCount: Int = 0
    var wasFavorited: Bool = false
    var revisitCount: Int = 0
    var visitCount: Int = 1
}

struct StandoutMoment {
    let promptText: String
    let reason: String?
}

@Observable
final class SessionManager {

    // MARK: - Session Configuration

    var selectedMode: Mode?
    var selectedIntensity: Intensity?
    var selectedSessionLength: SessionLength?
    var selectedTopic: Topic?

    /// Session-only setting — reset each time a new session starts.
    var followUpsEnabled: Bool = true

    // MARK: - Active Session State

    private(set) var currentPrompt: Prompt?
    private(set) var currentDepth: DepthLevel = .warmUp
    private(set) var maxDepthReached: DepthLevel = .warmUp
    private(set) var promptsShown: Int = 0
    private(set) var responses: [PromptResponse] = []
    private(set) var isSessionActive: Bool = false

    /// Prompt IDs already shown this session, to avoid repeats.
    private var shownPromptIDs: Set<UUID> = []

    /// Stack of previously shown prompts, most recent last. Powers the "Back" button.
    private var promptHistory: [Prompt] = []

    var canGoBack: Bool {
        !promptHistory.isEmpty && !isSessionComplete
    }

    /// Follow-ups revealed so far for the current prompt (progressive reveal).
    private(set) var shownFollowUps: [FollowUp] = []

    /// Styles already used for the current prompt, to prefer variety.
    private var usedFollowUpStyles: Set<FollowUpStyle> = []

    /// Number of prompts the user has *continued* (not skipped) at the current depth.
    private var continuedAtCurrentDepth: Int = 0

    /// Lightweight topic history to reduce clumping and create a smoother session rhythm.
    private var recentTopics: [Topic] = []

    /// Session-wide topic counts so we can gently reward variety over repetition.
    private var shownTopicCounts: [Topic: Int] = [:]

    // MARK: - Interaction Tracking

    /// Per-prompt interaction data for the current session, keyed by prompt ID.
    private(set) var interactions: [UUID: PromptInteraction] = [:]

    /// Timestamp when the current prompt became active (for elapsed time calculation).
    private var promptActiveAt: Date?

    /// Timestamp when the session started (for total duration).
    private var sessionStartedAt: Date?

    /// Snapshotted session duration at completion (avoids clock drift on completion screen).
    private(set) var completedSessionDuration: TimeInterval = 0

    /// Number of times the user tapped "Go deeper" this session.
    private(set) var goDeeperCount: Int = 0

    // MARK: - Favorites (persisted)

    private(set) var favorites: FavoritesStore

    // MARK: - Computed Properties

    var totalPrompts: Int {
        selectedSessionLength?.rawValue ?? 0
    }

    var promptsRemaining: Int {
        max(0, totalPrompts - promptsShown)
    }

    var sessionProgress: Double {
        guard totalPrompts > 0 else { return 0 }
        return Double(promptsShown) / Double(totalPrompts)
    }

    var isSessionComplete: Bool {
        isSessionActive && promptsShown >= totalPrompts
    }

    // MARK: - Init

    init() {
        self.favorites = FavoritesStore.load()
    }

    // MARK: - Session Lifecycle

    func startSession() {
        guard selectedMode != nil,
              selectedIntensity != nil,
              selectedSessionLength != nil else { return }

        currentDepth = .warmUp
        maxDepthReached = .warmUp
        continuedAtCurrentDepth = 0
        promptsShown = 0
        responses = []
        shownPromptIDs = []
        promptHistory = []
        recentTopics = []
        shownTopicCounts = [:]
        goDeeperCount = 0
        interactions = [:]
        promptActiveAt = nil
        sessionStartedAt = Date()
        completedSessionDuration = 0
        resetFollowUpTracking()
        isSessionActive = true

        currentPrompt = nextPrompt()

        // If the prompt bank has no matching prompts at all, end gracefully.
        if currentPrompt == nil {
            isSessionActive = false
        } else if let prompt = currentPrompt {
            beginTrackingPrompt(prompt)
        }
    }

    func continuePrompt(isFavorited: Bool = false) {
        guard let prompt = currentPrompt else { return }
        finalizeCurrentPromptTiming()
        promptHistory.append(prompt)
        resetFollowUpTracking()

        let response = PromptResponse(
            promptID: prompt.id,
            promptText: prompt.text,
            action: .continued,
            isFavorited: isFavorited
        )
        responses.append(response)

        if isFavorited {
            favorites.add(prompt)
        }

        continuedAtCurrentDepth += 1
        checkDepthProgression()

        promptsShown += 1

        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
            else { beginTrackingPrompt(currentPrompt!) }
        } else {
            snapshotSessionDuration()
            currentPrompt = nil
        }
    }

    /// Record a "Go deeper" tap.
    func recordGoDeeper() {
        goDeeperCount += 1
        if let prompt = currentPrompt {
            interactions[prompt.id]?.goDeeperCount += 1
        }
    }

    /// Whether the current prompt has more unrevealed follow-ups.
    var hasMoreFollowUps: Bool {
        guard let prompt = currentPrompt, followUpsEnabled else { return false }
        return prompt.followUps.count > shownFollowUps.count
    }

    /// Reveals the next follow-up for the current prompt, preferring an unused style.
    func revealNextFollowUp() {
        guard let prompt = currentPrompt else { return }
        let shown = Set(shownFollowUps.map(\.id))
        let remaining = prompt.followUps.filter { !shown.contains($0.id) }
        let preferredStyles = preferredFollowUpStyles(for: prompt, revealIndex: shownFollowUps.count)

        let selected = preferredStyles
            .lazy
            .compactMap { style in
                remaining.first { $0.style == style && !self.usedFollowUpStyles.contains($0.style) }
            }
            .first
            ?? remaining.first { !self.usedFollowUpStyles.contains($0.style) }
            ?? remaining.first

        guard let selected else { return }
        usedFollowUpStyles.insert(selected.style)
        shownFollowUps.append(selected)
    }

    func skipPrompt() {
        guard let prompt = currentPrompt else { return }
        finalizeCurrentPromptTiming()
        promptHistory.append(prompt)

        let response = PromptResponse(
            promptID: prompt.id,
            promptText: prompt.text,
            action: .skipped
        )
        responses.append(response)

        promptsShown += 1
        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
            else { beginTrackingPrompt(currentPrompt!) }
        } else {
            currentPrompt = nil
        }
    }

    func goBack() {
        guard let previousPrompt = promptHistory.popLast() else { return }
        finalizeCurrentPromptTiming()
        resetFollowUpTracking()
        currentPrompt = previousPrompt
        beginTrackingPrompt(previousPrompt, isRevisit: true)
        promptsShown = max(0, promptsShown - 1)
        if !responses.isEmpty {
            responses.removeLast()
        }
    }

    func favoriteCurrentPrompt() {
        guard let prompt = currentPrompt else { return }
        favorites.add(prompt)
        interactions[prompt.id]?.wasFavorited = true
    }

    func toggleFavoriteCurrentPrompt() {
        guard let prompt = currentPrompt else { return }
        favorites.toggle(prompt)
        interactions[prompt.id]?.wasFavorited = favorites.isFavorite(prompt)
    }

    func isCurrentPromptFavorited() -> Bool {
        guard let prompt = currentPrompt else { return false }
        return favorites.isFavorite(prompt)
    }

    func removeFavorite(id: UUID) {
        favorites.remove(id: id)
    }

    func toggleExperienceFavorite(_ experience: ShareExperience) {
        favorites.toggleExperience(experience)
    }

    func isExperienceFavorited(_ experience: ShareExperience) -> Bool {
        favorites.containsExperience(id: experience.id)
    }

    func toggleFallInLoveFavorite(_ prompt: FallInLovePrompt) {
        favorites.toggleFallInLovePrompt(prompt, mode: selectedMode ?? .couples)
    }

    func isFallInLoveFavorited(_ prompt: FallInLovePrompt) -> Bool {
        favorites.containsFallInLovePrompt(order: prompt.order)
    }

    func endSession() {
        finalizeCurrentPromptTiming()
        isSessionActive = false
        currentPrompt = nil
        promptsShown = 0
        responses = []
        shownPromptIDs = []
        promptHistory = []
        recentTopics = []
        shownTopicCounts = [:]
        continuedAtCurrentDepth = 0
        goDeeperCount = 0
        interactions = [:]
        promptActiveAt = nil
        currentDepth = .warmUp
        maxDepthReached = .warmUp
        resetFollowUpTracking()
        followUpsEnabled = true
    }

    func resetSelections() {
        selectedMode = nil
        selectedIntensity = nil
        selectedSessionLength = nil
        selectedTopic = nil
    }

    // MARK: - Summary

    func generateSummary() -> SessionSummary? {
        guard let mode = selectedMode, let intensity = selectedIntensity else { return nil }
        let signals = SessionSummaryEngine.Signals(
            responses: responses,
            maxDepthReached: maxDepthReached,
            goDeeperCount: goDeeperCount,
            mode: mode,
            intensity: intensity
        )
        return SessionSummaryEngine.generate(from: signals)
    }

    // MARK: - Recommendation

    func generateRecommendation() -> SessionRecommendation? {
        guard let mode = selectedMode,
              let intensity = selectedIntensity,
              let length = selectedSessionLength else { return nil }

        let signals = SessionRecommendationEngine.Signals(
            interactions: interactions,
            responses: responses,
            selectedMode: mode,
            selectedIntensity: intensity,
            selectedSessionLength: length,
            selectedTopic: selectedTopic,
            maxDepthReached: maxDepthReached,
            goDeeperCount: goDeeperCount,
            followUpsWereEnabled: followUpsEnabled
        )
        return SessionRecommendationEngine.generate(from: signals)
    }

    // MARK: - Interaction Tracking Helpers

    /// Finalizes elapsed time for the current prompt's interaction.
    private func finalizeCurrentPromptTiming() {
        guard let prompt = currentPrompt, let start = promptActiveAt else { return }
        let elapsed = Date().timeIntervalSince(start)
        interactions[prompt.id]?.totalTimeSpent += elapsed
        promptActiveAt = nil
    }

    /// Starts timing for a prompt and ensures an interaction record exists.
    private func beginTrackingPrompt(_ prompt: Prompt, isRevisit: Bool = false) {
        if var existing = interactions[prompt.id] {
            existing.visitCount += 1
            if isRevisit { existing.revisitCount += 1 }
            interactions[prompt.id] = existing
        } else {
            interactions[prompt.id] = PromptInteraction(
                promptID: prompt.id,
                promptText: prompt.text,
                topic: prompt.topic
            )
        }
        promptActiveAt = Date()
    }

    // MARK: - Interaction Scoring

    /// Returns the top standout prompt interactions for the current session, scored by engagement signals.
    func standoutPromptInteractions(limit: Int = 3) -> [PromptInteraction] {
        let meaningful = interactions.values.filter { isMeaningful($0) }
        let scored = meaningful.map { (interaction: $0, score: score($0)) }
        let sorted = scored.sorted { $0.score > $1.score }
        return sorted.prefix(limit).map { $0.interaction }
    }

    /// Scores a single interaction using normalized, balanced weights.
    /// Time (normalized to ~1 point per 30s, capped at 3) is the strongest signal.
    /// Go Deeper and favorites are strong explicit signals.
    /// Revisits are moderate; raw visit count is weak.
    private func score(_ interaction: PromptInteraction) -> Double {
        let normalizedTime = min(interaction.totalTimeSpent / 30.0, 3.0)
        let goDeeper = Double(interaction.goDeeperCount)
        let revisit = Double(interaction.revisitCount)
        let visits = Double(interaction.visitCount)
        let favoriteBonus = interaction.wasFavorited ? 2.5 : 0.0

        return
            (normalizedTime * 2.0) +
            (goDeeper * 2.5) +
            favoriteBonus +
            (revisit * 1.5) +
            (visits * 0.3)
    }

    /// Filters out interactions with negligible engagement.
    private func isMeaningful(_ interaction: PromptInteraction) -> Bool {
        interaction.totalTimeSpent > 5 ||
        interaction.goDeeperCount > 0 ||
        interaction.wasFavorited ||
        interaction.revisitCount > 0
    }

    /// Returns standout moments with human-readable reasons for display on the completion screen.
    func standoutMoments(limit: Int = 3) -> [StandoutMoment] {
        standoutPromptInteractions(limit: limit).map { interaction in
            StandoutMoment(
                promptText: interaction.promptText,
                reason: reasonForStandout(interaction)
            )
        }
    }

    /// Returns all prompts the user explicitly favorited during this session, ordered by engagement.
    /// Session-scoped: only includes favorites created by heart taps in the active session.
    func sessionFavoriteMoments() -> [StandoutMoment] {
        interactions.values
            .filter { $0.wasFavorited }
            .sorted { score($0) > score($1) }
            .map { StandoutMoment(promptText: $0.promptText, reason: reasonForStandout($0)) }
    }

    private func reasonForStandout(_ interaction: PromptInteraction) -> String? {
        if interaction.wasFavorited { return "You saved this one" }
        if interaction.goDeeperCount > 0 { return "You went deeper here" }
        if interaction.revisitCount > 0 { return "You came back to this one" }
        if interaction.totalTimeSpent > 30 { return "You lingered here" }
        return nil
    }

    /// Session duration formatted for display.
    var formattedSessionDuration: String {
        let minutes = Int(completedSessionDuration / 60)
        if minutes < 1 { return "< 1 min" }
        return "\(minutes) min"
    }

    // MARK: - Internal

    private func resetFollowUpTracking() {
        shownFollowUps = []
        usedFollowUpStyles = []
    }

    /// If prompts are exhausted before the session length is reached, mark the session complete.
    private func forceComplete() {
        finalizeCurrentPromptTiming()
        snapshotSessionDuration()
        promptsShown = totalPrompts
        currentPrompt = nil
    }

    private func snapshotSessionDuration() {
        guard let start = sessionStartedAt, completedSessionDuration == 0 else { return }
        completedSessionDuration = Date().timeIntervalSince(start)
    }

    private func checkDepthProgression() {
        if continuedAtCurrentDepth >= DepthLevel.promptsToUnlockNext,
           let nextDepth = currentDepth.next {
            currentDepth = nextDepth
            continuedAtCurrentDepth = 0
            if currentDepth > maxDepthReached {
                maxDepthReached = currentDepth
            }
        }
    }

    private func nextPrompt() -> Prompt? {
        guard let mode = selectedMode, let intensity = selectedIntensity else { return nil }

        let all = PromptBank.shared
            .prompts(for: mode, intensity: intensity, unlockedThrough: currentDepth)

        // Filter out already-shown prompts when avoid repeats is enabled.
        var available = avoidRepeats ? all.filter { !shownPromptIDs.contains($0.id) } : all

        // If we've exhausted all prompts, reset and try again.
        if available.isEmpty && avoidRepeats {
            shownPromptIDs = []
            available = all
        }

        // Prefer the selected topic, fall back to all topics only as a last resort.
        let candidates: [Prompt]
        if let topic = selectedTopic {
            let topicFiltered = available.filter { $0.topic == topic }
            candidates = topicFiltered.isEmpty ? available : topicFiltered
        } else {
            candidates = available
        }

        guard let chosen = choosePrompt(from: candidates) else { return nil }
        if avoidRepeats { shownPromptIDs.insert(chosen.id) }
        recentTopics.append(chosen.topic)
        if recentTopics.count > 3 {
            recentTopics.removeFirst(recentTopics.count - 3)
        }
        shownTopicCounts[chosen.topic, default: 0] += 1
        return chosen
    }

    /// Chooses a prompt with light pacing rules so sessions feel shaped instead of random.
    private func choosePrompt(from candidates: [Prompt]) -> Prompt? {
        guard !candidates.isEmpty else { return nil }

        let scored = candidates.map { prompt in
            (prompt: prompt, score: promptScore(prompt))
        }

        guard let bestScore = scored.map(\.score).max() else { return nil }

        // Keep a little variety by choosing among the strongest few candidates.
        let topBand = scored
            .filter { $0.score >= bestScore - 1 }
            .map(\.prompt)

        return topBand.randomElement()
    }

    /// Scores a prompt using depth pacing, topic variety, and gentle end-of-session deepening.
    private func promptScore(_ prompt: Prompt) -> Int {
        var score = 0

        // Strongly prefer the currently active depth once it has unlocked.
        if prompt.depthLevel == currentDepth {
            score += 6
        } else if prompt.depthLevel == maxDepthReached {
            score += 4
        } else if prompt.depthLevel < currentDepth {
            score += 1
        }

        // Once we reach the back half of a session, prefer the deeper unlocked layer.
        if totalPrompts > 0, promptsRemaining <= max(2, totalPrompts / 4), prompt.depthLevel == maxDepthReached {
            score += 2
        }

        score += topicAffinityScore(for: prompt)

        // Reduce immediate topic repetition unless the user explicitly selected a topic.
        if selectedTopic == nil {
            if prompt.topic == recentTopics.last {
                score -= 4
            }
            let recentMatches = recentTopics.filter { $0 == prompt.topic }.count
            score -= recentMatches * 2

            let timesShown = shownTopicCounts[prompt.topic, default: 0]
            if timesShown == 0 {
                score += 1
            } else if timesShown >= 2 {
                score -= (timesShown - 1)
            }
        }

        return score
    }

    /// Adds light topic sequencing so tones feel more intentionally shaped.
    private func topicAffinityScore(for prompt: Prompt) -> Int {
        guard let mode = selectedMode, let intensity = selectedIntensity else { return 0 }

        let preferredTopics = preferredTopics(for: mode, intensity: intensity, depth: prompt.depthLevel)
        guard let index = preferredTopics.firstIndex(of: prompt.topic) else { return -2 }

        // Earlier-listed topics are a stronger fit for that mode/intensity/depth slice.
        return max(0, 5 - index)
    }

    /// Follow-up pacing by tone/depth so "Go deeper" feels guided instead of random.
    private func preferredFollowUpStyles(for prompt: Prompt, revealIndex: Int) -> [FollowUpStyle] {
        let stagedOrder: [FollowUpStyle]

        switch (prompt.intensity, prompt.depthLevel, revealIndex) {
        case (.light, .warmUp, _):
            stagedOrder = [.origin, .meaning, .impact, .need, .tension]

        case (.light, .realTalk, 0):
            stagedOrder = [.meaning, .origin, .impact, .need, .tension]
        case (.light, .realTalk, _):
            stagedOrder = [.impact, .meaning, .need, .origin, .tension]

        case (.light, .deepDive, 0):
            stagedOrder = [.meaning, .impact, .origin, .need, .tension]
        case (.light, .deepDive, _):
            stagedOrder = [.need, .impact, .meaning, .origin, .tension]

        case (.honest, .warmUp, 0):
            stagedOrder = [.meaning, .origin, .impact, .need, .tension]
        case (.honest, .warmUp, _):
            stagedOrder = [.need, .impact, .meaning, .origin, .tension]

        case (.honest, .realTalk, 0):
            stagedOrder = [.meaning, .impact, .need, .origin, .tension]
        case (.honest, .realTalk, _):
            stagedOrder = [.need, .impact, .meaning, .tension, .origin]

        case (.honest, .deepDive, 0):
            stagedOrder = [.meaning, .need, .impact, .origin, .tension]
        case (.honest, .deepDive, _):
            stagedOrder = [.need, .tension, .impact, .meaning, .origin]

        case (.unfiltered, .warmUp, 0):
            stagedOrder = [.meaning, .impact, .origin, .need, .tension]
        case (.unfiltered, .warmUp, _):
            stagedOrder = [.need, .impact, .meaning, .tension, .origin]

        case (.unfiltered, .realTalk, 0):
            stagedOrder = [.meaning, .need, .impact, .origin, .tension]
        case (.unfiltered, .realTalk, _):
            stagedOrder = [.need, .tension, .impact, .meaning, .origin]

        case (.unfiltered, .deepDive, 0):
            stagedOrder = [.need, .meaning, .tension, .impact, .origin]
        case (.unfiltered, .deepDive, _):
            stagedOrder = [.tension, .need, .meaning, .impact, .origin]
        }

        return stagedOrder
    }

    /// Topic ordering by mode/intensity/depth. This keeps sessions feeling guided without making them deterministic.
    private func preferredTopics(for mode: Mode, intensity: Intensity, depth: DepthLevel) -> [Topic] {
        switch (mode, intensity, depth) {
        case (.couples, .light, .warmUp):
            return [.appreciation, .dailyLife, .communication, .identity, .parenting, .past, .values]
        case (.couples, .light, .realTalk):
            return [.communication, .emotions, .growth, .parenting, .intimacy, .past, .values]
        case (.couples, .light, .deepDive):
            return [.intimacy, .emotions, .parenting, .past, .growth, .values, .communication]

        case (.couples, .honest, .warmUp):
            return [.communication, .emotions, .parenting, .growth, .appreciation, .values, .past]
        case (.couples, .honest, .realTalk):
            return [.emotions, .parenting, .communication, .conflict, .intimacy, .growth, .past]
        case (.couples, .honest, .deepDive):
            return [.intimacy, .parenting, .conflict, .emotions, .past, .values, .growth]

        case (.couples, .unfiltered, .warmUp):
            return [.identity, .emotions, .conflict, .parenting, .communication, .sex, .past]
        case (.couples, .unfiltered, .realTalk):
            return [.sex, .conflict, .parenting, .intimacy, .emotions, .identity, .communication]
        case (.couples, .unfiltered, .deepDive):
            return [.sex, .intimacy, .parenting, .emotions, .conflict, .past, .identity]

        case (.friends, .light, .warmUp):
            return [.appreciation, .dailyLife, .past, .identity, .growth, .values]
        case (.friends, .light, .realTalk):
            return [.growth, .appreciation, .past, .communication, .identity, .values]
        case (.friends, .light, .deepDive):
            return [.intimacy, .values, .appreciation, .past, .growth, .communication]

        case (.friends, .honest, .warmUp):
            return [.communication, .emotions, .growth, .identity, .conflict, .past]
        case (.friends, .honest, .realTalk):
            return [.identity, .growth, .emotions, .communication, .conflict, .past]
        case (.friends, .honest, .deepDive):
            return [.conflict, .past, .intimacy, .growth, .values, .emotions]

        case (.friends, .unfiltered, .warmUp):
            return [.identity, .emotions, .conflict, .values, .past, .communication]
        case (.friends, .unfiltered, .realTalk):
            return [.conflict, .emotions, .identity, .values, .dailyLife, .past]
        case (.friends, .unfiltered, .deepDive):
            return [.past, .conflict, .identity, .emotions, .values, .dailyLife]

        case (.family, .light, .warmUp):
            return [.past, .appreciation, .dailyLife, .values, .communication, .growth]
        case (.family, .light, .realTalk):
            return [.appreciation, .past, .values, .growth, .communication, .intimacy]
        case (.family, .light, .deepDive):
            return [.values, .intimacy, .appreciation, .past, .growth, .communication]

        case (.family, .honest, .warmUp):
            return [.communication, .emotions, .identity, .growth, .past, .appreciation]
        case (.family, .honest, .realTalk):
            return [.past, .communication, .values, .emotions, .dailyLife, .identity]
        case (.family, .honest, .deepDive):
            return [.past, .intimacy, .growth, .dailyLife, .values, .emotions]

        case (.family, .unfiltered, .warmUp):
            return [.communication, .emotions, .identity, .conflict, .past, .growth]
        case (.family, .unfiltered, .realTalk):
            return [.communication, .dailyLife, .past, .identity, .emotions, .conflict]
        case (.family, .unfiltered, .deepDive):
            return [.past, .emotions, .communication, .identity, .dailyLife, .conflict]

        case (.soloReflection, .light, .warmUp):
            return [.dailyLife, .appreciation, .growth, .emotions, .identity, .past]
        case (.soloReflection, .light, .realTalk):
            return [.values, .growth, .emotions, .past, .identity, .appreciation]
        case (.soloReflection, .light, .deepDive):
            return [.values, .growth, .appreciation, .identity, .past, .emotions]

        case (.soloReflection, .honest, .warmUp):
            return [.emotions, .growth, .identity, .communication, .values, .dailyLife]
        case (.soloReflection, .honest, .realTalk):
            return [.growth, .identity, .emotions, .values, .past, .conflict]
        case (.soloReflection, .honest, .deepDive):
            return [.growth, .past, .values, .identity, .emotions]

        case (.soloReflection, .unfiltered, .warmUp):
            return [.emotions, .identity, .growth, .past, .values, .communication]
        case (.soloReflection, .unfiltered, .realTalk):
            return [.identity, .growth, .emotions, .past, .dailyLife, .conflict]
        case (.soloReflection, .unfiltered, .deepDive):
            return [.identity, .emotions, .past, .values, .conflict, .growth]
        }
    }

    /// Reads the avoid-repeats preference from UserDefaults.
    private var avoidRepeats: Bool {
        guard let data = UserDefaults.standard.data(forKey: "connections_settings"),
              let decoded = try? JSONDecoder().decode(AvoidRepeatsCheck.self, from: data) else {
            return true
        }
        return decoded.avoidRepeats
    }

    private struct AvoidRepeatsCheck: Decodable {
        let avoidRepeats: Bool
    }
}

// MARK: - Favorites Store

struct FavoritesStore: Codable {
    private(set) var entries: [FavoriteEntry] = []

    struct FavoriteEntry: Identifiable, Codable {
        /// Uses the original Prompt ID so duplicates are prevented.
        let id: UUID
        let promptText: String
        let mode: Mode
        let intensity: Intensity
        let depth: DepthLevel
        let followUps: [FollowUp]
        let date: Date
        /// Nil for session prompts; "shareExperience" for Share Experience entries.
        let source: String?
        /// Original ShareExperience.id for lookup. Nil for session prompts.
        let sourceID: String?

        init(promptID: UUID, promptText: String, mode: Mode, intensity: Intensity = .honest, depth: DepthLevel = .warmUp, followUps: [FollowUp] = [], date: Date = .now, source: String? = nil, sourceID: String? = nil) {
            self.id = promptID
            self.promptText = promptText
            self.mode = mode
            self.intensity = intensity
            self.depth = depth
            self.followUps = followUps
            self.date = date
            self.source = source
            self.sourceID = sourceID
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            promptText = try container.decode(String.self, forKey: .promptText)
            mode = try container.decode(Mode.self, forKey: .mode)
            intensity = try container.decodeIfPresent(Intensity.self, forKey: .intensity) ?? .honest
            depth = try container.decodeIfPresent(DepthLevel.self, forKey: .depth) ?? .warmUp
            followUps = try container.decode([FollowUp].self, forKey: .followUps)
            date = try container.decode(Date.self, forKey: .date)
            source = try container.decodeIfPresent(String.self, forKey: .source)
            sourceID = try container.decodeIfPresent(String.self, forKey: .sourceID)
        }
    }

    /// Adds a prompt to favorites if not already present, and saves immediately.
    mutating func add(_ prompt: Prompt) {
        guard !entries.contains(where: { $0.id == prompt.id }) else { return }
        let entry = FavoriteEntry(promptID: prompt.id, promptText: prompt.text, mode: prompt.mode, intensity: prompt.intensity, depth: prompt.depthLevel, followUps: prompt.followUps)
        entries.append(entry)
        save()
    }

    mutating func remove(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func contains(promptID: UUID) -> Bool {
        entries.contains { $0.id == promptID }
    }

    /// Convenience: check if a Prompt is favorited.
    func isFavorite(_ prompt: Prompt) -> Bool {
        contains(promptID: prompt.id)
    }

    /// Toggle a prompt in/out of favorites.
    mutating func toggle(_ prompt: Prompt) {
        if contains(promptID: prompt.id) {
            remove(id: prompt.id)
        } else {
            add(prompt)
        }
    }

    // MARK: - ShareExperience Support

    mutating func addExperience(_ experience: ShareExperience) {
        guard !containsExperience(id: experience.id) else { return }
        let entry = FavoriteEntry(
            promptID: UUID(),
            promptText: experience.text,
            mode: .soloReflection,
            intensity: experience.intensity,
            followUps: [],
            source: "shareExperience",
            sourceID: experience.id
        )
        entries.append(entry)
        save()
    }

    mutating func removeExperience(id: String) {
        entries.removeAll { $0.sourceID == id }
        save()
    }

    func containsExperience(id: String) -> Bool {
        entries.contains { $0.sourceID == id }
    }

    mutating func toggleExperience(_ experience: ShareExperience) {
        if containsExperience(id: experience.id) {
            removeExperience(id: experience.id)
        } else {
            addExperience(experience)
        }
    }

    // MARK: - FallInLove Support

    mutating func addFallInLovePrompt(_ prompt: FallInLovePrompt, mode: Mode) {
        let sourceID = "fil_\(prompt.order)"
        guard !entries.contains(where: { $0.sourceID == sourceID }) else { return }
        let entry = FavoriteEntry(
            promptID: UUID(),
            promptText: prompt.text,
            mode: mode,
            intensity: prompt.intensity,
            depth: prompt.depth,
            followUps: [],
            source: "fallInLove",
            sourceID: sourceID
        )
        entries.append(entry)
        save()
    }

    mutating func removeFallInLovePrompt(order: Int) {
        entries.removeAll { $0.sourceID == "fil_\(order)" }
        save()
    }

    func containsFallInLovePrompt(order: Int) -> Bool {
        entries.contains { $0.sourceID == "fil_\(order)" }
    }

    mutating func toggleFallInLovePrompt(_ prompt: FallInLovePrompt, mode: Mode) {
        if containsFallInLovePrompt(order: prompt.order) {
            removeFallInLovePrompt(order: prompt.order)
        } else {
            addFallInLovePrompt(prompt, mode: mode)
        }
    }

    /// All favorite entries.
    var allFavorites: [FavoriteEntry] { entries }

    // MARK: - Persistence

    private static let storageKey = "layers_favorites"

    static func load() -> FavoritesStore {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(FavoritesStore.self, from: data) else {
            return FavoritesStore()
        }
        return decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
