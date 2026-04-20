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

    var avoidRepeats: Bool {
        didSet { save() }
    }

    var hapticsEnabled: Bool {
        didSet { save() }
    }

    // MARK: - Persistence

    private static let storageKey = "connections_settings"

    init() {
        let defaults = Self.loadDefaults()
        self.defaultSessionLength = defaults.defaultSessionLength
        self.followUpsByDefault = defaults.followUpsByDefault
        self.avoidRepeats = defaults.avoidRepeats
        self.hapticsEnabled = defaults.hapticsEnabled
    }

    private func save() {
        let data = PersistedSettings(
            defaultSessionLengthRaw: defaultSessionLength.rawValue,
            followUpsByDefault: followUpsByDefault,
            avoidRepeats: avoidRepeats,
            hapticsEnabled: hapticsEnabled
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    private static func loadDefaults() -> (defaultSessionLength: SessionLength, followUpsByDefault: Bool, avoidRepeats: Bool, hapticsEnabled: Bool) {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PersistedSettings.self, from: data) else {
            return (.medium, true, true, true)
        }
        let length = SessionLength(rawValue: decoded.defaultSessionLengthRaw) ?? .medium
        return (length, decoded.followUpsByDefault, decoded.avoidRepeats, decoded.hapticsEnabled)
    }

    private struct PersistedSettings: Codable {
        let defaultSessionLengthRaw: Int
        let followUpsByDefault: Bool
        let avoidRepeats: Bool
        let hapticsEnabled: Bool
    }
}
