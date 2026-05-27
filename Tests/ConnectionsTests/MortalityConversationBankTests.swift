import XCTest
@testable import Connections

final class MortalityConversationBankTests: XCTestCase {

    private let bank = MortalityConversationBank.shared

    func testCountIs255() {
        XCTAssertEqual(bank.count, 255)
    }

    func testAllIDsAreNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.id.isEmpty, "Prompt has empty id")
        }
    }

    func testNoDuplicateIDs() {
        let ids = bank.prompts.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate prompt IDs found")
    }

    func testAllTopicsAreRepresented() {
        let topics = Set(bank.prompts.map(\.topic))
        XCTAssertEqual(topics, Set(MortalityConversationTopic.allCases))
    }

    func testEveryTopicHasAtLeastTenPrompts() {
        for topic in MortalityConversationTopic.allCases {
            let count = bank.prompts.filter { $0.topic == topic }.count
            XCTAssertGreaterThanOrEqual(count, 10, "\(topic.rawValue) has fewer than 10 prompts")
        }
    }

    func testAllPromptsHaveNonEmptyText() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.text.isEmpty, "Prompt '\(prompt.id)' has empty text")
        }
    }

    func testFilteringByTopic() {
        let prompts = bank.prompts(in: [.legacy])
        XCTAssertFalse(prompts.isEmpty)
        XCTAssertTrue(prompts.allSatisfy { $0.topic == .legacy })
    }
}
