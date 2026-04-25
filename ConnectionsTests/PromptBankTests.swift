import XCTest
@testable import Connections

final class PromptBankTests: XCTestCase {

    // Verify that availableTopics never returns a non-guided topic that has
    // zero prompts for the requested mode + intensity combination.
    func testNoTopicsWithZeroPromptsAreReturned() {
        for mode in Mode.allCases {
            for intensity in Intensity.allCases {
                let topics = PromptBank.shared.availableTopics(for: mode, intensity: intensity)
                let searchIntensities: [Intensity] = intensity == .mixed ? Intensity.concrete : [intensity]
                for topic in topics where !topic.isGuidedFlow {
                    let count = PromptBank.shared.prompts.filter {
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

    // Guided-flow topics (fallInLove) must always appear for couples
    // regardless of intensity, since they don't use the regular prompt bank.
    func testGuidedFlowTopicsAppearForCouplesRegardlessOfIntensity() {
        for intensity in Intensity.allCases {
            let topics = PromptBank.shared.availableTopics(for: .couples, intensity: intensity)
            XCTAssertTrue(
                topics.contains(.fallInLove),
                "fallInLove should appear for couples with intensity \(intensity.rawValue)"
            )
        }
    }

    // Guided-flow topics must not appear for modes that don't support them.
    func testGuidedFlowTopicsDoNotAppearForUnsupportedModes() {
        let unsupportedModes = Mode.allCases.filter { $0 != .couples && $0 != .friends }
        for mode in unsupportedModes {
            for intensity in Intensity.allCases {
                let topics = PromptBank.shared.availableTopics(for: mode, intensity: intensity)
                XCTAssertFalse(
                    topics.contains(.fallInLove),
                    "fallInLove should not appear for \(mode.rawValue)"
                )
            }
        }
    }
}
