import XCTest
@testable import Connections

final class SessionManagerPremiumAccessTests: XCTestCase {

    func testStandardPremiumPredicateCoversAllPaidPromptKinds() {
        let prompts = PromptBank.shared.prompts

        XCTAssertFalse(prompts.isEmpty)
        XCTAssertTrue(prompts.contains { $0.intensity == .unfiltered })
        XCTAssertTrue(prompts.contains { $0.topic == .sex })
        XCTAssertTrue(prompts.contains { $0.topic == .intimacy })

        for prompt in prompts {
            if prompt.intensity == .unfiltered || prompt.topic == .sex || prompt.topic == .intimacy {
                XCTAssertTrue(prompt.requiresPremiumAccess, "\(prompt.id) should require Full Access")
            }
        }
    }

    func testStandardPromptBankDoesNotContainGuidedFlowBanks() {
        for prompt in PromptBank.shared.prompts {
            XCTAssertFalse(prompt.id.hasPrefix("fil_"), "Fall in Love prompts must not appear in standard sessions")
            XCTAssertFalse(prompt.id.hasPrefix("mc_"), "Mortality prompts must not appear in standard sessions")
            XCTAssertFalse(prompt.id.hasPrefix("se"), "Share Experiences prompts must not appear in standard sessions")
            XCTAssertFalse(prompt.id.hasPrefix("ls_"), "Life Story prompts must not appear in standard sessions")
            XCTAssertNotEqual(prompt.topic, .fallInLove)
        }
    }

    func testFreeMixedLongAllTopicsDoesNotDrawPremiumPrompts() {
        for mode in Mode.allCases {
            let session = SessionManager()
            session.selectedMode = mode
            session.selectedIntensity = .mixed
            session.selectedSessionLength = .long
            session.selectedTopic = nil
            session.mixedIntensities = [.light, .honest]
            session.canAccessPremiumPrompts = false

            session.startSession()

            var seenPrompts = 0
            while let prompt = session.currentPrompt {
                XCTAssertFalse(prompt.requiresPremiumAccess, "Free Mixed sessions should not draw premium prompt \(prompt.id)")
                XCTAssertNotEqual(prompt.topic, .intimacy)
                XCTAssertNotEqual(prompt.topic, .sex)
                XCTAssertNotEqual(prompt.topic, .fallInLove)
                XCTAssertNotEqual(prompt.intensity, .unfiltered)
                seenPrompts += 1
                session.continuePrompt()
            }

            XCTAssertEqual(seenPrompts, SessionLength.long.rawValue, "\(mode.rawValue) should complete a free 20-prompt Mixed session")
            XCTAssertTrue(session.isSessionComplete)
        }
    }

    func testFreeHonestAllTopicsDoesNotDrawPremiumTopicPrompts() {
        let session = SessionManager()
        session.selectedMode = .couples
        session.selectedIntensity = .honest
        session.selectedSessionLength = .long
        session.selectedTopic = nil
        session.canAccessPremiumPrompts = false

        session.startSession()

        while let prompt = session.currentPrompt {
            XCTAssertFalse(prompt.requiresPremiumAccess, "Free Honest sessions should not draw premium prompt \(prompt.id)")
            XCTAssertNotEqual(prompt.topic, .intimacy)
            XCTAssertNotEqual(prompt.topic, .sex)
            session.continuePrompt()
        }

        XCTAssertTrue(session.isSessionComplete)
    }

    func testFreeSelectedPremiumTopicsDoNotStartStandardSession() {
        for topic in [Topic.intimacy, .sex] {
            let session = SessionManager()
            session.selectedMode = .couples
            session.selectedIntensity = .honest
            session.selectedSessionLength = .short
            session.selectedTopic = topic
            session.canAccessPremiumPrompts = false

            session.startSession()

            XCTAssertFalse(session.isSessionActive)
            XCTAssertNil(session.currentPrompt)
        }
    }

    func testPremiumSelectedPremiumTopicsCanDrawMatchingPrompts() {
        for topic in [Topic.intimacy, .sex] {
            let session = SessionManager()
            session.selectedMode = .couples
            session.selectedIntensity = .honest
            session.selectedSessionLength = .short
            session.selectedTopic = topic
            session.canAccessPremiumPrompts = true

            session.startSession()

            XCTAssertTrue(session.isSessionActive)
            XCTAssertEqual(session.currentPrompt?.topic, topic)
        }
    }
}
