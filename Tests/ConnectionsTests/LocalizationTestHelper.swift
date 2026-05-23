//
//  LocalizationTestHelper.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

/// Reusable static assertions for localization test coverage.
/// This is a plain struct — XCTestCase discovery lives in locale-specific test classes only.
struct LocalizationTestHelper {

    // MARK: - xcstrings paths (resolved relative to this source file)

    private static let projectRootURL: URL = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()   // ConnectionsTests/
        .deletingLastPathComponent()   // Tests/
        .deletingLastPathComponent()   // project root

    private static let xcstringsURLs: [URL] = [
        projectRootURL.appendingPathComponent("Connections/Localizable.xcstrings"),
        projectRootURL.appendingPathComponent("Connections/Paywall.xcstrings")
    ]

    private static let xcstringsCatalogs: [(url: URL, json: [String: Any])] = {
        xcstringsURLs.compactMap { url in
            guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return nil }
            return (url, json)
        }
    }()

    // MARK: - xcstrings assertions

    static func assertXcstringsFileExists(file: StaticString = #file, line: UInt = #line) {
        for url in xcstringsURLs {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: url.path),
                "\(url.lastPathComponent) not found at \(url.path)",
                file: file, line: line
            )
        }
    }

    static func assertAllTranslatableKeysHaveValues(
        locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        for catalog in xcstringsCatalogs {
            guard let strings = catalog.json["strings"] as? [String: Any] else {
                XCTFail("\(catalog.url.lastPathComponent): could not read 'strings' dictionary", file: file, line: line)
                continue
            }
            for (key, entry) in strings {
                guard let entryDict = entry as? [String: Any] else { continue }
                if let shouldTranslate = entryDict["shouldTranslate"] as? Bool, !shouldTranslate { continue }
                let localizations = entryDict["localizations"] as? [String: Any] ?? [:]
                XCTAssertNotNil(
                    localizations[locale],
                    "\(catalog.url.lastPathComponent): key '\(key)' is missing \(locale) localization",
                    file: file, line: line
                )
            }
        }
    }

    static func assertNoLocaleValuesAreEmpty(
        locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        for catalog in xcstringsCatalogs {
            guard let strings = catalog.json["strings"] as? [String: Any] else { continue }
            for (key, entry) in strings {
                guard let entryDict = entry as? [String: Any],
                      let localizations = entryDict["localizations"] as? [String: Any],
                      let localeEntry = localizations[locale] as? [String: Any],
                      let unit = localeEntry["stringUnit"] as? [String: Any],
                      let value = unit["value"] as? String else { continue }
                XCTAssertFalse(
                    value.isEmpty,
                    "\(catalog.url.lastPathComponent): \(locale) value for key '\(key)' is empty",
                    file: file, line: line
                )
            }
        }
    }

    static func assertBrandTermIsNonTranslatable(
        key: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        guard let localizable = xcstringsCatalogs.first(where: { $0.url.lastPathComponent == "Localizable.xcstrings" }),
              let strings = localizable.json["strings"] as? [String: Any],
              let entry = strings[key] as? [String: Any] else {
            XCTFail("'\(key)' key not found in xcstrings", file: file, line: line)
            return
        }
        XCTAssertEqual(
            entry["shouldTranslate"] as? Bool, false,
            "'\(key)' should have shouldTranslate=false",
            file: file, line: line
        )
    }

    static func assertBrandTermHasNoLocalizationBlock(
        key: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        guard let localizable = xcstringsCatalogs.first(where: { $0.url.lastPathComponent == "Localizable.xcstrings" }),
              let strings = localizable.json["strings"] as? [String: Any],
              let entry = strings[key] as? [String: Any],
              let localizations = entry["localizations"] as? [String: Any] else { return }
        XCTAssertNil(
            localizations[locale],
            "'\(key)' should not have a '\(locale)' localization block",
            file: file, line: line
        )
    }

    static func assertFormatPlaceholderParity(
        locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        for catalog in xcstringsCatalogs {
            guard let strings = catalog.json["strings"] as? [String: Any] else { continue }
            for (key, entry) in strings {
                guard let entryDict = entry as? [String: Any] else { continue }
                if let shouldTranslate = entryDict["shouldTranslate"] as? Bool, !shouldTranslate { continue }
                guard let localizations = entryDict["localizations"] as? [String: Any],
                      let en = localizations["en"] as? [String: Any],
                      let enUnit = en["stringUnit"] as? [String: Any],
                      let enValue = enUnit["value"] as? String,
                      let localeEntry = localizations[locale] as? [String: Any],
                      let localeUnit = localeEntry["stringUnit"] as? [String: Any],
                      let localeValue = localeUnit["value"] as? String else { continue }
                let enPH = formatPlaceholders(in: enValue).sorted()
                let localePH = formatPlaceholders(in: localeValue).sorted()
                XCTAssertEqual(
                    localePH, enPH,
                    "\(catalog.url.lastPathComponent): placeholder mismatch for '\(key)': en=\(enPH) \(locale)=\(localePH)",
                    file: file, line: line
                )
            }
        }
    }

    // MARK: - JSON bank assertions

    static func assertBankLoads(
        bankName: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: locale)
        XCTAssertFalse(result.data.isEmpty, "\(bankName)_\(locale): data is empty", file: file, line: line)
        XCTAssertEqual(result.locale, locale, "\(bankName): loaded locale mismatch", file: file, line: line)
    }

    static func assertBankCountMatchesEnglish(
        bankName: String, arrayKey: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let loc = loadJSON(bankName: bankName, locale: locale)
        let enCount = (en[arrayKey] as? [[String: Any]])?.count ?? 0
        let locCount = (loc[arrayKey] as? [[String: Any]])?.count ?? 0
        XCTAssertEqual(
            locCount, enCount,
            "\(bankName)_\(locale): count mismatch (expected \(enCount), got \(locCount))",
            file: file, line: line
        )
    }

    static func assertBankIDsMatchEnglish(
        bankName: String, arrayKey: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let loc = loadJSON(bankName: bankName, locale: locale)
        let enIDs = (en[arrayKey] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
        let locIDs = (loc[arrayKey] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
        XCTAssertEqual(locIDs, enIDs, "\(bankName)_\(locale): IDs don't match English", file: file, line: line)
    }

    /// Iterates paired English and locale arrays, calling `check` for each pair.
    /// Assertions written inside `check` closures will attribute to the caller's file/line.
    static func assertBankArrays(
        bankName: String, arrayKey: String, locale: String,
        check: ([String: Any], [String: Any]) -> Void,
        file: StaticString = #file, line: UInt = #line
    ) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let loc = loadJSON(bankName: bankName, locale: locale)
        guard let enArr = en[arrayKey] as? [[String: Any]],
              let locArr = loc[arrayKey] as? [[String: Any]] else {
            XCTFail("\(bankName): could not read '\(arrayKey)' array", file: file, line: line)
            return
        }
        for (enItem, locItem) in zip(enArr, locArr) { check(enItem, locItem) }
    }

    static func assertNoEmptyField(
        _ field: String, bankName: String, arrayKey: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let loc = loadJSON(bankName: bankName, locale: locale)
        guard let items = loc[arrayKey] as? [[String: Any]] else { return }
        for item in items {
            XCTAssertFalse(
                (item[field] as? String ?? "").isEmpty,
                "\(bankName)_\(locale): empty '\(field)' for id=\(item["id"] ?? "?")",
                file: file, line: line
            )
        }
    }

    /// Checks follow-up count, id, style, and non-empty text parity for the array-based `followUps` structure.
    static func assertPromptFollowUpParity(
        bankName: String, arrayKey: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        assertBankArrays(
            bankName: bankName, arrayKey: arrayKey, locale: locale,
            check: { enP, locP in
                let id = enP["id"] as? String ?? "?"
                let enFUs = enP["followUps"] as? [[String: Any]] ?? []
                let locFUs = locP["followUps"] as? [[String: Any]] ?? []
                XCTAssertEqual(locFUs.count, enFUs.count, "followUp count id=\(id)", file: file, line: line)
                for (enFU, locFU) in zip(enFUs, locFUs) {
                    XCTAssertEqual(locFU["id"] as? String, enFU["id"] as? String,
                                   "fu id mismatch prompt=\(id)", file: file, line: line)
                    XCTAssertEqual(locFU["style"] as? String, enFU["style"] as? String,
                                   "fu style mismatch prompt=\(id)", file: file, line: line)
                    XCTAssertFalse(
                        (locFU["text"] as? String ?? "").isEmpty,
                        "empty fu text prompt=\(id) fu=\(enFU["id"] ?? "?")",
                        file: file, line: line
                    )
                }
            },
            file: file, line: line
        )
    }

    /// Checks that `followUp1` and `followUp2` string fields are non-empty (life_story bank structure).
    static func assertLifeStoryFollowUpsNonEmpty(
        locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let loc = loadJSON(bankName: "life_story", locale: locale)
        guard let prompts = loc["prompts"] as? [[String: Any]] else { return }
        for p in prompts {
            let id = p["id"] as? String ?? "?"
            XCTAssertFalse((p["followUp1"] as? String ?? "").isEmpty,
                           "empty followUp1 id=\(id)", file: file, line: line)
            XCTAssertFalse((p["followUp2"] as? String ?? "").isEmpty,
                           "empty followUp2 id=\(id)", file: file, line: line)
        }
    }

    /// Asserts that each translated text differs from its English source (regression against untranslated placeholders).
    static func assertTranslatedTextDiffersFromEnglish(
        bankName: String, arrayKey: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        let en = loadJSON(bankName: bankName, locale: "en")
        let loc = loadJSON(bankName: bankName, locale: locale)
        guard let enArr = en[arrayKey] as? [[String: Any]],
              let locArr = loc[arrayKey] as? [[String: Any]] else {
            XCTFail("Could not load \(bankName) arrays", file: file, line: line)
            return
        }
        for (enP, locP) in zip(enArr, locArr) {
            let id = enP["id"] as? String ?? "?"
            if let enText = enP["text"] as? String, let locText = locP["text"] as? String {
                XCTAssertNotEqual(
                    locText, enText,
                    "\(bankName)_\(locale) prompt '\(id)' text is still English placeholder",
                    file: file, line: line
                )
            }
            let enFUs = enP["followUps"] as? [[String: Any]] ?? []
            let locFUs = locP["followUps"] as? [[String: Any]] ?? []
            for (enFU, locFU) in zip(enFUs, locFUs) {
                if let enT = enFU["text"] as? String, let locT = locFU["text"] as? String {
                    XCTAssertNotEqual(
                        locT, enT,
                        "\(bankName)_\(locale) followUp '\(locFU["id"] ?? "?")' text is still English placeholder",
                        file: file, line: line
                    )
                }
            }
        }
    }

    static func assertSchemaVersion(
        _ version: Int = 1, bankName: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertEqual(
            loadJSON(bankName: bankName, locale: locale)["schemaVersion"] as? Int, version,
            "\(bankName)_\(locale).json: schemaVersion must be \(version)",
            file: file, line: line
        )
    }

    static func assertLanguageField(
        bankName: String, locale: String,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertEqual(
            loadJSON(bankName: bankName, locale: locale)["language"] as? String, locale,
            "\(bankName)_\(locale).json: language must be '\(locale)'",
            file: file, line: line
        )
    }

    // MARK: - Internal helpers

    static func loadJSON(bankName: String, locale: String) -> [String: Any] {
        let result = JSONBankLoader.load(bankName: bankName, preferredLocale: locale)
        guard let json = try? JSONSerialization.jsonObject(with: result.data) as? [String: Any] else {
            XCTFail("Could not parse \(bankName)_\(locale).json")
            return [:]
        }
        return json
    }

    // MARK: - Private helpers

    private static func formatPlaceholders(in text: String) -> [String] {
        let pattern = #"%\d+\$[a-zA-Z@]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            Range(match.range, in: text).map { String(text[$0]) }
        }
    }
}
