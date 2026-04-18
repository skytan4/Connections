//
//  ShareExperienceBank.swift
//  Connections
//

import Foundation

struct ShareExperienceBank {
    static let shared = ShareExperienceBank()

    let experiences: [ShareExperience]

    private init() {
        experiences = Self.buildExperiences()
    }

    /// Returns a random experience matching the given filters.
    /// Pass nil for either parameter to skip that filter.
    func getRandomExperience(intensity: Intensity? = nil, topic: Topic? = nil) -> ShareExperience? {
        var filtered = experiences
        if let intensity { filtered = filtered.filter { $0.intensity == intensity } }
        if let topic { filtered = filtered.filter { $0.topic == topic } }
        return filtered.randomElement()
    }

    /// Returns all experiences matching the given filters.
    func experiences(intensity: Intensity? = nil, topic: Topic? = nil) -> [ShareExperience] {
        var filtered = experiences
        if let intensity { filtered = filtered.filter { $0.intensity == intensity } }
        if let topic { filtered = filtered.filter { $0.topic == topic } }
        return filtered
    }
}

// MARK: - Experience Data

private extension ShareExperienceBank {

    static func buildExperiences() -> [ShareExperience] {
        [
            ShareExperience(id: "se1", text: "unbelievable", intensity: .light, topic: .dailyLife),
            ShareExperience(id: "se2", text: "gutsy", intensity: .honest, topic: .growth),
            ShareExperience(id: "se3", text: "nostalgic", intensity: .light, topic: .past),
            ShareExperience(id: "se4", text: "provocative", intensity: .unfiltered, topic: .values),
            ShareExperience(id: "se5", text: "heavy", intensity: .unfiltered, topic: .emotions),
            ShareExperience(id: "se6", text: "life-changing", intensity: .honest, topic: .growth),
            ShareExperience(id: "se7", text: "joyful", intensity: .light, topic: .appreciation),
            ShareExperience(id: "se8", text: "unforgettable", intensity: .honest, topic: .past),
            ShareExperience(id: "se9", text: "from your teenage years", intensity: .light, topic: .past),
            ShareExperience(id: "se10", text: "close to your heart", intensity: .honest, topic: .emotions),
            ShareExperience(id: "se11", text: "that gets you worked up", intensity: .unfiltered, topic: .conflict),
            ShareExperience(id: "se12", text: "you wouldn't tell your mother", intensity: .unfiltered, topic: .identity),
            ShareExperience(id: "se13", text: "you wouldn't tell your coworkers", intensity: .honest, topic: .identity),
            ShareExperience(id: "se14", text: "you've never told anyone", intensity: .unfiltered, topic: .identity),
            ShareExperience(id: "se15", text: "that changed your worldview", intensity: .honest, topic: .growth),
            ShareExperience(id: "se16", text: "you've kept secret", intensity: .unfiltered, topic: .identity),
            ShareExperience(id: "se17", text: "crazy", intensity: .light, topic: .dailyLife),
            ShareExperience(id: "se18", text: "out of character", intensity: .honest, topic: .identity),
            ShareExperience(id: "se19", text: "risky", intensity: .unfiltered, topic: .growth),
            ShareExperience(id: "se20", text: "heartbreaking", intensity: .unfiltered, topic: .emotions),
            ShareExperience(id: "se21", text: "cringeworthy", intensity: .light, topic: .dailyLife),
        ]
    }
}
