import XCTest
@testable import Connections

final class FallInLoveManagerTests: XCTestCase {

    private let progressKey = "layers_fallInLove_progress"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    func testAdvanceIncrementsIndex() {
        let manager = FallInLoveManager()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.advance()
        XCTAssertEqual(manager.currentIndex, 1)
    }

    func testAdvanceDoesNotIncrementPastEnd() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<total { manager.advance() }
        // currentIndex stays at totalPrompts - 1 when isComplete flips
        XCTAssertEqual(manager.currentIndex, total - 1)
    }

    func testIsCompleteFlipsAtLastPrompt() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<(total - 1) { manager.advance() }
        XCTAssertFalse(manager.isComplete)
        manager.advance()
        XCTAssertTrue(manager.isComplete)
    }

    func testGoBackDecrementsIndex() {
        UserDefaults.standard.set(3, forKey: progressKey)
        let manager = FallInLoveManager()
        XCTAssertEqual(manager.currentIndex, 3)
        manager.goBack()
        XCTAssertEqual(manager.currentIndex, 2)
    }

    func testGoBackClampsAtZero() {
        let manager = FallInLoveManager()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.goBack()
        XCTAssertEqual(manager.currentIndex, 0)
    }

    func testResetClearsIndexAndCompleteFlag() {
        UserDefaults.standard.set(5, forKey: progressKey)
        let manager = FallInLoveManager()
        manager.reset()
        XCTAssertEqual(manager.currentIndex, 0)
        XCTAssertFalse(manager.isComplete)
    }

    func testResetAfterCompletionAllowsRestart() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<total { manager.advance() }
        XCTAssertTrue(manager.isComplete)
        manager.reset()
        XCTAssertFalse(manager.isComplete)
        XCTAssertEqual(manager.currentIndex, 0)
    }
}
