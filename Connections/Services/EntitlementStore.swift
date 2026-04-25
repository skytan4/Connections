//
//  EntitlementStore.swift
//  Connections
//

import Foundation

@Observable
final class EntitlementStore {

    // MARK: - Debug Override

    #if DEBUG
    enum DebugOverride: String, CaseIterable {
        case system = "System"
        case forcedFree = "Forced Free"
        case forcedPremium = "Forced Premium"
    }

    var debugOverride: DebugOverride = .forcedPremium
    #endif

    // MARK: - System Entitlement

    private(set) var systemEntitlement: Bool = false

    // MARK: - Effective Premium State

    var isPremium: Bool {
        #if DEBUG
        switch debugOverride {
        case .system: return systemEntitlement
        case .forcedFree: return false
        case .forcedPremium: return true
        }
        #else
        return systemEntitlement
        #endif
    }

    // MARK: - Feature Checks

    var canUseUnfiltered: Bool { isPremium }
    var canUseLongSessions: Bool { isPremium }
    var canUseSex: Bool { isPremium }
    var canUseFallInLove: Bool { isPremium }
    var canUseShareExperience: Bool { isPremium }
    var canUseLifeStory: Bool { isPremium }

    var mixedIntensities: [Intensity] {
        isPremium ? [.light, .honest, .unfiltered] : [.light, .honest]
    }
}
