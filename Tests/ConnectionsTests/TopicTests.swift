import XCTest
@testable import Connections

final class TopicTests: XCTestCase {

    func testFallInLoveAvailableForCouplesAndFriends() {
        for mode in Mode.allCases {
            let topics = Topic.availableFor(mode: mode)
            if mode == .couples || mode == .friends {
                XCTAssertTrue(topics.contains(.fallInLove), "fallInLove should be available for \(mode.rawValue)")
            } else {
                XCTAssertFalse(topics.contains(.fallInLove), "fallInLove should not be available for \(mode.rawValue)")
            }
        }
    }

    func testParentingOnlyAvailableForCouples() {
        for mode in Mode.allCases {
            let topics = Topic.availableFor(mode: mode)
            if mode == .couples {
                XCTAssertTrue(topics.contains(.parenting), "parenting should be available for couples")
            } else {
                XCTAssertFalse(topics.contains(.parenting), "parenting should not be available for \(mode.rawValue)")
            }
        }
    }

    func testUniversalTopicsAvailableForAllModes() {
        // Topics that are not mode-restricted should be available everywhere.
        let modeRestricted: Set<Topic> = [.fallInLove, .parenting]
        let universalTopics = Topic.allCases.filter { !modeRestricted.contains($0) }
        for mode in Mode.allCases {
            let topics = Topic.availableFor(mode: mode)
            for topic in universalTopics {
                XCTAssertTrue(topics.contains(topic), "\(topic.displayName) should be available for \(mode.rawValue)")
            }
        }
    }

    func testCouplesHasMostTopics() {
        let couplesCount = Topic.availableFor(mode: .couples).count
        for mode in Mode.allCases where mode != .couples {
            let count = Topic.availableFor(mode: mode).count
            XCTAssertLessThan(count, couplesCount, "\(mode.rawValue) should have fewer topics than couples")
        }
    }
}
