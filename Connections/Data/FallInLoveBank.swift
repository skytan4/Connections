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
        prompts = Self.buildPrompts()
    }

    var count: Int { prompts.count }

    func prompt(at index: Int) -> FallInLovePrompt? {
        guard index >= 0 && index < prompts.count else { return nil }
        return prompts[index]
    }

    private static func buildPrompts() -> [FallInLovePrompt] {
        let all: [FallInLovePrompt] = [
            FallInLovePrompt(id: "fl1", text: "If you could invite anyone in the world to dinner, who would it be?", intensity: .honest, depth: .warmUp, order: 1),
            FallInLovePrompt(id: "fl2", text: "Would you like to be famous? In what way?", intensity: .honest, depth: .warmUp, order: 2),
            FallInLovePrompt(id: "fl3", text: "Before making a call, do you ever rehearse what you're going to say? Why?", intensity: .honest, depth: .warmUp, order: 3),
            FallInLovePrompt(id: "fl4", text: "What would a perfect day look like for you?", intensity: .honest, depth: .warmUp, order: 4),
            FallInLovePrompt(id: "fl5", text: "When was the last time you sang to yourself or to someone else?", intensity: .honest, depth: .warmUp, order: 5),

            FallInLovePrompt(id: "fl6", text: "If you could live to 90 and keep either your mind or body youthful, which would you choose?", intensity: .honest, depth: .realTalk, order: 6),
            FallInLovePrompt(id: "fl7", text: "Do you have a sense of how you might die?", intensity: .honest, depth: .realTalk, order: 7),
            FallInLovePrompt(id: "fl8", text: "What are three things we might have in common?", intensity: .honest, depth: .realTalk, order: 8),
            FallInLovePrompt(id: "fl9", text: "What are you most grateful for right now?", intensity: .honest, depth: .realTalk, order: 9),
            FallInLovePrompt(id: "fl10", text: "If you could change something about your upbringing, what would it be?", intensity: .honest, depth: .realTalk, order: 10),
            FallInLovePrompt(id: "fl11", text: "Tell your life story in a few minutes", intensity: .honest, depth: .realTalk, order: 11),
            FallInLovePrompt(id: "fl12", text: "If you could wake up with a new ability, what would it be?", intensity: .honest, depth: .realTalk, order: 12),

            FallInLovePrompt(id: "fl13", text: "If you could know the future, what would you want to learn?", intensity: .unfiltered, depth: .deepDive, order: 13),
            FallInLovePrompt(id: "fl14", text: "What's something you've always wanted to do but haven't yet?", intensity: .unfiltered, depth: .deepDive, order: 14),
            FallInLovePrompt(id: "fl15", text: "What accomplishment are you most proud of?", intensity: .unfiltered, depth: .deepDive, order: 15),
            FallInLovePrompt(id: "fl16", text: "What do you value most in a friendship?", intensity: .unfiltered, depth: .deepDive, order: 16),
            FallInLovePrompt(id: "fl17", text: "What is one of your most meaningful memories?", intensity: .unfiltered, depth: .deepDive, order: 17),
            FallInLovePrompt(id: "fl18", text: "What is one of your most difficult memories?", intensity: .unfiltered, depth: .deepDive, order: 18),
            FallInLovePrompt(id: "fl19", text: "If you had one year left, would you change anything about how you live?", intensity: .unfiltered, depth: .deepDive, order: 19),
            FallInLovePrompt(id: "fl20", text: "What does friendship mean to you?", intensity: .unfiltered, depth: .deepDive, order: 20),
            FallInLovePrompt(id: "fl21", text: "What role do love and affection play in your life?", intensity: .unfiltered, depth: .deepDive, order: 21),
            FallInLovePrompt(id: "fl22", text: "Share something you appreciate about me", intensity: .unfiltered, depth: .deepDive, order: 22),
            FallInLovePrompt(id: "fl23", text: "What was your family like growing up?", intensity: .unfiltered, depth: .deepDive, order: 23),
            FallInLovePrompt(id: "fl24", text: "How do you feel about your relationship with your mother?", intensity: .unfiltered, depth: .deepDive, order: 24),
            FallInLovePrompt(id: "fl25", text: "Create three 'we' statements about us", intensity: .unfiltered, depth: .deepDive, order: 25),
            FallInLovePrompt(id: "fl26", text: "Complete: I wish I had someone to share ____ with", intensity: .unfiltered, depth: .deepDive, order: 26),
            FallInLovePrompt(id: "fl27", text: "What should I know about you if we became close?", intensity: .unfiltered, depth: .deepDive, order: 27),
            FallInLovePrompt(id: "fl28", text: "Tell me something you genuinely appreciate about me", intensity: .unfiltered, depth: .deepDive, order: 28),
            FallInLovePrompt(id: "fl29", text: "Share an embarrassing moment", intensity: .unfiltered, depth: .deepDive, order: 29),
            FallInLovePrompt(id: "fl30", text: "When did you last cry in front of someone or alone?", intensity: .unfiltered, depth: .deepDive, order: 30),
            FallInLovePrompt(id: "fl31", text: "Tell me something you already like about me", intensity: .unfiltered, depth: .deepDive, order: 31),
            FallInLovePrompt(id: "fl32", text: "What is too serious to joke about?", intensity: .unfiltered, depth: .deepDive, order: 32),
            FallInLovePrompt(id: "fl33", text: "What would you regret not saying if you died tonight?", intensity: .unfiltered, depth: .deepDive, order: 33),
            FallInLovePrompt(id: "fl34", text: "What would you save from a fire and why?", intensity: .unfiltered, depth: .deepDive, order: 34),
            FallInLovePrompt(id: "fl35", text: "Whose death would affect you most and why?", intensity: .unfiltered, depth: .deepDive, order: 35),
            FallInLovePrompt(id: "fl36", text: "Share a personal problem and let your partner reflect back what they heard", intensity: .unfiltered, depth: .deepDive, order: 36),
        ]
        return all.sorted { $0.order < $1.order }
    }
}
