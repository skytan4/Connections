//
//  JSONBankLoader.swift
//  Connections
//

import Foundation

enum JSONBankLoader {

    struct LoadResult {
        let data: Data
        let locale: String
    }

    /// Returns the ordered list of locale codes to try for a given preferred locale.
    /// Exposed for unit testing.
    ///
    /// Strategy:
    ///   1. Full locale code  ("en-US", "fr-FR")
    ///   2. Language-only     ("en", "fr")      — only added when different from step 1
    ///   3. English fallback  ("en")            — only added when not already present
    static func localeCandidates(preferredLocale: String) -> [String] {
        var candidates: [String] = [preferredLocale]
        let language = String(preferredLocale.prefix(while: { $0 != "-" && $0 != "_" }))
        if language != preferredLocale {
            candidates.append(language)
        }
        if !candidates.contains("en") {
            candidates.append("en")
        }
        return candidates
    }

    /// Loads raw JSON data for a named bank, trying locale variants then falling back to English.
    ///
    /// - Parameters:
    ///   - bankName: Filename stem, e.g. `"fall_in_love"` → tries `fall_in_love_en-US.json`, then
    ///               `fall_in_love_en.json`, etc.
    ///   - bundle: Bundle to search. Defaults to `.main`; inject a test bundle to verify fallback.
    ///   - preferredLocale: Override the locale resolution (uses `bundle.preferredLocalizations.first`
    ///                      when nil). Pass a value in tests to exercise specific fallback paths.
    /// - Returns: The raw `Data` and the locale code that was actually found.
    static func load(
        bankName: String,
        bundle: Bundle = .main,
        preferredLocale: String? = nil
    ) -> LoadResult {
        let locale = preferredLocale ?? bundle.preferredLocalizations.first ?? "en"
        let candidates = localeCandidates(preferredLocale: locale)

        for candidate in candidates {
            let resourceName = "\(bankName)_\(candidate)"
            if let url = bundle.url(forResource: resourceName, withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                return LoadResult(data: data, locale: candidate)
            }
        }

        fatalError(
            "No JSON found for bank '\(bankName)' — tried: " +
            candidates.map { "\(bankName)_\($0).json" }.joined(separator: ", ")
        )
    }
}
