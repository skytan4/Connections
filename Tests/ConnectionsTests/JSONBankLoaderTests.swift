import XCTest
@testable import Connections

final class JSONBankLoaderTests: XCTestCase {

    // MARK: - Locale Candidate Generation

    func testEnUsProducesEnUsAndEn() {
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "en-US"), ["en-US", "en"])
    }

    func testFrFrProducesFrFrFrAndEn() {
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "fr-FR"), ["fr-FR", "fr", "en"])
    }

    func testEnProducesOnlyEn() {
        // Language-only English: no duplicate, no extra fallback needed
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "en"), ["en"])
    }

    func testJaProducesJaAndEn() {
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "ja"), ["ja", "en"])
    }

    func testZhHansProducesZhHansZhAndEn() {
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "zh-Hans"), ["zh-Hans", "zh", "en"])
    }

    func testPlPlProducesPlPlPlAndEn() {
        XCTAssertEqual(JSONBankLoader.localeCandidates(preferredLocale: "pl-PL"), ["pl-PL", "pl", "en"])
    }

    // MARK: - Fallback Behavior (exercises real bundle files)

    func testEnglishFileLoadsDirectly() {
        // "en" → fall_in_love_en.json found on first try
        let result = JSONBankLoader.load(bankName: "fall_in_love", preferredLocale: "en")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en")
    }

    func testFallsBackToLanguageCodeWhenFullLocaleFileNotFound() {
        // "en-US" → fall_in_love_en-US.json absent → fall_in_love_en.json found via language code
        let result = JSONBankLoader.load(bankName: "fall_in_love", preferredLocale: "en-US")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en", "Should have fallen back to language-code 'en'")
    }

    func testFallsBackToEnglishWhenPreferredLocaleFileNotFound() {
        // "zz" → fall_in_love_zz.json absent → fall_in_love_en.json found via English fallback
        let result = JSONBankLoader.load(bankName: "fall_in_love", preferredLocale: "zz")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en", "Should have fallen back to English")
    }

    func testFallsBackToEnglishForShareExperience() {
        let result = JSONBankLoader.load(bankName: "share_experience", preferredLocale: "zz")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "en")
    }
}
