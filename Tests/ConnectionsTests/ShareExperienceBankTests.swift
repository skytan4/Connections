import XCTest
@testable import Connections

final class ShareExperienceBankTests: XCTestCase {

    private let bank = ShareExperienceBank.shared

    // MARK: - Count

    func testCountIs21() {
        XCTAssertEqual(bank.experiences.count, 21)
    }

    // MARK: - Stable IDs

    func testIDsMatchExpectedSE1ThroughSE21() {
        let ids = Set(bank.experiences.map(\.id))
        let expected = Set((1...21).map { "se\($0)" })
        XCTAssertEqual(ids, expected)
    }

    func testNoDuplicateIDs() {
        let ids = bank.experiences.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate experience IDs found")
    }

    func testFirstExperienceHasStableID() {
        XCTAssertEqual(bank.experiences.first?.id, "se1")
    }

    // MARK: - Content

    func testAllExperiencesHaveNonEmptyFullText() {
        for experience in bank.experiences {
            XCTAssertFalse(experience.fullText.isEmpty, "Experience '\(experience.id)' has empty fullText")
        }
    }

    // MARK: - Filtering

    func testFilteringByIntensityReturnsOnlyThatIntensity() {
        for intensity in Intensity.concrete {
            let results = bank.experiences(intensity: intensity)
            XCTAssertTrue(results.allSatisfy { $0.intensity == intensity },
                          "Filtering by \(intensity) returned experiences with other intensities")
        }
    }

    func testFilteringByTopicReturnsOnlyThatTopic() {
        let topicsInBank = Set(bank.experiences.map(\.topic))
        for topic in topicsInBank {
            let results = bank.experiences(topic: topic)
            XCTAssertFalse(results.isEmpty, "No experiences found for topic \(topic)")
            XCTAssertTrue(results.allSatisfy { $0.topic == topic },
                          "Filtering by \(topic) returned experiences with other topics")
        }
    }

    func testRandomExperienceWithIntensityFilterIsWithinFilter() {
        for intensity in Intensity.concrete {
            if let result = bank.getRandomExperience(intensity: intensity) {
                XCTAssertEqual(result.intensity, intensity)
            }
        }
    }
}
