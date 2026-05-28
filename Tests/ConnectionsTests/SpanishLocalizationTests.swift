//
//  SpanishLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class SpanishLocalizationTests: XCTestCase {

    // MARK: - Bundle

    func testBundleContainsSpanishLocalization() {
        XCTAssertTrue(Bundle.main.localizations.contains("es"),
                      "App bundle is missing 'es' in knownRegions")
    }

    // MARK: - Localizable.xcstrings

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testAllTranslatableKeysHaveSpanishValues() {
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: "es")
    }

    func testNoSpanishValuesAreEmpty() {
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: "es")
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoSpanishEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: "es")
    }

    func testFormatPlaceholderParityBetweenEnglishAndSpanish() {
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: "es")
    }

    // MARK: - Spanish JSON Loading

    func testSpanishFallInLoveLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: "es")
    }

    func testSpanishLifeStoryLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: "es")
    }

    func testSpanishShareExperienceLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: "es")
    }

    func testSpanishPromptsLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: "es")
    }

    // MARK: - fall_in_love parity

    func testFallInLoveSpanishCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: "es")
    }

    func testFallInLoveSpanishIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: "es")
    }

    func testFallInLoveSpanishMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: "es") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(esP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveSpanishNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: "es")
    }

    // MARK: - life_story parity

    func testLifeStorySpanishCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: "es")
    }

    func testLifeStorySpanishIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: "es")
    }

    func testLifeStorySpanishMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: "es") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(esP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStorySpanishNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: "es")
    }

    func testLifeStorySpanishFollowUpsNonEmpty() {
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: "es")
    }

    // MARK: - share_experience parity

    func testShareExperienceSpanishCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: "es")
    }

    func testShareExperienceSpanishIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: "es")
    }

    func testShareExperienceSpanishMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: "es") { enE, esE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(esE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceSpanishNoEmptyFullText() {
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: "es")
    }

    // MARK: - prompts parity

    func testPromptsSpanishCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: "es")
    }

    func testPromptsSpanishIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: "es")
    }

    func testPromptsSpanishMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: "es") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(esP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(esP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsSpanishNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: "es")
    }

    func testPromptsSpanishFollowUpParityWithEnglish() {
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: "es")
    }

    // MARK: - Translation regression

    func testPromptsEsTextDiffersFromEnglish() {
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: "es")
    }

    // MARK: - Schema metadata

    func testAllSpanishJsonFilesHaveSchemaVersion1() {
        for bank in ["fall_in_love", "life_story", "share_experience", "prompts"] {
            LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: "es")
        }
    }

    func testAllSpanishJsonFilesHaveLanguageEs() {
        for bank in ["fall_in_love", "life_story", "share_experience", "prompts"] {
            LocalizationTestHelper.assertLanguageField(bankName: bank, locale: "es")
        }
    }
}
