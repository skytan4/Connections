//
//  JSONEnumCoding.swift
//  Connections
//

import Foundation

extension Mode {
    init?(jsonCode: String) {
        switch jsonCode {
        case "couples": self = .couples
        case "friends": self = .friends
        case "family": self = .family
        case "soloReflection": self = .soloReflection
        default: return nil
        }
    }
}

extension FollowUpStyle {
    init?(jsonCode: String) {
        switch jsonCode {
        case "origin": self = .origin
        case "meaning": self = .meaning
        case "impact": self = .impact
        case "need": self = .need
        case "tension": self = .tension
        default: return nil
        }
    }
}

extension Intensity {
    init?(jsonCode: String) {
        switch jsonCode {
        case "light": self = .light
        case "honest": self = .honest
        case "unfiltered": self = .unfiltered
        case "mixed": self = .mixed
        default: return nil
        }
    }
}

extension DepthLevel {
    init?(jsonCode: String) {
        switch jsonCode {
        case "warmUp": self = .warmUp
        case "realTalk": self = .realTalk
        case "deepDive": self = .deepDive
        default: return nil
        }
    }
}

extension LifeStoryChapter {
    init?(jsonCode: String) {
        switch jsonCode {
        case "childhood": self = .childhood
        case "schoolAndGrowingUp": self = .schoolAndGrowingUp
        case "workAndEarlyAdulthood": self = .workAndEarlyAdulthood
        case "loveAndPartnership": self = .loveAndPartnership
        case "parentingAndFamilyLife": self = .parentingAndFamilyLife
        case "hardshipAndResilience": self = .hardshipAndResilience
        case "beliefsAndValues": self = .beliefsAndValues
        case "lookingBack": self = .lookingBack
        case "legacy": self = .legacy
        default: return nil
        }
    }
}

extension Topic {
    init?(jsonCode: String) {
        switch jsonCode {
        case "communication": self = .communication
        case "emotions": self = .emotions
        case "appreciation": self = .appreciation
        case "conflict": self = .conflict
        case "growth": self = .growth
        case "values": self = .values
        case "past": self = .past
        case "intimacy": self = .intimacy
        case "dailyLife": self = .dailyLife
        case "identity": self = .identity
        case "sex": self = .sex
        case "parenting": self = .parenting
        case "fallInLove": self = .fallInLove
        default: return nil
        }
    }
}
