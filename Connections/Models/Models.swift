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

    var localizedTitle: String {
        switch self {
        case .couples:        return String(localized: "mode.couples.title",        defaultValue: "Couples")
        case .friends:        return String(localized: "mode.friends.title",        defaultValue: "Friends")
        case .family:         return String(localized: "mode.family.title",         defaultValue: "Family")
        case .soloReflection: return String(localized: "mode.soloReflection.title", defaultValue: "Solo Reflection")
        }
    }

    var localizedDescription: String {
        switch self {
        case .couples:        return String(localized: "mode.couples.description",        defaultValue: "Build chemistry, closeness, and understanding")
        case .friends:        return String(localized: "mode.friends.description",        defaultValue: "Go beyond small talk")
        case .family:         return String(localized: "mode.family.description",         defaultValue: "Strengthen connection across generations")
        case .soloReflection: return String(localized: "mode.soloReflection.description", defaultValue: "Reflect with honesty and intention")
        }
    }
}

enum Intensity: String, CaseIterable, Identifiable, Codable {
    case light = "Light"
    case honest = "Honest"
    case unfiltered = "Unfiltered"
    case mixed = "Mixed"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .light: return "Easy and low-pressure"
        case .honest: return "Meaningful and reflective"
        case .unfiltered: return "Deep and emotionally revealing"
        case .mixed: return "A natural blend of tones"
        }
    }

    /// The three concrete (non-mixed) intensities.
    static let concrete: [Intensity] = [.light, .honest, .unfiltered]

    var next: Intensity? {
        switch self {
        case .light: return .honest
        case .honest: return .unfiltered
        case .unfiltered: return nil
        case .mixed: return nil
        }
    }

    var previous: Intensity? {
        switch self {
        case .light: return nil
        case .honest: return .light
        case .unfiltered: return .honest
        case .mixed: return nil
        }
    }

    var localizedTitle: String {
        switch self {
        case .light:      return String(localized: "intensity.light.title",      defaultValue: "Light")
        case .honest:     return String(localized: "intensity.honest.title",     defaultValue: "Honest")
        case .unfiltered: return String(localized: "intensity.unfiltered.title", defaultValue: "Unfiltered")
        case .mixed:      return String(localized: "intensity.mixed.title",      defaultValue: "Mixed")
        }
    }

    var localizedDescription: String {
        switch self {
        case .light:      return String(localized: "intensity.light.description",      defaultValue: "Easy and low-pressure")
        case .honest:     return String(localized: "intensity.honest.description",     defaultValue: "Meaningful and reflective")
        case .unfiltered: return String(localized: "intensity.unfiltered.description", defaultValue: "Deep and emotionally revealing")
        case .mixed:      return String(localized: "intensity.mixed.description",      defaultValue: "A natural blend of tones")
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

    var localizedTitle: String {
        switch self {
        case .warmUp:   return String(localized: "depthLevel.warmUp.title",   defaultValue: "Warm Up")
        case .realTalk: return String(localized: "depthLevel.realTalk.title", defaultValue: "Real Talk")
        case .deepDive: return String(localized: "depthLevel.deepDive.title", defaultValue: "Deep Dive")
        }
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

    /// Mode-aware display name (e.g. "Fall in Love" for couples, "Get Closer" for friends).
    func displayName(for mode: Mode?) -> String {
        if self == .fallInLove && mode == .friends { return "Get Closer" }
        return displayName
    }

    var localizedDisplayName: String {
        switch self {
        case .communication: return String(localized: "topic.communication", defaultValue: "Communication")
        case .emotions:      return String(localized: "topic.emotions",      defaultValue: "Emotions")
        case .appreciation:  return String(localized: "topic.appreciation",  defaultValue: "Appreciation")
        case .conflict:      return String(localized: "topic.conflict",      defaultValue: "Conflict")
        case .growth:        return String(localized: "topic.growth",        defaultValue: "Growth")
        case .values:        return String(localized: "topic.values",        defaultValue: "Values")
        case .past:          return String(localized: "topic.past",          defaultValue: "Past")
        case .intimacy:      return String(localized: "topic.intimacy",      defaultValue: "Intimacy")
        case .dailyLife:     return String(localized: "topic.dailyLife",     defaultValue: "Daily Life")
        case .identity:      return String(localized: "topic.identity",      defaultValue: "Identity")
        case .sex:           return String(localized: "topic.sex",           defaultValue: "Sex")
        case .parenting:     return String(localized: "topic.parenting",     defaultValue: "Parenting")
        case .fallInLove:    return String(localized: "topic.fallInLove",    defaultValue: "Fall in Love")
        }
    }

    func localizedDisplayName(for mode: Mode?) -> String {
        if self == .fallInLove && mode == .friends {
            return String(localized: "topic.fallInLove.friends", defaultValue: "Get Closer",
                          comment: "The Fall in Love topic name shown in Friends mode.")
        }
        return localizedDisplayName
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

    var localizedLabel: String {
        switch self {
        case .short:  return String(localized: "sessionLength.five.label",   defaultValue: "5 prompts")
        case .medium: return String(localized: "sessionLength.ten.label",    defaultValue: "10 prompts")
        case .long:   return String(localized: "sessionLength.twenty.label", defaultValue: "20 prompts")
        }
    }
}

// MARK: - Data Models

struct Prompt: Identifiable, Codable {
    let id: String
    let text: String
    let mode: Mode
    let intensity: Intensity
    let depthLevel: DepthLevel
    let topic: Topic
    let followUps: [FollowUp]
}

enum FollowUpStyle: String, Codable, CaseIterable, Hashable {
    case origin
    case meaning
    case impact
    case need
    case tension
}

struct FollowUp: Identifiable, Hashable, Codable {
    let id: String
    let text: String
    let style: FollowUpStyle
}

struct PromptResponse: Identifiable, Codable {
    let id: UUID
    let promptID: String
    let promptText: String
    let action: PromptAction
    let isFavorited: Bool
    let date: Date

    init(id: UUID = UUID(), promptID: String, promptText: String, action: PromptAction, isFavorited: Bool = false, date: Date = .now) {
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
