//
//  PromptBank.swift
//  Connections
//

import Foundation

struct PromptBank {
    static let shared = PromptBank()

    let prompts: [Prompt]

    private init() {
        prompts = Self.loadFromBundle()
    }

    /// Returns prompts matching the given criteria.
    func prompts(for mode: Mode, intensity: Intensity, depthLevel: DepthLevel) -> [Prompt] {
        prompts.filter { $0.mode == mode && $0.intensity == intensity && $0.depthLevel == depthLevel }
    }

    /// Returns prompts for the given mode and intensity across all unlocked depth levels.
    func prompts(for mode: Mode, intensity: Intensity, unlockedThrough depthLevel: DepthLevel) -> [Prompt] {
        prompts.filter { $0.mode == mode && $0.intensity == intensity && $0.depthLevel <= depthLevel }
    }

    /// Returns prompts for the given mode across multiple intensities up to the unlocked depth.
    func prompts(for mode: Mode, intensities: [Intensity], unlockedThrough depthLevel: DepthLevel) -> [Prompt] {
        let set = Set(intensities)
        return prompts.filter { $0.mode == mode && set.contains($0.intensity) && $0.depthLevel <= depthLevel }
    }

    /// Returns topics that have at least one prompt for the given mode and intensity,
    /// plus any guided-flow topics available for that mode.
    func availableTopics(for mode: Mode, intensity: Intensity) -> [Topic] {
        if intensity == .mixed {
            let present = Set(prompts.filter { $0.mode == mode && Intensity.concrete.contains($0.intensity) }.map(\.topic))
            return Topic.availableFor(mode: mode).filter { $0.isGuidedFlow || present.contains($0) }
        }
        let present = Set(prompts.filter { $0.mode == mode && $0.intensity == intensity }.map(\.topic))
        return Topic.availableFor(mode: mode).filter { $0.isGuidedFlow || present.contains($0) }
    }

    // MARK: - JSON Loading

    private struct BankDTO: Decodable {
        let schemaVersion: Int
        let language: String
        struct PromptDTO: Decodable {
            let id: String
            let text: String
            let mode: String
            let intensity: String
            let depth: String
            let topic: String
            struct FollowUpDTO: Decodable {
                let id: String
                let text: String
                let style: String
            }
            let followUps: [FollowUpDTO]
        }
        let prompts: [PromptDTO]
    }

    private static func loadFromBundle() -> [Prompt] {
        let loaded = JSONBankLoader.load(bankName: "prompts")
        guard let dto = try? JSONDecoder().decode(BankDTO.self, from: loaded.data) else {
            fatalError("prompts_\(loaded.locale).json malformed")
        }
        let file = "prompts_\(loaded.locale).json"
        #if DEBUG
        precondition(dto.schemaVersion == 1, "\(file): unsupported schemaVersion \(dto.schemaVersion)")
        #endif
        var result: [Prompt] = []
        for (index, p) in dto.prompts.enumerated() {
            guard let mode = Mode(jsonCode: p.mode),
                  let intensity = Intensity(jsonCode: p.intensity),
                  let depth = DepthLevel(jsonCode: p.depth),
                  let topic = Topic(jsonCode: p.topic) else {
                #if DEBUG
                fatalError("\(file) prompt[\(index)] id='\(p.id)': unrecognized mode/intensity/depth/topic")
                #else
                continue
                #endif
            }
            var followUps: [FollowUp] = []
            for (fi, fu) in p.followUps.enumerated() {
                guard let style = FollowUpStyle(jsonCode: fu.style) else {
                    #if DEBUG
                    fatalError("\(file) prompt[\(index)] followUp[\(fi)]: unrecognized style '\(fu.style)'")
                    #else
                    continue
                    #endif
                }
                followUps.append(FollowUp(id: fu.id, text: fu.text, style: style))
            }
            result.append(Prompt(id: p.id, text: p.text, mode: mode, intensity: intensity,
                                 depthLevel: depth, topic: topic, followUps: followUps))
        }
        return result
    }
}
