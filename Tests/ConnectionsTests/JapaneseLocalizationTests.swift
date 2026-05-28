//
//  JapaneseLocalizationTests.swift
//  ConnectionsTests
//
//  Tests are pre-xcstrings safe: each test that depends on a Japanese
//  JSON bank calls skipIfBankMissing(_:) first. If the file does not
//  exist yet, the test is marked Skipped (not Failed).
//  Once the Japanese xcstrings UI strings are added, all xcstring tests
//  will also run.
//

import XCTest
@testable import Connections

final class JapaneseLocalizationTests: XCTestCase {

    private static let locale = "ja"

    // MARK: - Skip guards

    /// Skip the calling test if <bankName>_ja.json is not in the bundle yet.
    /// JSONBankLoader falls back to "en" when the Japanese file is absent,
    /// so a locale mismatch is the reliable signal.
    private func skipIfBankMissing(_ bankName: String) throws {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: Self.locale)
        guard result.locale == Self.locale else {
            throw XCTSkip("\(bankName)_\(Self.locale).json not yet available — skipping until Japanese translation is committed")
        }
    }

    /// Skip the calling test if no Japanese entries exist in Localizable.xcstrings yet.
    private func skipIfJapaneseXcstringsMissing() throws {
        let xcstringsURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()   // ConnectionsTests/
            .deletingLastPathComponent()   // Tests/
            .deletingLastPathComponent()   // project root
            .appendingPathComponent("Connections/Localizable.xcstrings")
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else { return }
        let hasJapanese = strings.values
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["localizations"] as? [String: Any] }
            .flatMap { $0.keys }
            .contains(Self.locale)
        guard hasJapanese else {
            throw XCTSkip("No Japanese entries in Localizable.xcstrings yet — skipping until Japanese UI strings are added")
        }
    }

    // MARK: - Localizable.xcstrings (always-run — do not require Japanese to be present)

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoJapaneseEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: Self.locale)
    }

    // MARK: - Localizable.xcstrings (skip until Japanese UI strings are added)

    func testAllTranslatableKeysHaveJapaneseValues() throws {
        try skipIfJapaneseXcstringsMissing()
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: Self.locale)
    }

    func testNoJapaneseValuesAreEmpty() throws {
        try skipIfJapaneseXcstringsMissing()
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: Self.locale)
    }

    func testFormatPlaceholderParityBetweenEnglishAndJapanese() throws {
        try skipIfJapaneseXcstringsMissing()
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: Self.locale)
    }

    // MARK: - JSON bank loading

    func testJapaneseFallInLoveLoads() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testJapaneseLifeStoryLoads() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testJapaneseShareExperienceLoads() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    func testJapanesePromptsLoads() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: Self.locale)
    }

    // MARK: - fall_in_love parity

    func testFallInLoveJapaneseCountMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveJapaneseIDsMatchEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveJapaneseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, jaP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(jaP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(jaP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(jaP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveJapaneseNoEmptyText() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - life_story parity

    func testLifeStoryJapaneseCountMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryJapaneseIDsMatchEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryJapaneseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, jaP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(jaP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(jaP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryJapaneseNoEmptyText() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryJapaneseFollowUpsNonEmpty() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    // MARK: - share_experience parity

    func testShareExperienceJapaneseCountMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceJapaneseIDsMatchEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceJapaneseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, jaE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(jaE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(jaE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceJapaneseNoEmptyFullText() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    // MARK: - prompts parity

    func testPromptsJapaneseCountMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsJapaneseIDsMatchEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsJapaneseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: Self.locale) { enP, jaP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(jaP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(jaP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(jaP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(jaP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsJapaneseNoEmptyText() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsJapaneseFollowUpParityWithEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Translation regression

    func testPromptsJaTextDiffersFromEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Schema metadata

    func testAllJapaneseJsonFilesHaveSchemaVersion1() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: Self.locale) }
    }

    func testAllJapaneseJsonFilesHaveLanguageJa() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertLanguageField(bankName: bank, locale: Self.locale) }
    }
}
