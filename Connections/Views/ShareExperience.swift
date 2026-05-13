//
//  ShareExperience.swift
//  Connections
//

import Foundation

struct ShareExperience: Identifiable, Codable {
    let id: String
    let fullText: String
    let intensity: Intensity
    let topic: Topic
}
