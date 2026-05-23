//
//  HapticsManager.swift
//  Connections
//

import UIKit

enum HapticsManager {
    static func lightImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func mediumImpact() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    // Reads directly from the same UserDefaults key used by SettingsStore.
    private static var isEnabled: Bool {
        guard let data = UserDefaults.standard.data(forKey: "connections_settings"),
              let decoded = try? JSONDecoder().decode(HapticCheck.self, from: data) else {
            return true // default: enabled
        }
        return decoded.hapticsEnabled
    }

    private struct HapticCheck: Decodable {
        let hapticsEnabled: Bool
    }
}
