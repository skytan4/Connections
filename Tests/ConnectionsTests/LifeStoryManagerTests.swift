import XCTest
@testable import Connections

final class LifeStoryManagerTests: XCTestCase {

    private let storageKey = "layers_life_story_progress"

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        super.tearDown()
    }

    func testPreviewSessionUsesFixedPreviewPrompts() {
        let manager = LifeStoryManager(previewPrompts: PremiumPreviewDeck.lifeStoryPrompts())

        XCTAssertTrue(manager.isPreview)
        XCTAssertEqual(manager.totalPrompts, PremiumPreviewDeck.count)
        XCTAssertEqual(manager.currentPrompt?.id, PremiumPreviewFeature.lifeStory.previewIDs.first)
    }

    func testPreviewResetReplaysSamePromptsAndDoesNotPersistProgress() {
        UserDefaults.standard.set(12, forKey: storageKey)
        let manager = LifeStoryManager(previewPrompts: PremiumPreviewDeck.lifeStoryPrompts())

        manager.advance()
        XCTAssertEqual(manager.currentPrompt?.id, PremiumPreviewFeature.lifeStory.previewIDs[1])

        manager.reset()

        XCTAssertEqual(manager.currentPrompt?.id, PremiumPreviewFeature.lifeStory.previewIDs.first)
        XCTAssertFalse(manager.isComplete)
        XCTAssertEqual(LifeStoryManager().currentIndex, 12)
    }

    func testPreviewCompletesAfterFixedPreviewCount() {
        let manager = LifeStoryManager(previewPrompts: PremiumPreviewDeck.lifeStoryPrompts())

        for _ in 0..<PremiumPreviewDeck.count {
            manager.advance()
        }

        XCTAssertTrue(manager.isComplete)
    }
}
