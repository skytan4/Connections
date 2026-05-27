//
//  MortalityConversationBank.swift
//  Connections
//

import Foundation

// MARK: - Topic

enum MortalityConversationTopic: String, CaseIterable, Identifiable, Codable, Hashable {
    case unsaidLove
    case gratitudeBeforeTooLate
    case repairForgiveness
    case rememberedHonestly
    case legacy
    case ordinaryMoments
    case burden
    case dyingAlone
    case suffering
    case peopleLeftBehind
    case childrenMissedFutures
    case deathOfChild
    case suddenLoss
    case anticipatoryGrief
    case friendsStayDisappear
    case caregivingLove
    case autonomyControl
    case spiritualPeaceMeaning
    case regret
    case identityBeyondIllness
    case familyConflict
    case ritualsAnniversaries
    case comfort
    case lastConversation
    case mortalityClarity

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .unsaidLove:
            return String(localized: "mortalityTopic.unsaidLove", defaultValue: "Unsaid Love")
        case .gratitudeBeforeTooLate:
            return String(localized: "mortalityTopic.gratitudeBeforeTooLate", defaultValue: "Gratitude")
        case .repairForgiveness:
            return String(localized: "mortalityTopic.repairForgiveness", defaultValue: "Repair & Forgiveness")
        case .rememberedHonestly:
            return String(localized: "mortalityTopic.rememberedHonestly", defaultValue: "Being Remembered")
        case .legacy:
            return String(localized: "mortalityTopic.legacy", defaultValue: "Legacy")
        case .ordinaryMoments:
            return String(localized: "mortalityTopic.ordinaryMoments", defaultValue: "Ordinary Moments")
        case .burden:
            return String(localized: "mortalityTopic.burden", defaultValue: "Being a Burden")
        case .dyingAlone:
            return String(localized: "mortalityTopic.dyingAlone", defaultValue: "Dying Alone")
        case .suffering:
            return String(localized: "mortalityTopic.suffering", defaultValue: "Suffering")
        case .peopleLeftBehind:
            return String(localized: "mortalityTopic.peopleLeftBehind", defaultValue: "People Left Behind")
        case .childrenMissedFutures:
            return String(localized: "mortalityTopic.childrenMissedFutures", defaultValue: "Missed Futures")
        case .deathOfChild:
            return String(localized: "mortalityTopic.deathOfChild", defaultValue: "Death of a Child")
        case .suddenLoss:
            return String(localized: "mortalityTopic.suddenLoss", defaultValue: "Sudden Loss")
        case .anticipatoryGrief:
            return String(localized: "mortalityTopic.anticipatoryGrief", defaultValue: "Anticipatory Grief")
        case .friendsStayDisappear:
            return String(localized: "mortalityTopic.friendsStayDisappear", defaultValue: "Friends Who Stay")
        case .caregivingLove:
            return String(localized: "mortalityTopic.caregivingLove", defaultValue: "Caregiving")
        case .autonomyControl:
            return String(localized: "mortalityTopic.autonomyControl", defaultValue: "Autonomy & Control")
        case .spiritualPeaceMeaning:
            return String(localized: "mortalityTopic.spiritualPeaceMeaning", defaultValue: "Spiritual Peace")
        case .regret:
            return String(localized: "mortalityTopic.regret", defaultValue: "Regret")
        case .identityBeyondIllness:
            return String(localized: "mortalityTopic.identityBeyondIllness", defaultValue: "Beyond Illness")
        case .familyConflict:
            return String(localized: "mortalityTopic.familyConflict", defaultValue: "Family Conflict")
        case .ritualsAnniversaries:
            return String(localized: "mortalityTopic.ritualsAnniversaries", defaultValue: "Rituals")
        case .comfort:
            return String(localized: "mortalityTopic.comfort", defaultValue: "Comfort")
        case .lastConversation:
            return String(localized: "mortalityTopic.lastConversation", defaultValue: "Last Conversation")
        case .mortalityClarity:
            return String(localized: "mortalityTopic.mortalityClarity", defaultValue: "Mortality Clarity")
        }
    }
}

// MARK: - Prompt

struct MortalityConversationPrompt: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let topic: MortalityConversationTopic
    let order: Int
}

// MARK: - Bank

struct MortalityConversationBank {
    static let shared = MortalityConversationBank()

    let prompts: [MortalityConversationPrompt]

    private init() {
        prompts = Self.loadFromBundle()
    }

    var count: Int { prompts.count }

    func prompts(in topics: Set<MortalityConversationTopic>) -> [MortalityConversationPrompt] {
        guard !topics.isEmpty else { return [] }
        return prompts.filter { topics.contains($0.topic) }
    }

    func prompt(id: String) -> MortalityConversationPrompt? {
        prompts.first { $0.id == id }
    }

    // MARK: - JSON Loading

    private struct BankDTO: Decodable {
        let schemaVersion: Int
        let language: String

        struct PromptDTO: Decodable {
            let id: String
            let text: String
            let topic: String
            let order: Int
        }

        let prompts: [PromptDTO]
    }

    private static func loadFromBundle() -> [MortalityConversationPrompt] {
        let loaded = JSONBankLoader.load(bankName: "mortality_conversations")
        guard let dto = try? JSONDecoder().decode(BankDTO.self, from: loaded.data) else {
            fatalError("mortality_conversations_\(loaded.locale).json malformed")
        }
        let file = "mortality_conversations_\(loaded.locale).json"
        #if DEBUG
        precondition(dto.schemaVersion == 1, "\(file): unsupported schemaVersion \(dto.schemaVersion)")
        #endif

        var result: [MortalityConversationPrompt] = []
        for (index, p) in dto.prompts.enumerated() {
            guard let topic = MortalityConversationTopic(rawValue: p.topic) else {
                #if DEBUG
                fatalError("\(file) prompt[\(index)] id='\(p.id)': unrecognized topic '\(p.topic)'")
                #else
                continue
                #endif
            }
            result.append(MortalityConversationPrompt(id: p.id, text: p.text, topic: topic, order: p.order))
        }
        return result.sorted { $0.order < $1.order }
    }
}
