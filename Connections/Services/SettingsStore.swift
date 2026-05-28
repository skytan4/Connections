//
//  SettingsStore.swift
//  Connections
//

import Foundation

@Observable
final class SettingsStore {
    // MARK: - Session

    var defaultSessionLength: SessionLength {
        didSet { save() }
    }

    var followUpsByDefault: Bool {
        didSet { save() }
    }

    // MARK: - Experience

    var hapticsEnabled: Bool {
        didSet { save() }
    }

    var skipFallInLoveIntroCouples: Bool {
        didSet { save() }
    }

    var skipFallInLoveIntroFriends: Bool {
        didSet { save() }
    }

    var skipLifeStoryIntro: Bool {
        didSet { save() }
    }

    // MARK: - Onboarding

    var hasSeenOnboarding: Bool {
        didSet { save() }
    }

    // MARK: - Actions

    func resetToDefaults() {
        defaultSessionLength = .medium
        followUpsByDefault = true
        hapticsEnabled = true
        skipFallInLoveIntroCouples = false
        skipFallInLoveIntroFriends = false
        skipLifeStoryIntro = false
        hasSeenOnboarding = false
    }

    // MARK: - Persistence

    private static let storageKey = "connections_settings"

    init() {
        let defaults = Self.loadDefaults()
        self.defaultSessionLength = defaults.defaultSessionLength
        self.followUpsByDefault = defaults.followUpsByDefault
        self.hapticsEnabled = defaults.hapticsEnabled
        self.skipFallInLoveIntroCouples = defaults.skipFallInLoveIntroCouples
        self.skipFallInLoveIntroFriends = defaults.skipFallInLoveIntroFriends
        self.skipLifeStoryIntro = defaults.skipLifeStoryIntro
        self.hasSeenOnboarding = defaults.hasSeenOnboarding
    }

    private func save() {
        let data = PersistedSettings(
            defaultSessionLengthRaw: defaultSessionLength.rawValue,
            followUpsByDefault: followUpsByDefault,
            hapticsEnabled: hapticsEnabled,
            skipFallInLoveIntroCouples: skipFallInLoveIntroCouples,
            skipFallInLoveIntroFriends: skipFallInLoveIntroFriends,
            skipLifeStoryIntro: skipLifeStoryIntro,
            hasSeenOnboarding: hasSeenOnboarding
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    private static func loadDefaults() -> (defaultSessionLength: SessionLength, followUpsByDefault: Bool, hapticsEnabled: Bool, skipFallInLoveIntroCouples: Bool, skipFallInLoveIntroFriends: Bool, skipLifeStoryIntro: Bool, hasSeenOnboarding: Bool) {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PersistedSettings.self, from: data) else {
            return (.medium, true, true, false, false, false, false)
        }
        let length = SessionLength(rawValue: decoded.defaultSessionLengthRaw) ?? .medium
        // Migrate old single flag to couples if present
        let couplesSkip = decoded.skipFallInLoveIntroCouples ?? decoded.skipFallInLoveIntro ?? false
        let friendsSkip = decoded.skipFallInLoveIntroFriends ?? false
        let lifeStorySkip = decoded.skipLifeStoryIntro ?? false
        return (length, decoded.followUpsByDefault, decoded.hapticsEnabled, couplesSkip, friendsSkip, lifeStorySkip, decoded.hasSeenOnboarding ?? false)
    }

    private struct PersistedSettings: Codable {
        let defaultSessionLengthRaw: Int
        let followUpsByDefault: Bool
        var avoidRepeats: Bool? = nil   // legacy field — decoded for old JSON, never written
        let hapticsEnabled: Bool
        var skipFallInLoveIntro: Bool? = nil     // legacy, migrated to couples
        let skipFallInLoveIntroCouples: Bool?
        let skipFallInLoveIntroFriends: Bool?
        let skipLifeStoryIntro: Bool?
        let hasSeenOnboarding: Bool?
    }
}
