//
//  FallInLoveBank.swift
//  Connections
//

import Foundation

struct FallInLovePrompt: Identifiable, Codable {
    let id: UUID
    let text: String
    let intensity: Intensity
    let depth: DepthLevel
    let order: Int

    init(id: UUID = UUID(), text: String, intensity: Intensity, depth: DepthLevel, order: Int) {
        self.id = id
        self.text = text
        self.intensity = intensity
        self.depth = depth
        self.order = order
    }
}

struct FallInLoveBank {
    static let shared = FallInLoveBank()

    let prompts: [FallInLovePrompt]

    private init() {
        prompts = Self.buildPrompts()
    }

    var count: Int { prompts.count }

    func prompt(at index: Int) -> FallInLovePrompt? {
        guard index >= 0 && index < prompts.count else { return nil }
        return prompts[index]
    }

    private static func buildPrompts() -> [FallInLovePrompt] {
        let all: [FallInLovePrompt] = [
            FallInLovePrompt(text: "If you could invite anyone in the world to dinner, who would it be?", intensity: .honest, depth: .warmUp, order: 1),
            FallInLovePrompt(text: "Would you like to be famous? In what way?", intensity: .honest, depth: .warmUp, order: 2),
            FallInLovePrompt(text: "Before making a call, do you ever rehearse what you're going to say? Why?", intensity: .honest, depth: .warmUp, order: 3),
            FallInLovePrompt(text: "What would a perfect day look like for you?", intensity: .honest, depth: .warmUp, order: 4),
            FallInLovePrompt(text: "When was the last time you sang to yourself or to someone else?", intensity: .honest, depth: .warmUp, order: 5),

            FallInLovePrompt(text: "If you could live to 90 and keep either your mind or body youthful, which would you choose?", intensity: .honest, depth: .realTalk, order: 6),
            FallInLovePrompt(text: "Do you have a sense of how you might die?", intensity: .honest, depth: .realTalk, order: 7),
            FallInLovePrompt(text: "What are three things we might have in common?", intensity: .honest, depth: .realTalk, order: 8),
            FallInLovePrompt(text: "What are you most grateful for right now?", intensity: .honest, depth: .realTalk, order: 9),
            FallInLovePrompt(text: "If you could change something about your upbringing, what would it be?", intensity: .honest, depth: .realTalk, order: 10),
            FallInLovePrompt(text: "Tell your life story in a few minutes", intensity: .honest, depth: .realTalk, order: 11),
            FallInLovePrompt(text: "If you could wake up with a new ability, what would it be?", intensity: .honest, depth: .realTalk, order: 12),

            FallInLovePrompt(text: "If you could know the future, what would you want to learn?", intensity: .unfiltered, depth: .deepDive, order: 13),
            FallInLovePrompt(text: "What's something you've always wanted to do but haven't yet?", intensity: .unfiltered, depth: .deepDive, order: 14),
            FallInLovePrompt(text: "What accomplishment are you most proud of?", intensity: .unfiltered, depth: .deepDive, order: 15),
            FallInLovePrompt(text: "What do you value most in a friendship?", intensity: .unfiltered, depth: .deepDive, order: 16),
            FallInLovePrompt(text: "What is one of your most meaningful memories?", intensity: .unfiltered, depth: .deepDive, order: 17),
            FallInLovePrompt(text: "What is one of your most difficult memories?", intensity: .unfiltered, depth: .deepDive, order: 18),
            FallInLovePrompt(text: "If you had one year left, would you change anything about how you live?", intensity: .unfiltered, depth: .deepDive, order: 19),
            FallInLovePrompt(text: "What does friendship mean to you?", intensity: .unfiltered, depth: .deepDive, order: 20),
            FallInLovePrompt(text: "What role do love and affection play in your life?", intensity: .unfiltered, depth: .deepDive, order: 21),
            FallInLovePrompt(text: "Share something you appreciate about me", intensity: .unfiltered, depth: .deepDive, order: 22),
            FallInLovePrompt(text: "What was your family like growing up?", intensity: .unfiltered, depth: .deepDive, order: 23),
            FallInLovePrompt(text: "How do you feel about your relationship with your mother?", intensity: .unfiltered, depth: .deepDive, order: 24),
            FallInLovePrompt(text: "Create three 'we' statements about us", intensity: .unfiltered, depth: .deepDive, order: 25),
            FallInLovePrompt(text: "Complete: I wish I had someone to share ____ with", intensity: .unfiltered, depth: .deepDive, order: 26),
            FallInLovePrompt(text: "What should I know about you if we became close?", intensity: .unfiltered, depth: .deepDive, order: 27),
            FallInLovePrompt(text: "Tell me something you genuinely appreciate about me", intensity: .unfiltered, depth: .deepDive, order: 28),
            FallInLovePrompt(text: "Share an embarrassing moment", intensity: .unfiltered, depth: .deepDive, order: 29),
            FallInLovePrompt(text: "When did you last cry in front of someone or alone?", intensity: .unfiltered, depth: .deepDive, order: 30),
            FallInLovePrompt(text: "Tell me something you already like about me", intensity: .unfiltered, depth: .deepDive, order: 31),
            FallInLovePrompt(text: "What is too serious to joke about?", intensity: .unfiltered, depth: .deepDive, order: 32),
            FallInLovePrompt(text: "What would you regret not saying if you died tonight?", intensity: .unfiltered, depth: .deepDive, order: 33),
            FallInLovePrompt(text: "What would you save from a fire and why?", intensity: .unfiltered, depth: .deepDive, order: 34),
            FallInLovePrompt(text: "Whose death would affect you most and why?", intensity: .unfiltered, depth: .deepDive, order: 35),
            FallInLovePrompt(text: "Share a personal problem and let your partner reflect back what they heard", intensity: .unfiltered, depth: .deepDive, order: 36),
        ]
        return all.sorted { $0.order < $1.order }
    }
}
