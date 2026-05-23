//
//  NorwegianLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class NorwegianLocalizationTests: XCTestCase {

    private static let locale = "nb"

    private func skipIfBankMissing(_ bankName: String) throws {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: Self.locale)
        guard result.locale == Self.locale else {
            throw XCTSkip("\(bankName)_\(Self.locale).json not yet available — skipping until Norwegian translation is committed")
        }
    }

    private func skipIfNorwegianXcstringsMissing() throws {
        let xcstringsURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Connections/Localizable.xcstrings")
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else { return }
        let hasNorwegian = strings.values
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["localizations"] as? [String: Any] }
            .flatMap { $0.keys }
            .contains(Self.locale)
        guard hasNorwegian else {
            throw XCTSkip("No Norwegian entries in Localizable.xcstrings yet — skipping until Norwegian UI strings are added")
        }
    }

    // MARK: - Localizable.xcstrings (always-run)

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoNorwegianEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: Self.locale)
    }

    // MARK: - Localizable.xcstrings (skip until Norwegian UI strings are added)

    func testAllTranslatableKeysHaveNorwegianValues() throws {
        try skipIfNorwegianXcstringsMissing()
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: Self.locale)
    }

    func testNoNorwegianValuesAreEmpty() throws {
        try skipIfNorwegianXcstringsMissing()
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: Self.locale)
    }

    func testFormatPlaceholderParityBetweenEnglishAndNorwegian() throws {
        try skipIfNorwegianXcstringsMissing()
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: Self.locale)
    }

    // MARK: - JSON bank loading

    func testNorwegianFallInLoveLoads() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testNorwegianLifeStoryLoads() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testNorwegianShareExperienceLoads() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    func testNorwegianPromptsLoads() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: Self.locale)
    }

    // MARK: - fall_in_love parity

    func testFallInLoveNorwegianCountMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveNorwegianIDsMatchEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLoveNorwegianMetadataMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, nbP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(nbP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(nbP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(nbP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveNorwegianNoEmptyText() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - life_story parity

    func testLifeStoryNorwegianCountMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryNorwegianIDsMatchEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryNorwegianMetadataMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, nbP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(nbP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(nbP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryNorwegianNoEmptyText() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryNorwegianFollowUpsNonEmpty() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    // MARK: - share_experience parity

    func testShareExperienceNorwegianCountMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceNorwegianIDsMatchEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperienceNorwegianMetadataMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, nbE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(nbE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(nbE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceNorwegianNoEmptyFullText() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    // MARK: - prompts parity

    func testPromptsNorwegianCountMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsNorwegianIDsMatchEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsNorwegianMetadataMatchesEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: Self.locale) { enP, nbP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(nbP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(nbP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(nbP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(nbP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsNorwegianNoEmptyText() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsNorwegianFollowUpParityWithEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Translation regression

    func testPromptsNbTextDiffersFromEnglish() throws {
        try skipIfBankMissing("prompts")
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Schema metadata

    func testAllNorwegianJsonFilesHaveSchemaVersion1() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: Self.locale) }
    }

    func testAllNorwegianJsonFilesHaveLanguageNb() throws {
        let banks = ["fall_in_love", "life_story", "share_experience", "prompts"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertLanguageField(bankName: bank, locale: Self.locale) }
    }
}
