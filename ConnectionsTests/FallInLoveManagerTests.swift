import Testing
@testable import Connections

private let progressKey = "layers_fallInLove_progress"

@Suite("FallInLoveManager", .serialized)
struct FallInLoveManagerTests {

    init() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    @Test func advanceIncrementsIndex() {
        let manager = FallInLoveManager()
        #expect(manager.currentIndex == 0)
        manager.advance()
        #expect(manager.currentIndex == 1)
    }

    @Test func advanceDoesNotIncrementPastEnd() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<total { manager.advance() }
        #expect(manager.currentIndex == total - 1)
    }

    @Test func isCompleteFlipsAtLastPrompt() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<(total - 1) { manager.advance() }
        #expect(!manager.isComplete)
        manager.advance()
        #expect(manager.isComplete)
    }

    @Test func goBackDecrementsIndex() {
        UserDefaults.standard.set(3, forKey: progressKey)
        let manager = FallInLoveManager()
        #expect(manager.currentIndex == 3)
        manager.goBack()
        #expect(manager.currentIndex == 2)
    }

    @Test func goBackClampsAtZero() {
        let manager = FallInLoveManager()
        manager.goBack()
        #expect(manager.currentIndex == 0)
    }

    @Test func resetClearsIndexAndCompleteFlag() {
        UserDefaults.standard.set(5, forKey: progressKey)
        let manager = FallInLoveManager()
        manager.reset()
        #expect(manager.currentIndex == 0)
        #expect(!manager.isComplete)
    }

    @Test func resetAfterCompletionAllowsRestart() {
        let manager = FallInLoveManager()
        let total = manager.totalPrompts
        for _ in 0..<total { manager.advance() }
        #expect(manager.isComplete)
        manager.reset()
        #expect(!manager.isComplete)
        #expect(manager.currentIndex == 0)
    }
}
