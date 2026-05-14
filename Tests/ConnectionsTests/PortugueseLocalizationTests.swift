//
//  PortugueseLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class PortugueseLocalizationTests: XCTestCase {

    private static let locale = "pt-BR"

    // MARK: - Skip guards

    private func skipIfBankMissing(_ bankName: String) throws {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: Self.locale)
        guard result.locale == Self.locale else {
            throw XCTSkip("\(bankName)_\(Self.locale).json not yet available — skipping until Portuguese translation is committed")
        }
    }

    private func skipIfPortugueseXcstringsMissing() throws {
        let xcstringsURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()   // ConnectionsTests/
            .deletingLastPathComponent()   // Tests/
            .deletingLastPathComponent()   // project root
            .appendingPathComponent("Connections/Localizable.xcstrings")
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else { return }
        let hasPortuguese = strings.values
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["localizations"] as? [String: Any] }
            .flatMap { $0.keys }
            .contains(Self.locale)
        guard hasPortuguese else {
            throw XCTSkip("No Portuguese entries in Localizable.xcstrings yet — skipping until Portuguese UI strings are added")
        }
    }

    // MARK: - Localizable.xcstrings (always-run)

    func testXcstringsSourceFileExists() {
        LocalizationTestHelper.assertXcstringsFileExists()
    }

    func testDeeperConversationsIsNonTranslatable() {
        LocalizationTestHelper.assertBrandTermIsNonTranslatable(key: "Deeper Conversations")
    }

    func testDeeperConversationsHasNoPortugueseEntry() {
        LocalizationTestHelper.assertBrandTermHasNoLocalizationBlock(key: "Deeper Conversations", locale: Self.locale)
    }

    // MARK: - Localizable.xcstrings (skip until Portuguese UI strings are added)

    func testAllTranslatableKeysHavePortugueseValues() throws {
        try skipIfPortugueseXcstringsMissing()
        LocalizationTestHelper.assertAllTranslatableKeysHaveValues(locale: Self.locale)
    }

    func testNoPortugueseValuesAreEmpty() throws {
        try skipIfPortugueseXcstringsMissing()
        LocalizationTestHelper.assertNoLocaleValuesAreEmpty(locale: Self.locale)
    }

    func testFormatPlaceholderParityBetweenEnglishAndPortuguese() throws {
        try skipIfPortugueseXcstringsMissing()
        LocalizationTestHelper.assertFormatPlaceholderParity(locale: Self.locale)
    }

    // MARK: - JSON bank loading (prompts always-run; others skip until available)

    func testPortuguesePromptsLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "prompts", locale: Self.locale)
    }

    func testPortugueseFallInLoveLoads() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testPortugueseLifeStoryLoads() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testPortugueseShareExperienceLoads() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    // MARK: - fall_in_love parity

    func testFallInLovePortugueseCountMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseIDsMatchEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, ptP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(ptP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(ptP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(ptP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLovePortugueseNoEmptyText() throws {
        try skipIfBankMissing("fall_in_love")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - life_story parity

    func testLifeStoryPortugueseCountMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseIDsMatchEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, ptP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(ptP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(ptP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryPortugueseNoEmptyText() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseFollowUpsNonEmpty() throws {
        try skipIfBankMissing("life_story")
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    // MARK: - share_experience parity

    func testShareExperiencePortugueseCountMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseIDsMatchEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseMetadataMatchesEnglish() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, ptE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(ptE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(ptE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperiencePortugueseNoEmptyFullText() throws {
        try skipIfBankMissing("share_experience")
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    // MARK: - prompts parity (always-run)

    func testPromptsPortugueseCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsPortugueseIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsPortugueseMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "prompts", arrayKey: "prompts", locale: Self.locale) { enP, ptP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(ptP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(ptP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(ptP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(ptP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsPortugueseNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    func testPromptsPortugueseFollowUpParityWithEnglish() {
        LocalizationTestHelper.assertPromptFollowUpParity(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Translation regression

    func testPromptsPtBRTextDiffersFromEnglish() {
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "prompts", arrayKey: "prompts", locale: Self.locale)
    }

    // MARK: - Schema metadata

    func testPromptsPortugueseJsonHasSchemaVersion1() {
        LocalizationTestHelper.assertSchemaVersion(1, bankName: "prompts", locale: Self.locale)
    }

    func testPromptsPortugueseJsonHasLanguagePtBR() {
        LocalizationTestHelper.assertLanguageField(bankName: "prompts", locale: Self.locale)
    }

    func testAllPortugueseJsonFilesHaveSchemaVersion1() throws {
        let banks = ["fall_in_love", "life_story", "share_experience"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertSchemaVersion(1, bankName: bank, locale: Self.locale) }
    }

    func testAllPortugueseJsonFilesHaveLanguagePtBR() throws {
        let banks = ["fall_in_love", "life_story", "share_experience"]
        for bank in banks { try skipIfBankMissing(bank) }
        for bank in banks { LocalizationTestHelper.assertLanguageField(bankName: bank, locale: Self.locale) }
    }
}
