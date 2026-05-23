//
//  GermanLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class GermanLocalizationTests: XCTestCase {

    private static let locale = "de"

    // MARK: - Skip guards

    private func skipIfBankMissing(_ bankName: String) throws {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: Self.locale)
        guard result.locale == Self.locale else {
            throw XCTSkip("\(bankName)_\(Self.locale).json not yet available — skipping until German translation is committed")
        }
    }

    private func skipIfGermanXcstringsMissing() throws {
        let xcstringsURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()   // ConnectionsTests/
            .deletingLastPathComponent()   // Tests/
            .deletingLastPathComponent()   // project root
            .appendingPathComponent("Connections/Localizable.xcstrings")
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else { return }
        let hasGerman = strings.values
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["localizations"] as? [String: Any] }
            .flatMap { $0.keys }
            .contains(Self.locale)
        guard hasGerman else {
            throw XCTSkip("No German entries in Localizable.xcstrings yet — skipping until German UI strings are added")
        }
    }

    // MARK: - Localizable.xcstrings (always-run)

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoGermanEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: Self.locale)
    }

    // MARK: - Localizable.xcstrings (skip until German UI strings are added)

    func testAllTranslatableKeysHaveGermanValues() throws {
        try skipIfGermanXcstringsMissing()
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: Self.locale)
    }

    func testNoGermanValuesAreEmpty() throws {
        try skipIfGermanXcstringsMissing()
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: Self.locale)
    }

    func testFormatPlaceholderParityBetweenEnglishAndGerman() throws {
        try skipIfGermanXcstringsMissing()
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: Self.locale)
    }

    // MARK: - JSON bank loading

    func testGermanFallInLoveLoads() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testGermanLifeStoryLoads() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testGermanShareExperienceLoads() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    func testGermanPromptsLoads() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: Self.locale)
    }

    // MARK: - fall_in_love parity

    func testFallInLoveGermanCountMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveGermanIDsMatchEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveGermanMetadataMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, deP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(deP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(deP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(deP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveGermanNoEmptyText() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - life_story parity

    func testLifeStoryGermanCountMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryGermanIDsMatchEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryGermanMetadataMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, deP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(deP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(deP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryGermanNoEmptyText() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryGermanFollowUpsNonEmpty() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    // MARK: - share_experience parity

    func testShareExperienceGermanCountMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceGermanIDsMatchEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceGermanMetadataMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, deE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(deE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(deE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceGermanNoEmptyFullText() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    // MARK: - prompts parity

    func testPromptsGermanCountMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsGermanIDsMatchEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsGermanMetadataMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: Self.locale) { enP, deP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(deP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(deP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(deP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(deP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsGermanNoEmptyText() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsGermanFollowUpParityWithEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Translation regression

    func testPromptsDeTextDiffersFromEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Schema metadata

    func testAllGermanJsonFilesHaveSchemaVersion1() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: Self.locale) }
    }

    func testAllGermanJsonFilesHaveLanguageDe() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertLanguageField(bankName: bank, locale: Self.locale) }
    }
}
