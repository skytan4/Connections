import XCTest
@testable import Connections

final class LifeStoryBankTests: XCTestCase {

    private let bank = LifeStoryBank.shared

    // MARK: - Count

    func testCountIsExactly50() {
        XCTAssertEqual(bank.prompts.count, 50)
    }

    // MARK: - Stable IDs

    func testAllIDsAreNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.id.isEmpty, "Prompt order=\(prompt.order) has empty id")
        }
    }

    func testNoDuplicateIDs() {
        let ids = bank.prompts.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate prompt IDs found")
    }

    func testFirstPromptHasStableID() {
        XCTAssertEqual(bank.prompts.first?.id, "ls_childhood_001")
    }

    // MARK: - Order

    func testOrderValuesAreContiguous1Through50() {
        let orders = bank.prompts.map(\.order).sorted()
        XCTAssertEqual(orders, Array(1...50))
    }

    func testNoDuplicateOrders() {
        let orders = bank.prompts.map(\.order)
        XCTAssertEqual(orders.count, Set(orders).count, "Duplicate order values found")
    }

    // MARK: - Content

    func testAllPromptTextIsNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.text.isEmpty, "Prompt '\(prompt.id)' has empty text")
        }
    }

    func testAllFollowUp1IsNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.followUp1.isEmpty, "Prompt '\(prompt.id)' has empty followUp1")
        }
    }

    func testAllFollowUp2IsNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.followUp2.isEmpty, "Prompt '\(prompt.id)' has empty followUp2")
        }
    }

    // MARK: - Chapters

    func testAllNineChaptersAreRepresented() {
        let chaptersInBank = Set(bank.prompts.map(\.chapter))
        for chapter in LifeStoryChapter.allCases {
            XCTAssertTrue(chaptersInBank.contains(chapter),
                          "Chapter '\(chapter)' has no prompts in the bank")
        }
    }

    // MARK: - JSON Loader Fallback

    func testFallsBackToEnglishForLifeStory() {
        let result = JSONBankLoader.load(bankName: "life_story", preferredLocale: "zz")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en", "Should have fallen back to English")
    }
}
