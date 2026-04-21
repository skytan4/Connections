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
    var totalTimeSpent: TimeInterval = 0
    var goDeeperCount: Int = 0
    var wasFavorited: Bool = false
    var revisitCount: Int = 0
    var visitCount: Int = 1
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

    // MARK: - Interaction Tracking

    /// Per-prompt interaction data for the current session, keyed by prompt ID.
    private(set) var interactions: [UUID: PromptInteraction] = [:]

    /// Timestamp when the current prompt became active (for elapsed time calculation).
    private var promptActiveAt: Date?

    // MARK: - Connection Tracking

    private(set) var connectionTracker = ConnectionTracker()

    /// Number of continued prompts since the last feeling check-in.
    private var continuedSinceLastCheckIn: Int = 0

    /// Whether a feeling check-in should be shown right now.
    private(set) var showFeelingCheckIn: Bool = false

    private static let checkInInterval = 3

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
        continuedSinceLastCheckIn = 0
        promptsShown = 0
        responses = []
        shownPromptIDs = []
        promptHistory = []
        connectionTracker.reset()
        showFeelingCheckIn = false
        goDeeperCount = 0
        interactions = [:]
        promptActiveAt = nil
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
        continuedSinceLastCheckIn += 1
        checkDepthProgression()

        promptsShown += 1

        // Check if we should show a feeling check-in before the next prompt.
        if continuedSinceLastCheckIn >= Self.checkInInterval && !isSessionComplete {
            showFeelingCheckIn = true
            // Timing paused — will resume when check-in resolves and a new prompt loads.
        } else if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
            else { beginTrackingPrompt(currentPrompt!) }
        } else {
            currentPrompt = nil
        }
    }

    func recordFeeling(_ feeling: Feeling) {
        connectionTracker.record(feeling)
        resetFollowUpTracking()
        continuedSinceLastCheckIn = 0
        showFeelingCheckIn = false
        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
            else { beginTrackingPrompt(currentPrompt!) }
        } else {
            currentPrompt = nil
        }
    }

    /// Record a "Go deeper" tap (either showing follow-ups or triggering a check-in).
    func recordGoDeeper() {
        goDeeperCount += 1
        if let prompt = currentPrompt {
            interactions[prompt.id]?.goDeeperCount += 1
        }
    }

    /// Trigger a check-in after a "Go deeper" interaction, if not already pending.
    func triggerCheckInFromGoDeeper() {
        guard !showFeelingCheckIn, !isSessionComplete else { return }
        finalizeCurrentPromptTiming()
        showFeelingCheckIn = true
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
        // Prefer a follow-up whose style hasn't been used yet
        let preferred = remaining.filter { !usedFollowUpStyles.contains($0.style) }
        guard let selected = (preferred.first ?? remaining.first) else { return }
        usedFollowUpStyles.insert(selected.style)
        shownFollowUps.append(selected)
    }

    func dismissCheckIn() {
        resetFollowUpTracking()
        continuedSinceLastCheckIn = 0
        showFeelingCheckIn = false
        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
            else { beginTrackingPrompt(currentPrompt!) }
        } else {
            currentPrompt = nil
        }
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

    func endSession() {
        finalizeCurrentPromptTiming()
        isSessionActive = false
        currentPrompt = nil
        promptsShown = 0
        responses = []
        shownPromptIDs = []
        promptHistory = []
        continuedAtCurrentDepth = 0
        continuedSinceLastCheckIn = 0
        goDeeperCount = 0
        interactions = [:]
        promptActiveAt = nil
        currentDepth = .warmUp
        maxDepthReached = .warmUp
        showFeelingCheckIn = false
        connectionTracker.reset()
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
            feelings: connectionTracker.feelings,
            connectionLevel: connectionTracker.connectionLevel,
            maxDepthReached: maxDepthReached,
            goDeeperCount: goDeeperCount,
            mode: mode,
            intensity: intensity
        )
        return SessionSummaryEngine.generate(from: signals)
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
                promptText: prompt.text
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

    // MARK: - Internal

    private func resetFollowUpTracking() {
        shownFollowUps = []
        usedFollowUpStyles = []
    }

    /// If prompts are exhausted before the session length is reached, mark the session complete.
    private func forceComplete() {
        finalizeCurrentPromptTiming()
        promptsShown = totalPrompts
        currentPrompt = nil
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

        guard let chosen = candidates.randomElement() else { return nil }
        if avoidRepeats { shownPromptIDs.insert(chosen.id) }
        return chosen
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

        init(promptID: UUID, promptText: String, mode: Mode, intensity: Intensity = .honest, depth: DepthLevel = .warmUp, followUps: [FollowUp] = [], date: Date = .now) {
            self.id = promptID
            self.promptText = promptText
            self.mode = mode
            self.intensity = intensity
            self.depth = depth
            self.followUps = followUps
            self.date = date
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
