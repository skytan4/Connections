//
//  ConnectionTracker.swift
//  Connections
//

import Foundation

// MARK: - Feeling

enum Feeling: String, CaseIterable, Identifiable {
    case light
    case meaningful
    case deep
    case hard

    var id: String { rawValue }

    /// SF Symbol name for the feeling icon. Nil means use `emoji` text instead.
    var symbolName: String? {
        switch self {
        case .light: return "heart"
        default: return nil
        }
    }

    var emoji: String? {
        switch self {
        case .light: return nil
        case .meaningful: return "💛"
        case .deep: return "❤️"
        case .hard: return "💔"
        }
    }

    var label: String {
        switch self {
        case .light: return "Light"
        case .meaningful: return "Moved"
        case .deep: return "Deep"
        case .hard: return "Tender"
        }
    }

    /// Internal weight for connection tracking.
    var weight: Double {
        switch self {
        case .light: return 1.0
        case .meaningful: return 2.5
        case .deep: return 4.0
        case .hard: return 3.0
        }
    }

    /// Possible micro-messages shown after selection. Nil means never show.
    var microMessages: [String]? {
        switch self {
        case .light: return nil
        case .meaningful: return [
            "That moved you.",
            "Something landed there.",
            "That one mattered."
        ]
        case .deep: return [
            "You're getting somewhere.",
            "That went deep.",
            "You stayed with it."
        ]
        case .hard: return [
            "That felt tender.",
            "That took honesty.",
            "That touched something."
        ]
        }
    }
}

// MARK: - Connection Level

enum ConnectionLevel: String {
    case openingUp = "Opening Up"
    case connected = "Connected"
    case deeplyConnected = "Deeply Connected"

    static func from(score: Double, maxScore: Double) -> ConnectionLevel {
        guard maxScore > 0 else { return .openingUp }
        let ratio = score / maxScore
        if ratio >= 0.65 {
            return .deeplyConnected
        } else if ratio >= 0.35 {
            return .connected
        }
        return .openingUp
    }

    var completionMessage: String {
        switch self {
        case .openingUp:
            return "You opened up more as you went."
        case .connected:
            return "This became more moving as you stayed with it."
        case .deeplyConnected:
            return "You reached a deeper level tonight."
        }
    }
}

// MARK: - Connection Tracker

struct ConnectionTracker {
    private(set) var feelings: [Feeling] = []
    private(set) var totalScore: Double = 0

    /// The maximum possible score if the user checked in every time at the highest weight.
    var maxPossibleScore: Double {
        Double(max(feelings.count, 1)) * Feeling.deep.weight
    }

    /// 0.0 to 1.0 representing connection fill.
    var fillAmount: Double {
        guard maxPossibleScore > 0 else { return 0 }
        return min(totalScore / maxPossibleScore, 1.0)
    }

    var connectionLevel: ConnectionLevel {
        ConnectionLevel.from(score: totalScore, maxScore: maxPossibleScore)
    }

    var checkInCount: Int { feelings.count }

    mutating func record(_ feeling: Feeling) {
        feelings.append(feeling)
        totalScore += feeling.weight
    }

    mutating func reset() {
        feelings = []
        totalScore = 0
    }
}
