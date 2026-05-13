import XCTest
@testable import Connections

final class PromptBankTests: XCTestCase {

    private let bank = PromptBank.shared

    // MARK: - Count

    func testCountIs598() {
        XCTAssertEqual(bank.prompts.count, 598)
    }

    // MARK: - Stable IDs

    func testAllIDsAreNonEmpty() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.id.isEmpty, "Prompt has empty id")
        }
    }

    func testNoDuplicatePromptIDs() {
        let ids = bank.prompts.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate prompt IDs found")
    }

    func testFirstPromptHasStableID() {
        XCTAssertEqual(bank.prompts.first?.id, "p_couples_light_warmUp_dailyLife_001")
    }

    func testAllFollowUpIDsAreNonEmpty() {
        for prompt in bank.prompts {
            for fu in prompt.followUps {
                XCTAssertFalse(fu.id.isEmpty, "Prompt '\(prompt.id)' has follow-up with empty id")
            }
        }
    }

    func testNoDuplicateFollowUpIDs() {
        let ids = bank.prompts.flatMap { $0.followUps.map(\.id) }
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate follow-up IDs found")
    }

    func testFollowUpIDsReferenceParentPrompt() {
        for prompt in bank.prompts {
            for fu in prompt.followUps {
                XCTAssertTrue(fu.id.hasPrefix(prompt.id),
                              "FollowUp '\(fu.id)' does not start with parent '\(prompt.id)'")
            }
        }
    }

    // MARK: - Content

    func testAllPromptsHaveNonEmptyText() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.text.isEmpty, "Prompt '\(prompt.id)' has empty text")
        }
    }

    func testAllPromptsHaveAtLeastOneFollowUp() {
        for prompt in bank.prompts {
            XCTAssertFalse(prompt.followUps.isEmpty, "Prompt '\(prompt.id)' has no follow-ups")
        }
    }

    // MARK: - Modes

    func testAllFourModesAreRepresented() {
        let modes = Set(bank.prompts.map(\.mode))
        for mode in [Mode.couples, .friends, .family, .soloReflection] {
            XCTAssertTrue(modes.contains(mode), "\(mode) has no prompts")
        }
    }

    // MARK: - Behavior (retained from original tests)

    func testNoTopicsWithZeroPromptsAreReturned() {
        for mode in Mode.allCases {
            for intensity in Intensity.allCases {
                let topics = bank.availableTopics(for: mode, intensity: intensity)
                let searchIntensities: [Intensity] = intensity == .mixed ? Intensity.concrete : [intensity]
                for topic in topics where !topic.isGuidedFlow {
                    let count = bank.prompts.filter {
                        $0.mode == mode && searchIntensities.contains($0.intensity) && $0.topic == topic
                    }.count
                    XCTAssertGreaterThan(
                        count, 0,
                        "\(topic.displayName) has 0 prompts for \(mode.rawValue)/\(intensity.rawValue) but appears in availableTopics"
                    )
                }
            }
        }
    }

    func testGuidedFlowTopicsAppearForCouplesRegardlessOfIntensity() {
        for intensity in Intensity.allCases {
            let topics = bank.availableTopics(for: .couples, intensity: intensity)
            XCTAssertTrue(
                topics.contains(.fallInLove),
                "fallInLove should appear for couples with intensity \(intensity.rawValue)"
            )
        }
    }

    func testGuidedFlowTopicsDoNotAppearForUnsupportedModes() {
        let unsupportedModes = Mode.allCases.filter { $0 != .couples && $0 != .friends }
        for mode in unsupportedModes {
            for intensity in Intensity.allCases {
                let topics = bank.availableTopics(for: mode, intensity: intensity)
                XCTAssertFalse(
                    topics.contains(.fallInLove),
                    "fallInLove should not appear for \(mode.rawValue)"
                )
            }
        }
    }

    // MARK: - JSON Loader Fallback

    func testFallsBackToEnglishForPrompts() {
        let result = JSONBankLoader.load(bankName: "prompts", preferredLocale: "fr")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en", "Should have fallen back to English")
    }
}
