import XCTest
@testable import Connections

final class PremiumPreviewDeckTests: XCTestCase {

    func testEveryPremiumPreviewFeatureUsesFiveStableIDs() {
        for feature in PremiumPreviewFeature.allCases {
            XCTAssertEqual(feature.previewIDs.count, PremiumPreviewDeck.count)
            XCTAssertEqual(feature.previewIDs.count, Set(feature.previewIDs).count)
        }
    }

    func testMortalityPreviewResolvesSameFivePromptsInOrder() {
        let prompts = PremiumPreviewDeck.mortalityPrompts()

        XCTAssertEqual(prompts.map(\.id), PremiumPreviewFeature.mortalityConversations.previewIDs)
        XCTAssertEqual(prompts.count, PremiumPreviewDeck.count)
    }

    func testLifeStoryPreviewResolvesSameFivePromptsInOrder() {
        let prompts = PremiumPreviewDeck.lifeStoryPrompts()

        XCTAssertEqual(prompts.map(\.id), PremiumPreviewFeature.lifeStory.previewIDs)
        XCTAssertEqual(prompts.count, PremiumPreviewDeck.count)
    }

    func testShareExperiencePreviewResolvesSameFiveExperiencesInOrder() {
        let experiences = PremiumPreviewDeck.shareExperiences()

        XCTAssertEqual(experiences.map(\.id), PremiumPreviewFeature.shareExperience.previewIDs)
        XCTAssertEqual(experiences.count, PremiumPreviewDeck.count)
    }

    @MainActor
    func testLockedFeaturesUsePreviewWhenForcedFree() {
        let entitlements = EntitlementStore()
        entitlements.debugOverride = .forcedFree

        XCTAssertTrue(PremiumPreviewFeature.mortalityConversations.shouldUsePreview(for: entitlements))
        XCTAssertTrue(PremiumPreviewFeature.lifeStory.shouldUsePreview(for: entitlements))
        XCTAssertTrue(PremiumPreviewFeature.shareExperience.shouldUsePreview(for: entitlements))
    }

    @MainActor
    func testUnlockedFeaturesDoNotUsePreviewWhenForcedPremium() {
        let entitlements = EntitlementStore()
        entitlements.debugOverride = .forcedPremium

        XCTAssertFalse(PremiumPreviewFeature.mortalityConversations.shouldUsePreview(for: entitlements))
        XCTAssertFalse(PremiumPreviewFeature.lifeStory.shouldUsePreview(for: entitlements))
        XCTAssertFalse(PremiumPreviewFeature.shareExperience.shouldUsePreview(for: entitlements))
    }
}
