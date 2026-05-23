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


    // MARK: - fall_in_love parity (always-run)

    func testFallInLovePortugueseLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "fall_in_love", locale: Self.locale)
    }

    func testFallInLovePortugueseCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale) { enP, ptP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(ptP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(ptP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(ptP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLovePortugueseNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseTextDiffersFromEnglish() {
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "fall_in_love", arrayKey: "prompts", locale: Self.locale)
    }

    func testFallInLovePortugueseSchemaVersion1() {
        LocalizationTestHelper.assertSchemaVersion(1, bankName: "fall_in_love", locale: Self.locale)
    }

    func testFallInLovePortugueseLanguagePtBR() {
        LocalizationTestHelper.assertLanguageField(bankName: "fall_in_love", locale: Self.locale)
    }

    // MARK: - life_story parity (always-run)

    func testLifeStoryPortugueseLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "life_story", locale: Self.locale)
    }

    func testLifeStoryPortugueseCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "life_story", arrayKey: "prompts", locale: Self.locale) { enP, ptP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(ptP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(ptP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStoryPortugueseNoEmptyText() {
        LocalizationTestHelper.assertNoEmptyField("text", bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseFollowUpsNonEmpty() {
        LocalizationTestHelper.assertLifeStoryFollowUpsNonEmpty(locale: Self.locale)
    }

    func testLifeStoryPortugueseTextDiffersFromEnglish() {
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "life_story", arrayKey: "prompts", locale: Self.locale)
    }

    func testLifeStoryPortugueseSchemaVersion1() {
        LocalizationTestHelper.assertSchemaVersion(1, bankName: "life_story", locale: Self.locale)
    }

    func testLifeStoryPortugueseLanguagePtBR() {
        LocalizationTestHelper.assertLanguageField(bankName: "life_story", locale: Self.locale)
    }

    // MARK: - share_experience parity (always-run)

    func testShareExperiencePortugueseLoads() {
        LocalizationTestHelper.assertBankLoads(bankName: "share_experience", locale: Self.locale)
    }

    func testShareExperiencePortugueseCountMatchesEnglish() {
        LocalizationTestHelper.assertBankCountMatchesEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseIDsMatchEnglish() {
        LocalizationTestHelper.assertBankIDsMatchEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseMetadataMatchesEnglish() {
        LocalizationTestHelper.assertBankArrays(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale) { enE, ptE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(ptE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(ptE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperiencePortugueseNoEmptyFullText() {
        LocalizationTestHelper.assertNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseFullTextDiffersFromEnglish() {
        LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(bankName: "share_experience", arrayKey: "experiences", locale: Self.locale)
    }

    func testShareExperiencePortugueseSchemaVersion1() {
        LocalizationTestHelper.assertSchemaVersion(1, bankName: "share_experience", locale: Self.locale)
    }

    func testShareExperiencePortugueseLanguagePtBR() {
        LocalizationTestHelper.assertLanguageField(bankName: "share_experience", locale: Self.locale)
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

}
