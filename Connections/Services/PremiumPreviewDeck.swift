//
//  PremiumPreviewDeck.swift
//  Connections
//

import Foundation

enum PremiumPreviewFeature: String, CaseIterable, Identifiable {
    case mortalityConversations
    case lifeStory
    case shareExperience

    var id: String { rawValue }

    var previewIDs: [String] {
        switch self {
        case .mortalityConversations:
            return [
                "mc_unsaidLove_001",
                "mc_gratitudeBeforeTooLate_001",
                "mc_ordinaryMoments_001",
                "mc_legacy_001",
                "mc_mortalityClarity_001"
            ]
        case .lifeStory:
            return [
                "ls_childhood_001",
                "ls_schoolAndGrowingUp_010",
                "ls_workAndEarlyAdulthood_019",
                "ls_lookingBack_045",
                "ls_legacy_047"
            ]
        case .shareExperience:
            return [
                "se1",
                "se3",
                "se7",
                "se10",
                "se6"
            ]
        }
    }

    @MainActor
    func isUnlocked(by entitlements: EntitlementStore) -> Bool {
        switch self {
        case .mortalityConversations:
            return entitlements.canUseMortalityConversations
        case .lifeStory:
            return entitlements.canUseLifeStory
        case .shareExperience:
            return entitlements.canUseShareExperience
        }
    }

    @MainActor
    func shouldUsePreview(for entitlements: EntitlementStore) -> Bool {
        !isUnlocked(by: entitlements)
    }
}

enum PremiumPreviewDeck {
    static let count = 5

    static func mortalityPrompts(
        bank: MortalityConversationBank = .shared
    ) -> [MortalityConversationPrompt] {
        resolve(
            ids: PremiumPreviewFeature.mortalityConversations.previewIDs,
            from: bank.prompts,
            id: \.id
        )
    }

    static func lifeStoryPrompts(
        bank: LifeStoryBank = .shared
    ) -> [LifeStoryPrompt] {
        resolve(
            ids: PremiumPreviewFeature.lifeStory.previewIDs,
            from: bank.prompts,
            id: \.id
        )
    }

    static func shareExperiences(
        bank: ShareExperienceBank = .shared
    ) -> [ShareExperience] {
        resolve(
            ids: PremiumPreviewFeature.shareExperience.previewIDs,
            from: bank.experiences,
            id: \.id
        )
    }

    private static func resolve<Item>(
        ids: [String],
        from items: [Item],
        id: KeyPath<Item, String>
    ) -> [Item] {
        let itemsByID = Dictionary(uniqueKeysWithValues: items.map { ($0[keyPath: id], $0) })
        let resolved = ids.compactMap { itemsByID[$0] }

        #if DEBUG
        let resolvedIDs = Set(resolved.map { $0[keyPath: id] })
        let missingIDs = ids.filter { !resolvedIDs.contains($0) }
        precondition(
            missingIDs.isEmpty,
            "Missing premium preview IDs: \(missingIDs.joined(separator: ", "))"
        )
        #endif

        return resolved
    }
}
