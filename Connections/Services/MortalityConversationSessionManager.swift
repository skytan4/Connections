//
//  MortalityConversationSessionManager.swift
//  Connections
//

import Foundation

@Observable
final class MortalityConversationSessionManager {

    private(set) var prompts: [MortalityConversationPrompt]
    private(set) var currentIndex: Int = 0
    private(set) var selectedLength: SessionLength
    private(set) var selectedTopics: Set<MortalityConversationTopic>

    init(length: SessionLength, topics: Set<MortalityConversationTopic>) {
        selectedLength = length
        selectedTopics = topics
        prompts = Self.buildSessionPrompts(length: length, topics: topics)
    }

    var currentPrompt: MortalityConversationPrompt? {
        guard currentIndex >= 0 && currentIndex < prompts.count else { return nil }
        return prompts[currentIndex]
    }

    var isComplete: Bool {
        !prompts.isEmpty && currentIndex >= prompts.count
    }

    var totalPrompts: Int {
        prompts.count
    }

    var promptsShown: Int {
        min(currentIndex, prompts.count)
    }

    var progress: Double {
        guard totalPrompts > 0 else { return 0 }
        return Double(promptsShown) / Double(totalPrompts)
    }

    var canGoBack: Bool {
        currentIndex > 0 && !isComplete
    }

    func advance() {
        guard currentIndex < prompts.count else { return }
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func restart() {
        prompts = Self.buildSessionPrompts(length: selectedLength, topics: selectedTopics)
        currentIndex = 0
    }

    private static func buildSessionPrompts(
        length: SessionLength,
        topics: Set<MortalityConversationTopic>
    ) -> [MortalityConversationPrompt] {
        let pool = MortalityConversationBank.shared.prompts(in: topics)
        return Array(pool.shuffled().prefix(length.rawValue))
    }
}
