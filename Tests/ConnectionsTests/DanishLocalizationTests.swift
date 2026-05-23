//
//  DanishLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class DanishLocalizationTests: XCTestCase {

    private static let locale = "da"

    private func skipIfBankMissing(_ bankName: String) throws {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: Self.locale)
        guard result.locale == Self.locale else {
            throw XCTSkip("\(bankName)_\(Self.locale).json not yet available — skipping until Danish translation is committed")
        }
    }

    private func skipIfDanishXcstringsMissing() throws {
        let xcstringsURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Connections/Localizable.xcstrings")
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else { return }
        let hasDanish = strings.values
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["localizations"] as? [String: Any] }
            .flatMap { $0.keys }
            .contains(Self.locale)
        guard hasDanish else {
            throw XCTSkip("No Danish entries in Localizable.xcstrings yet — skipping until Danish UI strings are added")
        }
    }

    // MARK: - Localizable.xcstrings (always-run)

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoDanishEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: Self.locale)
    }

    // MARK: - Localizable.xcstrings (skip until Danish UI strings are added)

    func testAllTranslatableKeysHaveDanishValues() throws {
        try skipIfDanishXcstringsMissing()
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: Self.locale)
    }

    func testNoDanishValuesAreEmpty() throws {
        try skipIfDanishXcstringsMissing()
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: Self.locale)
    }

    func testFormatPlaceholderParityBetweenEnglishAndDanish() throws {
        try skipIfDanishXcstringsMissing()
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: Self.locale)
    }

    // MARK: - JSON bank loading

    func testDanishFallInLoveLoads() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testDanishLifeStoryLoads() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testDanishShareExperienceLoads() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    func testDanishPromptsLoads() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: Self.locale)
    }

    // MARK: - fall_in_love parity

    func testFallInLoveDanishCountMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveDanishIDsMatchEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveDanishMetadataMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, daP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(daP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(daP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(daP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveDanishNoEmptyText() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - life_story parity

    func testLifeStoryDanishCountMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryDanishIDsMatchEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryDanishMetadataMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, daP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(daP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(daP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryDanishNoEmptyText() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryDanishFollowUpsNonEmpty() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    // MARK: - share_experience parity

    func testShareExperienceDanishCountMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceDanishIDsMatchEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceDanishMetadataMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, daE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(daE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(daE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceDanishNoEmptyFullText() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    // MARK: - prompts parity

    func testPromptsDanishCountMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsDanishIDsMatchEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsDanishMetadataMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: Self.locale) { enP, daP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(daP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(daP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(daP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(daP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsDanishNoEmptyText() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsDanishFollowUpParityWithEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Translation regression

    func testPromptsDaTextDiffersFromEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Schema metadata

    func testAllDanishJsonFilesHaveSchemaVersion1() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: Self.locale) }
    }

    func testAllDanishJsonFilesHaveLanguageDa() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertLanguageField(bankName: bank, locale: Self.locale) }
    }
}
