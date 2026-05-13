//
//  ShareExperienceBank.swift
//  Connections
//

import Foundation

struct ShareExperienceBank {
    static let shared = ShareExperienceBank()

    let experiences: [ShareExperience]

    private init() {
        experiences = Self.loadFromBundle()
    }

    func getRandomExperience(intensity: Intensity? = nil, topic: Topic? = nil) -> ShareExperience? {
        var filtered = experiences
        if let intensity { filtered = filtered.filter { $0.intensity == intensity } }
        if let topic { filtered = filtered.filter { $0.topic == topic } }
        return filtered.randomElement()
    }

    func experiences(intensity: Intensity? = nil, topic: Topic? = nil) -> [ShareExperience] {
        var filtered = experiences
        if let intensity { filtered = filtered.filter { $0.intensity == intensity } }
        if let topic { filtered = filtered.filter { $0.topic == topic } }
        return filtered
    }

    // MARK: - JSON Loading

    private struct BankDTO: Decodable {
        let schemaVersion: Int
        let language: String
        struct ExperienceDTO: Decodable {
            let id: String
            let fullText: String
            let intensity: String
            let topic: String
        }
        let experiences: [ExperienceDTO]
    }

    private static func loadFromBundle() -> [ShareExperience] {
        let loaded = JSONBankLoader.load(bankName: "share_experience")
        guard let dto = try? JSONDecoder().decode(BankDTO.self, from: loaded.data) else {
            fatalError("share_experience_\(loaded.locale).json malformed")
        }
        let file = "share_experience_\(loaded.locale).json"
        #if DEBUG
        precondition(dto.schemaVersion == 1, "\(file): unsupported schemaVersion \(dto.schemaVersion)")
        #endif
        var result: [ShareExperience] = []
        for (index, e) in dto.experiences.enumerated() {
            guard let intensity = Intensity(jsonCode: e.intensity),
                  let topic = Topic(jsonCode: e.topic) else {
                #if DEBUG
                fatalError("\(file) experience[\(index)] id='\(e.id)': unrecognized intensity '\(e.intensity)' or topic '\(e.topic)'")
                #else
                continue
                #endif
            }
            result.append(ShareExperience(id: e.id, fullText: e.fullText, intensity: intensity, topic: topic))
        }
        return result
    }
}
