//
//  Models.swift
//  Connections
//

import Foundation

// MARK: - Core Enums

enum Mode: String, CaseIterable, Identifiable, Codable {
    case couples = "Couples"
    case friends = "Friends"
    case family = "Family"
    case soloReflection = "Solo Reflection"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .couples: return "Build chemistry, closeness, and understanding"
        case .friends: return "Go beyond small talk"
        case .family: return "Strengthen connection across generations"
        case .soloReflection: return "Reflect with honesty and intention"
        }
    }

    var iconName: String {
        switch self {
        case .couples: return "heart.fill"
        case .friends: return "person.2.fill"
        case .family: return "house.fill"
        case .soloReflection: return "person.fill"
        }
    }
}

enum Intensity: String, CaseIterable, Identifiable, Codable {
    case light = "Light"
    case honest = "Honest"
    case unfiltered = "Unfiltered"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .light: return "Easy and low-pressure"
        case .honest: return "Meaningful and reflective"
        case .unfiltered: return "Deep and emotionally revealing"
        }
    }

    var next: Intensity? {
        switch self {
        case .light: return .honest
        case .honest: return .unfiltered
        case .unfiltered: return nil
        }
    }

    var previous: Intensity? {
        switch self {
        case .light: return nil
        case .honest: return .light
        case .unfiltered: return .honest
        }
    }
}

enum DepthLevel: Int, CaseIterable, Identifiable, Codable, Comparable {
    case warmUp = 0
    case realTalk = 1
    case deepDive = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .warmUp: return "Warm Up"
        case .realTalk: return "Real Talk"
        case .deepDive: return "Deep Dive"
        }
    }

    /// Number of continued prompts at the current depth needed to unlock the next.
    static let promptsToUnlockNext = 5

    static func < (lhs: DepthLevel, rhs: DepthLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// The next depth level, if one exists.
    var next: DepthLevel? {
        DepthLevel(rawValue: rawValue + 1)
    }
}

enum Topic: String, CaseIterable, Identifiable, Codable {
    case communication
    case emotions
    case appreciation
    case conflict
    case growth
    case values
    case past
    case intimacy
    case dailyLife
    case identity
    case sex
    case parenting
    case fallInLove

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .communication: return "Communication"
        case .emotions: return "Emotions"
        case .appreciation: return "Appreciation"
        case .conflict: return "Conflict"
        case .growth: return "Growth"
        case .values: return "Values"
        case .past: return "Past"
        case .intimacy: return "Intimacy"
        case .dailyLife: return "Daily Life"
        case .identity: return "Identity"
        case .sex: return "Sex"
        case .parenting: return "Parenting"
        case .fallInLove: return "Fall in Love"
        }
    }

    /// Topics available in the free version.
    // TODO: Restore gating for monetization — currently unlocked for testing
    static let freeTopics: Set<Topic> = Set(Topic.allCases)

    var isFree: Bool { Self.freeTopics.contains(self) }

    /// Mode-aware display name (e.g. "Fall in Love" for couples, "Get Closer" for friends).
    func displayName(for mode: Mode?) -> String {
        if self == .fallInLove && mode == .friends { return "Get Closer" }
        return displayName
    }

    /// Topics that use a separate guided flow instead of the random session.
    var isGuidedFlow: Bool { self == .fallInLove }

    /// Topics only available for certain modes.
    static func availableFor(mode: Mode) -> [Topic] {
        Topic.allCases.filter { topic in
            if topic == .fallInLove { return mode == .couples || mode == .friends }
            if topic == .parenting { return mode == .couples }
            return true
        }
    }
}

enum SessionLength: Int, CaseIterable, Identifiable {
    case short = 5
    case medium = 10
    case long = 20

    var id: Int { rawValue }

    var label: String { "\(rawValue) prompts" }
}

// MARK: - Data Models

struct Prompt: Identifiable, Codable {
    let id: UUID
    let text: String
    let mode: Mode
    let intensity: Intensity
    let depthLevel: DepthLevel
    let topic: Topic
    let followUps: [FollowUp]

    init(id: UUID = UUID(), text: String, mode: Mode, intensity: Intensity, depthLevel: DepthLevel, topic: Topic, followUps: [FollowUp] = []) {
        self.id = id
        self.text = text
        self.mode = mode
        self.intensity = intensity
        self.depthLevel = depthLevel
        self.topic = topic
        self.followUps = followUps
    }
}

enum FollowUpStyle: String, Codable, CaseIterable, Hashable {
    case origin
    case meaning
    case impact
    case need
    case tension
}

struct FollowUp: Identifiable, Hashable, Codable {
    let id: UUID
    let text: String
    let style: FollowUpStyle

    init(id: UUID = UUID(), text: String, style: FollowUpStyle = .meaning) {
        self.id = id
        self.text = text
        self.style = style
    }
}

struct PromptResponse: Identifiable, Codable {
    let id: UUID
    let promptID: UUID
    let promptText: String
    let action: PromptAction
    let isFavorited: Bool
    let date: Date

    init(id: UUID = UUID(), promptID: UUID, promptText: String, action: PromptAction, isFavorited: Bool = false, date: Date = .now) {
        self.id = id
        self.promptID = promptID
        self.promptText = promptText
        self.action = action
        self.isFavorited = isFavorited
        self.date = date
    }
}

enum PromptAction: String, Codable {
    case continued
    case skipped
}
