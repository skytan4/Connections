//
//  ContentLibraryStats.swift
//  Connections
//

import Foundation

enum ContentLibraryStats {
    // Mortality, Share Experiences, and Fall in Love banks have no follow-ups,
    // so their bucket totals equal their prompt counts.
    static var mortalityPromptCount: Int {
        MortalityConversationBank.shared.count
    }

    static var mortalityTopicCount: Int {
        MortalityConversationTopic.allCases.count
    }

    static var lifeStoryPromptCount: Int {
        LifeStoryBank.shared.count
    }

    static var lifeStoryChapterCount: Int {
        LifeStoryChapter.allCases.count
    }

    static var lifeStoryQuestionAndFollowUpCount: Int {
        LifeStoryBank.shared.prompts.reduce(0) { count, prompt in
            count + 1 + (prompt.followUp1.isEmpty ? 0 : 1) + (prompt.followUp2.isEmpty ? 0 : 1)
        }
    }

    static var shareExperienceCount: Int {
        ShareExperienceBank.shared.experiences.count
    }

    static var premiumQuestionAndFollowUpCount: Int {
        let lockedStandardPrompts = PromptBank.shared.prompts.filter { prompt in
            prompt.requiresPremiumAccess
        }
        let lockedStandardQuestions = lockedStandardPrompts.count
        let lockedStandardFollowUps = lockedStandardPrompts.reduce(0) { $0 + $1.followUps.count }

        return lockedStandardQuestions
            + lockedStandardFollowUps
            + mortalityPromptCount
            + lifeStoryQuestionAndFollowUpCount
            + FallInLoveBank.shared.count
            + shareExperienceCount
    }

    static var totalQuestionAndFollowUpCount: Int {
        let promptQuestions = PromptBank.shared.prompts.count
        let promptFollowUps = PromptBank.shared.prompts.reduce(0) { $0 + $1.followUps.count }

        return promptQuestions
            + promptFollowUps
            + mortalityPromptCount
            + lifeStoryQuestionAndFollowUpCount
            + FallInLoveBank.shared.count
            + shareExperienceCount
    }

    static func formattedCount(_ count: Int) -> String {
        count.formatted(.number.grouping(.automatic))
    }
}
