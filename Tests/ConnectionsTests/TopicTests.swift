import XCTest
@testable import Connections

final class TopicTests: XCTestCase {

    func testFallInLoveOnlyAvailableForCouples() {
        for mode in Mode.allCases {
            let topics = Topic.availableFor(mode: mode)
            if mode == .couples {
                XCTAssertTrue(topics.contains(.fallInLove), "fallInLove should be available for couples")
            } else {
                XCTAssertFalse(topics.contains(.fallInLove), "fallInLove should not be available for \(mode.rawValue)")
            }
        }
    }

    func testAllNonGuidedTopicsAvailableForAllModes() {
        let nonGuidedTopics = Topic.allCases.filter { !$0.isGuidedFlow }
        for mode in Mode.allCases {
            let topics = Topic.availableFor(mode: mode)
            for topic in nonGuidedTopics {
                XCTAssertTrue(topics.contains(topic), "\(topic.displayName) should be available for \(mode.rawValue)")
            }
        }
    }

    func testAvailableForReturnsSameCountForAllModesExceptCouples() {
        // Every mode gets all non-guided topics; couples gets one extra (fallInLove).
        let nonCouplesModes = Mode.allCases.filter { $0 != .couples }
        let couplesCount = Topic.availableFor(mode: .couples).count
        for mode in nonCouplesModes {
            let count = Topic.availableFor(mode: mode).count
            XCTAssertEqual(count, couplesCount - 1, "\(mode.rawValue) should have one fewer topic than couples")
        }
    }
}
