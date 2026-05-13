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

    // MARK: - Localizable.xcstrings (source-level)

    // The xcstrings file lives in source; locate it relative to this test file.
    private static let xcstringsURL: URL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // ConnectionsTests/
        .deletingLastPathComponent()   // Tests/
        .deletingLastPathComponent()   // project root
        .appendingPathComponent("Connections/Localizable.xcstrings")

    private static var xcstringsJSON: [String: Any]? = {
        guard let data = try? Data(contentsOf: xcstringsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }()

    func testXcstringsSourceFileExists() {
        XCTAssertTrue(FileManager.default.fileExists(atPath: Self.xcstringsURL.path),
                      "Localizable.xcstrings not found at \(Self.xcstringsURL.path)")
    }

    func testAllTranslatableKeysHaveSpanishValues() {
        guard let strings = Self.xcstringsJSON?["strings"] as? [String: Any] else {
            XCTFail("Localizable.xcstrings: could not read 'strings' dictionary"); return
        }
        for (key, entry) in strings {
            guard let entryDict = entry as? [String: Any] else { continue }
            if let shouldTranslate = entryDict["shouldTranslate"] as? Bool, !shouldTranslate { continue }
            let localizations = entryDict["localizations"] as? [String: Any] ?? [:]
            XCTAssertNotNil(localizations["es"], "Key '\(key)' is missing Spanish localization")
        }
    }

    func testNoSpanishValuesAreEmpty() {
        guard let strings = Self.xcstringsJSON?["strings"] as? [String: Any] else { return }
        for (key, entry) in strings {
            guard let entryDict = entry as? [String: Any],
                  let localizations = entryDict["localizations"] as? [String: Any],
                  let es = localizations["es"] as? [String: Any],
                  let unit = es["stringUnit"] as? [String: Any],
                  let value = unit["value"] as? String else { continue }
            XCTAssertFalse(value.isEmpty, "Spanish value for key '\(key)' is empty")
        }
    }

    func testDeeperConversationsIsNonTranslatable() {
        guard let strings = Self.xcstringsJSON?["strings"] as? [String: Any],
              let entry = strings["Deeper Conversations"] as? [String: Any] else {
            XCTFail("'Deeper Conversations' key not found in xcstrings"); return
        }
        XCTAssertEqual(entry["shouldTranslate"] as? Bool, false,
                       "'Deeper Conversations' should have shouldTranslate=false")
    }

    func testDeeperConversationsHasNoSpanishEntry() {
        guard let strings = Self.xcstringsJSON?["strings"] as? [String: Any],
              let entry = strings["Deeper Conversations"] as? [String: Any],
              let localizations = entry["localizations"] as? [String: Any] else { return }
        XCTAssertNil(localizations["es"],
                     "'Deeper Conversations' should not have an 'es' localization block")
    }

    func testFormatPlaceholderParityBetweenEnglishAndSpanish() {
        guard let strings = Self.xcstringsJSON?["strings"] as? [String: Any] else { return }
        for (key, entry) in strings {
            guard let entryDict = entry as? [String: Any] else { continue }
            if let shouldTranslate = entryDict["shouldTranslate"] as? Bool, !shouldTranslate { continue }
            guard let localizations = entryDict["localizations"] as? [String: Any],
                  let en = localizations["en"] as? [String: Any],
                  let enUnit = en["stringUnit"] as? [String: Any],
                  let enValue = enUnit["value"] as? String,
                  let es = localizations["es"] as? [String: Any],
                  let esUnit = es["stringUnit"] as? [String: Any],
                  let esValue = esUnit["value"] as? String else { continue }
            let enPH = formatPlaceholders(in: enValue).sorted()
            let esPH = formatPlaceholders(in: esValue).sorted()
            XCTAssertEqual(esPH, enPH,
                           "Placeholder mismatch for '\(key)': en=\(enPH) es=\(esPH)")
        }
    }

    private func formatPlaceholders(in text: String) -> [String] {
        // Matches numbered specifiers: %1$@, %2$lld, %1$d, etc.
        let pattern = #"%\d+\$[a-zA-Z@]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            Range(match.range, in: text).map { String(text[$0]) }
        }
    }

    // MARK: - Spanish JSON Loading

    func testSpanishFallInLoveLoads() {
        let result = JSONBankLoader.load(bankName: "fall_in_love", preferredLocale: "es")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "es")
    }

    func testSpanishLifeStoryLoads() {
        let result = JSONBankLoader.load(bankName: "life_story", preferredLocale: "es")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "es")
    }

    func testSpanishShareExperienceLoads() {
        let result = JSONBankLoader.load(bankName: "share_experience", preferredLocale: "es")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "es")
    }

    func testSpanishPromptsLoads() {
        let result = JSONBankLoader.load(bankName: "prompts", preferredLocale: "es")
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.locale, "es")
    }

    // MARK: - fall_in_love parity

    func testFallInLoveSpanishCountMatchesEnglish() {
        verifyCount(bankName: "fall_in_love", arrayKey: "prompts")
    }

    func testFallInLoveSpanishIDsMatchEnglish() {
        verifyIDs(bankName: "fall_in_love", arrayKey: "prompts")
    }

    func testFallInLoveSpanishMetadataMatchesEnglish() {
        verifyArrays(bankName: "fall_in_love", arrayKey: "prompts") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(esP["order"] as? Int,        enP["order"] as? Int,         "order id=\(id)")
        }
    }

    func testFallInLoveSpanishNoEmptyText() {
        verifyNoEmptyField("text", bankName: "fall_in_love", arrayKey: "prompts")
    }

    // MARK: - life_story parity

    func testLifeStorySpanishCountMatchesEnglish() {
        verifyCount(bankName: "life_story", arrayKey: "prompts")
    }

    func testLifeStorySpanishIDsMatchEnglish() {
        verifyIDs(bankName: "life_story", arrayKey: "prompts")
    }

    func testLifeStorySpanishMetadataMatchesEnglish() {
        verifyArrays(bankName: "life_story", arrayKey: "prompts") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["chapter"] as? String, enP["chapter"] as? String, "chapter id=\(id)")
            XCTAssertEqual(esP["order"] as? Int,      enP["order"] as? Int,       "order id=\(id)")
        }
    }

    func testLifeStorySpanishNoEmptyText() {
        verifyNoEmptyField("text", bankName: "life_story", arrayKey: "prompts")
    }

    func testLifeStorySpanishFollowUpsNonEmpty() {
        let es = loadJSON(bankName: "life_story", locale: "es")
        guard let prompts = es["prompts"] as? [[String: Any]] else { return }
        for p in prompts {
            let id = p["id"] as? String ?? "?"
            XCTAssertFalse((p["followUp1"] as? String ?? "").isEmpty, "empty followUp1 id=\(id)")
            XCTAssertFalse((p["followUp2"] as? String ?? "").isEmpty, "empty followUp2 id=\(id)")
        }
    }

    // MARK: - share_experience parity

    func testShareExperienceSpanishCountMatchesEnglish() {
        verifyCount(bankName: "share_experience", arrayKey: "experiences")
    }

    func testShareExperienceSpanishIDsMatchEnglish() {
        verifyIDs(bankName: "share_experience", arrayKey: "experiences")
    }

    func testShareExperienceSpanishMetadataMatchesEnglish() {
        verifyArrays(bankName: "share_experience", arrayKey: "experiences") { enE, esE in
            let id = enE["id"] as? String ?? "?"
            XCTAssertEqual(esE["intensity"] as? String, enE["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esE["topic"] as? String,     enE["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testShareExperienceSpanishNoEmptyFullText() {
        verifyNoEmptyField("fullText", bankName: "share_experience", arrayKey: "experiences")
    }

    // MARK: - prompts parity

    func testPromptsSpanishCountMatchesEnglish() {
        verifyCount(bankName: "prompts", arrayKey: "prompts")
    }

    func testPromptsSpanishIDsMatchEnglish() {
        verifyIDs(bankName: "prompts", arrayKey: "prompts")
    }

    func testPromptsSpanishMetadataMatchesEnglish() {
        verifyArrays(bankName: "prompts", arrayKey: "prompts") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            XCTAssertEqual(esP["mode"] as? String,      enP["mode"] as? String,      "mode id=\(id)")
            XCTAssertEqual(esP["intensity"] as? String, enP["intensity"] as? String, "intensity id=\(id)")
            XCTAssertEqual(esP["depth"] as? String,     enP["depth"] as? String,     "depth id=\(id)")
            XCTAssertEqual(esP["topic"] as? String,     enP["topic"] as? String,     "topic id=\(id)")
        }
    }

    func testPromptsSpanishNoEmptyText() {
        verifyNoEmptyField("text", bankName: "prompts", arrayKey: "prompts")
    }

    func testPromptsSpanishFollowUpParityWithEnglish() {
        verifyArrays(bankName: "prompts", arrayKey: "prompts") { enP, esP in
            let id = enP["id"] as? String ?? "?"
            let enFUs = enP["followUps"] as? [[String: Any]] ?? []
            let esFUs = esP["followUps"] as? [[String: Any]] ?? []
            XCTAssertEqual(esFUs.count, enFUs.count, "followUp count id=\(id)")
            for (enFU, esFU) in zip(enFUs, esFUs) {
                XCTAssertEqual(esFU["id"] as? String,    enFU["id"] as? String,    "fu id mismatch prompt=\(id)")
                XCTAssertEqual(esFU["style"] as? String, enFU["style"] as? String, "fu style mismatch prompt=\(id)")
                XCTAssertFalse((esFU["text"] as? String ?? "").isEmpty,
                               "empty fu text prompt=\(id) fu=\(enFU["id"] ?? "?")")
            }
        }
    }

    // MARK: - Translation regression (prompts_es must not be English placeholders)

    func testPromptsEsTextDiffersFromEnglish() {
        let en = loadJSON(bankName: "prompts", locale: "en")
        let es = loadJSON(bankName: "prompts", locale: "es")
        guard let enArr = en["prompts"] as? [[String: Any]],
              let esArr = es["prompts"] as? [[String: Any]] else {
            XCTFail("Could not load prompts arrays"); return
        }
        var identical = 0
        for (enP, esP) in zip(enArr, esArr) {
            let id = enP["id"] as? String ?? "?"
            if let enText = enP["text"] as? String, let esText = esP["text"] as? String {
                if enText == esText { identical += 1 }
                XCTAssertNotEqual(esText, enText,
                    "prompts_es prompt '\(id)' text is still English placeholder")
            }
            let enFUs = enP["followUps"] as? [[String: Any]] ?? []
            let esFUs = esP["followUps"] as? [[String: Any]] ?? []
            for (enFU, esFU) in zip(enFUs, esFUs) {
                if let enT = enFU["text"] as? String, let esT = esFU["text"] as? String {
                    XCTAssertNotEqual(esT, enT,
                        "prompts_es followUp '\(esFU["id"] ?? "?")' text is still English placeholder")
                }
            }
        }
    }

    // MARK: - Schema metadata

    func testAllSpanishJsonFilesHaveSchemaVersion1() {
        for bank in ["fall_in_love", "life_story", "share_experience", "prompts"] {
            XCTAssertEqual(loadJSON(bankName: bank, locale: "es")["schemaVersion"] as? Int, 1,
                           "\(bank)_es.json: schemaVersion must be 1")
        }
    }

    func testAllSpanishJsonFilesHaveLanguageEs() {
        for bank in ["fall_in_love", "life_story", "share_experience", "prompts"] {
            XCTAssertEqual(loadJSON(bankName: bank, locale: "es")["language"] as? String, "es",
                           "\(bank)_es.json: language must be 'es'")
        }
    }

    // MARK: - Helpers

    private func loadJSON(bankName: String, locale: String) -> [String: Any] {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: locale)
        guard let json = try? JSONSerialization.jsonObject(with: result.data) as? [String: Any] else {
            XCTFail("Could not parse \(bankName)_\(locale).json"); return [:]
        }
        return json
    }

    private func verifyCount(bankName: String, arrayKey: String) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let es = loadJSON(bankName: bankName, locale: "es")
        let enCount = (en[arrayKey] as? [[String: Any]])?.count ?? 0
        let esCount = (es[arrayKey] as? [[String: Any]])?.count ?? 0
        XCTAssertEqual(esCount, enCount, "\(bankName)_es: count mismatch (expected \(enCount), got \(esCount))")
    }

    private func verifyIDs(bankName: String, arrayKey: String) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let es = loadJSON(bankName: bankName, locale: "es")
        let enIDs = (en[arrayKey] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
        let esIDs = (es[arrayKey] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
        XCTAssertEqual(esIDs, enIDs, "\(bankName)_es: IDs don't match English")
    }

    private func verifyArrays(bankName: String, arrayKey: String,
                               check: ([String: Any], [String: Any]) -> Void) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let es = loadJSON(bankName: bankName, locale: "es")
        guard let enArr = en[arrayKey] as? [[String: Any]],
              let esArr = es[arrayKey] as? [[String: Any]] else {
            XCTFail("\(bankName): could not read '\(arrayKey)' array"); return
        }
        for (enItem, esItem) in zip(enArr, esArr) { check(enItem, esItem) }
    }

    private func verifyNoEmptyField(_ field: String, bankName: String, arrayKey: String) {
        let es = loadJSON(bankName: bankName, locale: "es")
        guard let items = es[arrayKey] as? [[String: Any]] else { return }
        for item in items {
            XCTAssertFalse((item[field] as? String ?? "").isEmpty,
                           "\(bankName)_es: empty '\(field)' for id=\(item["id"] ?? "?")")
        }
    }
}
