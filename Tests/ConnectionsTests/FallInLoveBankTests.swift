import XCTest
@testable import Connections

final class FallInLoveBankTests: XCTestCase {

    func testCountIs36() {
        XCTAssertEqual(FallInLoveBank.shared.count, 36)
    }

    func testPromptAtZeroIsNotNil() {
        XCTAssertNotNil(FallInLoveBank.shared.prompt(at: 0))
    }

    func testPromptAtLastIndexIsNotNil() {
        let last = FallInLoveBank.shared.count - 1
        XCTAssertNotNil(FallInLoveBank.shared.prompt(at: last))
    }

    func testPromptAtNegativeIndexReturnsNil() {
        XCTAssertNil(FallInLoveBank.shared.prompt(at: -1))
    }

    func testPromptAtCountReturnsNil() {
        XCTAssertNil(FallInLoveBank.shared.prompt(at: FallInLoveBank.shared.count))
    }

    func testAllPromptsHaveNonEmptyText() {
        for index in 0..<FallInLoveBank.shared.count {
            let prompt = FallInLoveBank.shared.prompt(at: index)
            XCTAssertFalse(prompt?.text.isEmpty ?? true, "Prompt at index \(index) has empty text")
        }
    }

    // MARK: - Stable ID Tests

    func testAllPromptsHaveNonEmptyIDs() {
        for index in 0..<FallInLoveBank.shared.count {
            let prompt = FallInLoveBank.shared.prompt(at: index)
            XCTAssertFalse(prompt?.id.isEmpty ?? true, "Prompt at index \(index) has empty id")
        }
    }

    func testNoDuplicateIDs() {
        let ids = (0..<FallInLoveBank.shared.count).compactMap { FallInLoveBank.shared.prompt(at: $0)?.id }
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate prompt IDs found")
    }

    func testFirstPromptHasStableID() {
        XCTAssertEqual(FallInLoveBank.shared.prompt(at: 0)?.id, "fil_01")
    }

    // MARK: - Order Validation Tests

    func testOrdersAreContiguousFrom1() {
        let count = FallInLoveBank.shared.count
        let orders = (0..<count).compactMap { FallInLoveBank.shared.prompt(at: $0)?.order }.sorted()
        XCTAssertEqual(orders, Array(1...count), "Prompt orders must be contiguous 1…\(count)")
    }

    func testNoDuplicateOrders() {
        let orders = (0..<FallInLoveBank.shared.count).compactMap { FallInLoveBank.shared.prompt(at: $0)?.order }
        XCTAssertEqual(orders.count, Set(orders).count, "Duplicate prompt orders found")
    }
}
