// 
// GeneratedStringSymbols_Paywall.swift
// Auto-Generated symbols for localized strings defined in “Paywall.xcstrings”.
// 

import Foundation

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.atURL(resourceBundle.bundleURL)
#else

private class ResourceBundleClass {}
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.forClass(ResourceBundleClass.self)
#endif

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
nonisolated extension LocalizedStringResource {
    /// Namespace for strings in file “Paywall.xcstrings”.
    enum Paywall {
        /**
         Shown when the StoreKit product fails to load (network issue, App Store Connect misconfig, etc.). Apple guideline: actionable, mentions Restore as backup.
         
         Localized string for key “paywall.error.productUnavailable” in table “Paywall.xcstrings”.
         */
        static var paywallErrorProductUnavailable: LocalizedStringResource {
            LocalizedStringResource("paywall.error.productUnavailable", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Shown when product.purchase() throws (network, payment method failure, etc.). Apple guideline: reassure no charge, offer retry + restore.
         
         Localized string for key “paywall.error.purchaseFailed” in table “Paywall.xcstrings”.
         */
        static var paywallErrorPurchaseFailed: LocalizedStringResource {
            LocalizedStringResource("paywall.error.purchaseFailed", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Shown when AppStore.sync() throws during Restore Purchases. Apple guideline: short, actionable, no raw error codes.
         
         Localized string for key “paywall.error.restoreFailed” in table “Paywall.xcstrings”.
         */
        static var paywallErrorRestoreFailed: LocalizedStringResource {
            LocalizedStringResource("paywall.error.restoreFailed", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Shown when StoreKit transaction verification fails cryptographically. Apple guideline: actionable, never a dead-end "contact support".
         
         Localized string for key “paywall.error.verificationFailed” in table “Paywall.xcstrings”.
         */
        static var paywallErrorVerificationFailed: LocalizedStringResource {
            LocalizedStringResource("paywall.error.verificationFailed", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Body text on the general paywall screen explaining the full unlock.
         
         Localized string for key “paywall.general.body” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBody: LocalizedStringResource {
            LocalizedStringResource("paywall.general.body", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         First feature bullet on the general paywall screen.
         
         Localized string for key “paywall.general.bullet1” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBullet1: LocalizedStringResource {
            LocalizedStringResource("paywall.general.bullet1", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Second feature bullet on the general paywall screen.
         
         Localized string for key “paywall.general.bullet2” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBullet2: LocalizedStringResource {
            LocalizedStringResource("paywall.general.bullet2", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Third feature bullet on the general paywall screen.
         
         Localized string for key “paywall.general.bullet3” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBullet3: LocalizedStringResource {
            LocalizedStringResource("paywall.general.bullet3", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Fourth feature bullet on the general paywall screen.
         
         Localized string for key “paywall.general.bullet4” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBullet4: LocalizedStringResource {
            LocalizedStringResource("paywall.general.bullet4", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Benefit-focused feature bullet on the general paywall screen.
         
         Localized string for key “paywall.general.bullet5” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralBullet5: LocalizedStringResource {
            LocalizedStringResource("paywall.general.bullet5", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Footer text below the feature list on the general paywall screen. Markdown bold markers around numbers are intentional.
         
         Localized string for key “paywall.general.footer” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralFooter: LocalizedStringResource {
            LocalizedStringResource("paywall.general.footer", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Title of the general paywall screen.
         
         Localized string for key “paywall.general.title” in table “Paywall.xcstrings”.
         */
        static var paywallGeneralTitle: LocalizedStringResource {
            LocalizedStringResource("paywall.general.title", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Informational (not an error) — shown when Restore Purchases succeeds but no entitlement exists for this Apple ID. Apple guideline: every tap needs visible, actionable feedback.
         
         Localized string for key “paywall.info.nothingToRestore” in table “Paywall.xcstrings”.
         */
        static var paywallInfoNothingToRestore: LocalizedStringResource {
            LocalizedStringResource("paywall.info.nothingToRestore", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Body text on the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.body” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryBody: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.body", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         First feature bullet on the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.bullet1” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryBullet1: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.bullet1", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Second feature bullet on the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.bullet2” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryBullet2: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.bullet2", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Third feature bullet on the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.bullet3” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryBullet3: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.bullet3", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Fourth feature bullet on the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.bullet4” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryBullet4: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.bullet4", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Title of the Life Story paywall screen.
         
         Localized string for key “paywall.lifeStory.title” in table “Paywall.xcstrings”.
         */
        static var paywallLifeStoryTitle: LocalizedStringResource {
            LocalizedStringResource("paywall.lifeStory.title", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Primary purchase button label on the paywall screen.
         
         Localized string for key “paywall.purchase.button” in table “Paywall.xcstrings”.
         */
        static var paywallPurchaseButton: LocalizedStringResource {
            LocalizedStringResource("paywall.purchase.button", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Button label to dismiss the paywall without purchasing.
         
         Localized string for key “paywall.purchase.notNow” in table “Paywall.xcstrings”.
         */
        static var paywallPurchaseNotNow: LocalizedStringResource {
            LocalizedStringResource("paywall.purchase.notNow", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Price line below the purchase button. Arg 1 is the localized StoreKit price.
         
         Localized string for key “paywall.purchase.priceLine” in table “Paywall.xcstrings”.
         */
        static func paywallPurchasePriceLine(_ arg1: String) -> LocalizedStringResource {
            LocalizedStringResource("paywall.purchase.priceLine", defaultValue: "\(arg1)", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Button label to restore previous purchases on the paywall screen.
         
         Localized string for key “paywall.purchase.restore” in table “Paywall.xcstrings”.
         */
        static var paywallPurchaseRestore: LocalizedStringResource {
            LocalizedStringResource("paywall.purchase.restore", table: "Paywall", bundle: resourceBundleDescription)
        }

        /**
         Fallback tagline shown below the primary purchase button if StoreKit price has not loaded.
         
         Localized string for key “paywall.purchase.tagline” in table “Paywall.xcstrings”.
         */
        static var paywallPurchaseTagline: LocalizedStringResource {
            LocalizedStringResource("paywall.purchase.tagline", table: "Paywall", bundle: resourceBundleDescription)
        }
    }
}