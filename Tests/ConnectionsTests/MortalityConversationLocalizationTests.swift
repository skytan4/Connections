//
//  MortalityConversationLocalizationTests.swift
//  ConnectionsTests
//

import XCTest
@testable import Connections

final class MortalityConversationLocalizationTests: XCTestCase {
    private let locales = [
        "da",
        "de",
        "es",
        "fi",
        "fr",
        "it",
        "ja",
        "nb",
        "nl",
        "pl",
        "pt-BR",
        "ru",
        "sv",
        "zh-Hans"
    ]

    func testLocalizedMortalityConversationBanksLoad() {
        for locale in locales {
            LocalizationTestHelper.assertBankLoads(bankName: "mortality_conversations", locale: locale)
        }
    }

    func testLocalizedMortalityConversationCountsMatchEnglish() {
        for locale in locales {
            LocalizationTestHelper.assertBankCountMatchesEnglish(
                bankName: "mortality_conversations",
                arrayKey: "prompts",
                locale: locale
            )
        }
    }

    func testLocalizedMortalityConversationIDsMatchEnglish() {
        for locale in locales {
            LocalizationTestHelper.assertBankIDsMatchEnglish(
                bankName: "mortality_conversations",
                arrayKey: "prompts",
                locale: locale
            )
        }
    }

    func testLocalizedMortalityConversationMetadataMatchesEnglish() {
        for locale in locales {
            LocalizationTestHelper.assertBankArrays(
                bankName: "mortality_conversations",
                arrayKey: "prompts",
                locale: locale
            ) { enPrompt, localizedPrompt in
                let id = enPrompt["id"] as? String ?? "?"
                XCTAssertEqual(localizedPrompt["topic"] as? String, enPrompt["topic"] as? String, "topic id=\(id)")
                XCTAssertEqual(localizedPrompt["order"] as? Int, enPrompt["order"] as? Int, "order id=\(id)")
            }
        }
    }

    func testLocalizedMortalityConversationTextIsNonEmpty() {
        for locale in locales {
            LocalizationTestHelper.assertNoEmptyField(
                "text",
                bankName: "mortality_conversations",
                arrayKey: "prompts",
                locale: locale
            )
        }
    }

    func testLocalizedMortalityConversationTextDiffersFromEnglish() {
        for locale in locales {
            LocalizationTestHelper.assertTranslatedTextDiffersFromEnglish(
                bankName: "mortality_conversations",
                arrayKey: "prompts",
                locale: locale
            )
        }
    }

    func testLocalizedMortalityConversationSchemaMetadata() {
        for locale in locales {
            LocalizationTestHelper.assertSchemaVersion(1, bankName: "mortality_conversations", locale: locale)
            LocalizationTestHelper.assertLanguageField(bankName: "mortality_conversations", locale: locale)
        }
    }
}
