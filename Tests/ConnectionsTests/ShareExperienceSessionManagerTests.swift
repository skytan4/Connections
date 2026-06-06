import XCTest
@testable import Connections

final class ShareExperienceSessionManagerTests: XCTestCase {

    func testPreviewSessionUsesFixedPreviewExperiences() {
        let manager = ShareExperienceSessionManager(previewExperiences: PremiumPreviewDeck.shareExperiences())

        XCTAssertTrue(manager.isPreview)
        XCTAssertEqual(manager.currentExperience?.id, PremiumPreviewFeature.shareExperience.previewIDs.first)
    }

    func testPreviewAdvancesThroughFixedExperiencesAndCompletes() {
        let manager = ShareExperienceSessionManager(previewExperiences: PremiumPreviewDeck.shareExperiences())
        var seenIDs = [manager.currentExperience?.id].compactMap { $0 }

        for _ in 1..<PremiumPreviewDeck.count {
            manager.advance()
            seenIDs.append(contentsOf: [manager.currentExperience?.id].compactMap { $0 })
        }

        XCTAssertEqual(seenIDs, PremiumPreviewFeature.shareExperience.previewIDs)
        XCTAssertFalse(manager.isComplete)

        manager.advance()

        XCTAssertTrue(manager.isComplete)
    }

    func testPreviewRestartReplaysSameExperiences() {
        let manager = ShareExperienceSessionManager(previewExperiences: PremiumPreviewDeck.shareExperiences())

        for _ in 0..<PremiumPreviewDeck.count {
            manager.advance()
        }
        XCTAssertTrue(manager.isComplete)

        manager.restart()

        XCTAssertFalse(manager.isComplete)
        XCTAssertEqual(manager.currentExperience?.id, PremiumPreviewFeature.shareExperience.previewIDs.first)

        manager.advance()

        XCTAssertEqual(manager.currentExperience?.id, PremiumPreviewFeature.shareExperience.previewIDs[1])
    }

    func testPreviewIgnoresIntensityFilterChanges() {
        let manager = ShareExperienceSessionManager(previewExperiences: PremiumPreviewDeck.shareExperiences())

        manager.setIntensity(.unfiltered)

        XCTAssertNil(manager.selectedIntensity)
        XCTAssertEqual(manager.currentExperience?.id, PremiumPreviewFeature.shareExperience.previewIDs.first)
    }

    func testRandomAllModeKeepsNeutralBackground() {
        let manager = ShareExperienceSessionManager()

        XCTAssertNil(manager.selectedIntensity)
        XCTAssertNil(manager.backgroundIntensity)
    }
}
