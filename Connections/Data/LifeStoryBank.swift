//
//  LifeStoryBank.swift
//  Connections
//

import Foundation

// MARK: - Chapter

enum LifeStoryChapter: Int, CaseIterable, Identifiable, Codable {
    case childhood = 1
    case schoolAndGrowingUp
    case workAndEarlyAdulthood
    case loveAndPartnership
    case parentingAndFamilyLife
    case hardshipAndResilience
    case beliefsAndValues
    case lookingBack
    case legacy

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .childhood: return "Childhood"
        case .schoolAndGrowingUp: return "School and Growing Up"
        case .workAndEarlyAdulthood: return "Work and Early Adulthood"
        case .loveAndPartnership: return "Love and Partnership"
        case .parentingAndFamilyLife: return "Parenting and Family Life"
        case .hardshipAndResilience: return "Hardship and Resilience"
        case .beliefsAndValues: return "Beliefs and Values"
        case .lookingBack: return "Looking Back"
        case .legacy: return "Legacy"
        }
    }
}

// MARK: - Prompt

struct LifeStoryPrompt: Identifiable, Codable {
    let id: String
    let text: String
    let chapter: LifeStoryChapter
    let order: Int
    let followUp1: String
    let followUp2: String
}

// MARK: - Bank

struct LifeStoryBank {
    static let shared = LifeStoryBank()

    let prompts: [LifeStoryPrompt]

    private init() {
        prompts = Self.loadFromBundle()
    }

    var count: Int { prompts.count }

    func prompt(at index: Int) -> LifeStoryPrompt? {
        guard index >= 0 && index < prompts.count else { return nil }
        return prompts[index]
    }

    func chapter(for index: Int) -> LifeStoryChapter? {
        prompt(at: index)?.chapter
    }

    func promptsInChapter(_ chapter: LifeStoryChapter) -> [LifeStoryPrompt] {
        prompts.filter { $0.chapter == chapter }
    }

    // MARK: - JSON Loading

    private struct BankDTO: Decodable {
        let schemaVersion: Int
        let language: String
        struct PromptDTO: Decodable {
            let id: String
            let text: String
            let chapter: String
            let order: Int
            let followUp1: String
            let followUp2: String
        }
        let prompts: [PromptDTO]
    }

    private static func loadFromBundle() -> [LifeStoryPrompt] {
        let loaded = JSONBankLoader.load(bankName: "life_story")
        guard let dto = try? JSONDecoder().decode(BankDTO.self, from: loaded.data) else {
            fatalError("life_story_\(loaded.locale).json malformed")
        }
        let file = "life_story_\(loaded.locale).json"
        #if DEBUG
        precondition(dto.schemaVersion == 1, "\(file): unsupported schemaVersion \(dto.schemaVersion)")
        #endif
        var result: [LifeStoryPrompt] = []
        for (index, p) in dto.prompts.enumerated() {
            guard let chapter = LifeStoryChapter(jsonCode: p.chapter) else {
                #if DEBUG
                fatalError("\(file) prompt[\(index)] id='\(p.id)': unrecognized chapter '\(p.chapter)'")
                #else
                continue
                #endif
            }
            result.append(LifeStoryPrompt(id: p.id, text: p.text, chapter: chapter, order: p.order,
                                          followUp1: p.followUp1, followUp2: p.followUp2))
        }
        return result.sorted { $0.order < $1.order }
    }
}
