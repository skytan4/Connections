import XCTest
@testable import Connections

final class MortalityConversationSessionManagerTests: XCTestCase {

    func testBuildsRequestedLengthFromSelectedTopics() {
        let manager = MortalityConversationSessionManager(length: .medium, topics: [.legacy])
        XCTAssertEqual(manager.totalPrompts, 10)
        XCTAssertTrue(manager.prompts.allSatisfy { $0.topic == .legacy })
    }

    func testLongSessionCanUseTwoTopicsWithoutRepeats() {
        let manager = MortalityConversationSessionManager(length: .long, topics: [.legacy, .ordinaryMoments])
        XCTAssertEqual(manager.totalPrompts, 20)
        XCTAssertEqual(manager.prompts.count, Set(manager.prompts.map(\.id)).count)
    }

    func testAdvanceCompletesSession() {
        let manager = MortalityConversationSessionManager(length: .short, topics: [.legacy])
        XCTAssertFalse(manager.isComplete)

        for _ in 0..<manager.totalPrompts {
            manager.advance()
        }

        XCTAssertTrue(manager.isComplete)
    }

    func testRestartKeepsSelectionsAndBuildsFreshSession() {
        let manager = MortalityConversationSessionManager(length: .short, topics: [.legacy])
        for _ in 0..<manager.totalPrompts {
            manager.advance()
        }
        XCTAssertTrue(manager.isComplete)

        manager.restart()

        XCTAssertEqual(manager.totalPrompts, 5)
        XCTAssertFalse(manager.isComplete)
        XCTAssertTrue(manager.prompts.allSatisfy { $0.topic == .legacy })
    }

    func testPreviewSessionUsesFixedPreviewPrompts() {
        let manager = MortalityConversationSessionManager()

        XCTAssertTrue(manager.isPreview)
        XCTAssertEqual(manager.totalPrompts, PremiumPreviewDeck.count)
        XCTAssertEqual(manager.prompts.map(\.id), PremiumPreviewFeature.mortalityConversations.previewIDs)
    }

    func testPreviewRestartReplaysSamePrompts() {
        let manager = MortalityConversationSessionManager()
        let originalIDs = manager.prompts.map(\.id)

        manager.restart()

        XCTAssertEqual(manager.prompts.map(\.id), originalIDs)
    }
}
