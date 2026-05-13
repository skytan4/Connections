//
//  FallInLoveBank.swift
//  Connections
//

import Foundation

struct FallInLovePrompt: Identifiable, Codable {
    let id: String
    let text: String
    let intensity: Intensity
    let depth: DepthLevel
    let order: Int
}

struct FallInLoveBank {
    static let shared = FallInLoveBank()

    let prompts: [FallInLovePrompt]

    private init() {
        prompts = Self.loadFromBundle()
    }

    var count: Int { prompts.count }

    func prompt(at index: Int) -> FallInLovePrompt? {
        guard index >= 0 && index < prompts.count else { return nil }
        return prompts[index]
    }

    // MARK: - JSON Loading

    private struct BankDTO: Decodable {
        let schemaVersion: Int
        let language: String
        struct PromptDTO: Decodable {
            let id: String
            let text: String
            let intensity: String
            let depth: String
            let order: Int
        }
        let prompts: [PromptDTO]
    }

    private static func loadFromBundle() -> [FallInLovePrompt] {
        let loaded = JSONBankLoader.load(bankName: "fall_in_love")
        guard let dto = try? JSONDecoder().decode(BankDTO.self, from: loaded.data) else {
            fatalError("fall_in_love_\(loaded.locale).json malformed")
        }
        let file = "fall_in_love_\(loaded.locale).json"
        #if DEBUG
        precondition(dto.schemaVersion == 1, "\(file): unsupported schemaVersion \(dto.schemaVersion)")
        #endif
        var result: [FallInLovePrompt] = []
        for (index, p) in dto.prompts.enumerated() {
            guard let intensity = Intensity(jsonCode: p.intensity),
                  let depth = DepthLevel(jsonCode: p.depth) else {
                #if DEBUG
                fatalError("\(file) prompt[\(index)] id='\(p.id)': unrecognized intensity '\(p.intensity)' or depth '\(p.depth)'")
                #else
                continue
                #endif
            }
            result.append(FallInLovePrompt(id: p.id, text: p.text, intensity: intensity, depth: depth, order: p.order))
        }
        return result.sorted { $0.order < $1.order }
    }
}
