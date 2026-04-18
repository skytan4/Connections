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
}
