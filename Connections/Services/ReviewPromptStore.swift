//
//  ReviewPromptStore.swift
//  Connections
//

import Foundation

@Observable
final class ReviewPromptStore {

    private(set) var firstOpenDate: Date?
    private(set) var uniqueUsageDaysCount: Int
    private(set) var completedSessionsCount: Int
    private(set) var lastPaywallShownAt: Date?
    private(set) var lastReviewPromptAttemptAt: Date?
    private var lastActiveDayKey: String?

    // MARK: - Init

    init() {
        let persisted = Self.load()
        self.firstOpenDate = persisted.firstOpenDate
        self.uniqueUsageDaysCount = persisted.uniqueUsageDaysCount
        self.completedSessionsCount = persisted.completedSessionsCount
        self.lastPaywallShownAt = persisted.lastPaywallShownAt
        self.lastReviewPromptAttemptAt = persisted.lastReviewPromptAttemptAt
        self.lastActiveDayKey = persisted.lastActiveDayKey
    }

    // MARK: - Recording

    func recordAppOpen() {
        let now = Date()

        if firstOpenDate == nil {
            firstOpenDate = now
        }

        let todayKey = Self.dayKey(for: now)
        if lastActiveDayKey != todayKey {
            uniqueUsageDaysCount += 1
            lastActiveDayKey = todayKey
        }

        save()
    }

    func recordCompletedSession() {
        completedSessionsCount += 1
        save()
    }

    func recordPaywallShown() {
        lastPaywallShownAt = Date()
        save()
    }

    func recordReviewPromptAttempt() {
        lastReviewPromptAttemptAt = Date()
        save()
    }

    // MARK: - Eligibility

    func shouldPromptForReview(now: Date = .now, isDebugOverride: Bool) -> Bool {
        if isDebugOverride { return false }

        guard completedSessionsCount >= 3 else { return false }
        guard uniqueUsageDaysCount >= 3 else { return false }

        if let firstOpen = firstOpenDate {
            let daysSinceFirstOpen = Calendar.current.dateComponents([.day], from: firstOpen, to: now).day ?? 0
            guard daysSinceFirstOpen >= 5 else { return false }
        } else {
            return false
        }

        if let lastPaywall = lastPaywallShownAt {
            let hoursSincePaywall = now.timeIntervalSince(lastPaywall) / 3600
            guard hoursSincePaywall >= 24 else { return false }
        }

        if let lastAttempt = lastReviewPromptAttemptAt {
            let daysSinceLastAttempt = Calendar.current.dateComponents([.day], from: lastAttempt, to: now).day ?? 0
            guard daysSinceLastAttempt >= 90 else { return false }
        }

        return true
    }

    // MARK: - Persistence

    private static let storageKey = "layers_review_prompt"

    private struct Persisted: Codable {
        var firstOpenDate: Date?
        var uniqueUsageDaysCount: Int
        var completedSessionsCount: Int
        var lastPaywallShownAt: Date?
        var lastReviewPromptAttemptAt: Date?
        var lastActiveDayKey: String?
    }

    private static func load() -> Persisted {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(Persisted.self, from: data) else {
            return Persisted(uniqueUsageDaysCount: 0, completedSessionsCount: 0)
        }
        return decoded
    }

    private func save() {
        let persisted = Persisted(
            firstOpenDate: firstOpenDate,
            uniqueUsageDaysCount: uniqueUsageDaysCount,
            completedSessionsCount: completedSessionsCount,
            lastPaywallShownAt: lastPaywallShownAt,
            lastReviewPromptAttemptAt: lastReviewPromptAttemptAt,
            lastActiveDayKey: lastActiveDayKey
        )
        if let data = try? JSONEncoder().encode(persisted) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
