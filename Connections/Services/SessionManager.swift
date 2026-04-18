//
//  SessionManager.swift
//  Connections
//

import Foundation
import SwiftUI

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

    /// Number of prompts the user has *continued* (not skipped) at the current depth.
    private var continuedAtCurrentDepth: Int = 0

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
        connectionTracker.reset()
        showFeelingCheckIn = false
        goDeeperCount = 0
        isSessionActive = true

        currentPrompt = nextPrompt()

        // If the prompt bank has no matching prompts at all, end gracefully.
        if currentPrompt == nil {
            isSessionActive = false
        }
    }

    func continuePrompt(isFavorited: Bool = false) {
        guard let prompt = currentPrompt else { return }

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
        } else if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
        } else {
            currentPrompt = nil
        }
    }

    func recordFeeling(_ feeling: Feeling) {
        connectionTracker.record(feeling)
        continuedSinceLastCheckIn = 0
        showFeelingCheckIn = false
        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
        } else {
            currentPrompt = nil
        }
    }

    /// Record a "Go deeper" tap (either showing follow-ups or triggering a check-in).
    func recordGoDeeper() {
        goDeeperCount += 1
    }

    /// Trigger a check-in after a "Go deeper" interaction, if not already pending.
    func triggerCheckInFromGoDeeper() {
        guard !showFeelingCheckIn, !isSessionComplete else { return }
        showFeelingCheckIn = true
    }

    func dismissCheckIn() {
        continuedSinceLastCheckIn = 0
        showFeelingCheckIn = false
        if !isSessionComplete {
            currentPrompt = nextPrompt()
            if currentPrompt == nil { forceComplete() }
        } else {
            currentPrompt = nil
        }
    }

    func skipPrompt() {
        guard let prompt = currentPrompt else { return }

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
        } else {
            currentPrompt = nil
        }
    }

    func favoriteCurrentPrompt() {
        guard let prompt = currentPrompt else { return }
        favorites.add(prompt)
    }

    func endSession() {
        isSessionActive = false
        currentPrompt = nil
        promptsShown = 0
        responses = []
        shownPromptIDs = []
        continuedAtCurrentDepth = 0
        continuedSinceLastCheckIn = 0
        goDeeperCount = 0
        currentDepth = .warmUp
        maxDepthReached = .warmUp
        showFeelingCheckIn = false
        connectionTracker.reset()
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

    // MARK: - Internal

    /// If prompts are exhausted before the session length is reached, mark the session complete.
    private func forceComplete() {
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

        // Draw from all prompts at or below the current depth for maximum variety.
        let available = PromptBank.shared
            .prompts(for: mode, intensity: intensity, unlockedThrough: currentDepth)
            .filter { !shownPromptIDs.contains($0.id) }

        // Prefer the selected topic, fall back to all topics only as a last resort.
        let candidates: [Prompt]
        if let topic = selectedTopic {
            let topicFiltered = available.filter { $0.topic == topic }
            candidates = topicFiltered.isEmpty ? available : topicFiltered
        } else {
            candidates = available
        }

        guard let chosen = candidates.randomElement() else { return nil }
        shownPromptIDs.insert(chosen.id)
        return chosen
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
        let date: Date

        init(promptID: UUID, promptText: String, mode: Mode, date: Date = .now) {
            self.id = promptID
            self.promptText = promptText
            self.mode = mode
            self.date = date
        }
    }

    /// Adds a prompt to favorites if not already present, and saves immediately.
    mutating func add(_ prompt: Prompt) {
        guard !entries.contains(where: { $0.id == prompt.id }) else { return }
        let entry = FavoriteEntry(promptID: prompt.id, promptText: prompt.text, mode: prompt.mode)
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
