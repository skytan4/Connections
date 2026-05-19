//
//  EntitlementStore.swift
//  Connections
//

import Foundation
import os
import StoreKit

@Observable
@MainActor
final class EntitlementStore {

    // MARK: - Product ID

    /// ⚠️ Replace with your real App Store Connect non-consumable product identifier before shipping.
    static let fullAccessProductID = "connections.full_access"

    private static let logger = Logger(subsystem: "com.tanner.Connections", category: "StoreKit")

    // MARK: - Purchase State

    enum PurchaseState: Equatable {
        case idle
        case loading
        case error(ErrorKind)
        case info(InfoKind)

        enum ErrorKind: Equatable {
            case productUnavailable
            case purchaseFailed
            case verificationFailed
            case restoreFailed
        }

        enum InfoKind: Equatable {
            case nothingToRestore
        }
    }

    // MARK: - Debug Override

    #if DEBUG
    enum DebugOverride: String, CaseIterable {
        case system = "System"
        case forcedFree = "Forced Free"
        case forcedPremium = "Forced Premium"
    }

    var debugOverride: DebugOverride = .system
    #endif

    // MARK: - State

    private(set) var systemEntitlement: Bool = false
    private(set) var purchaseState: PurchaseState = .idle
    private var product: Product?
    private var listenerTask: Task<Void, Never>?

    // MARK: - Effective Premium State

    var isPremium: Bool {
        #if DEBUG
        switch debugOverride {
        case .forcedFree: return false
        case .forcedPremium: return true
        case .system: return systemEntitlement
        }
        #else
        return systemEntitlement
        #endif
    }

    // MARK: - Feature Checks

    var canUseUnfiltered: Bool { isPremium }
    var canUseLongSessions: Bool { isPremium }
    var canUseSex: Bool { isPremium }
    var canUseFallInLove: Bool { isPremium }
    var canUseShareExperience: Bool { isPremium }
    var canUseLifeStory: Bool { isPremium }

    var mixedIntensities: [Intensity] {
        isPremium ? [.light, .honest, .unfiltered] : [.light, .honest]
    }

    // MARK: - Product Display Info

    /// Localized price string from StoreKit, e.g. "$4.99". Nil until product loads.
    var productDisplayPrice: String? { product?.displayPrice }

    // MARK: - Startup

    /// Fetches the full-access product from the App Store. Safe to call multiple times.
    func loadProduct() async {
        guard product == nil else { return }
        do {
            let products = try await Product.products(for: [Self.fullAccessProductID])
            if let loaded = products.first {
                product = loaded
            } else {
                Self.logger.error("Product.products returned empty for ID '\(Self.fullAccessProductID, privacy: .public)'. Check App Store Connect: IAP exists with this exact ID, is in 'Ready to Submit' or higher, Paid Apps Agreement is signed, tax/banking is complete.")
            }
        } catch {
            Self.logger.error("Failed to load product '\(Self.fullAccessProductID, privacy: .public)': \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Checks Transaction.currentEntitlements and sets systemEntitlement accordingly.
    /// Call on app launch and after restore.
    func refreshEntitlements() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fullAccessProductID {
                found = true
                break
            }
        }
        systemEntitlement = found
    }

    /// Starts the long-lived Transaction.updates listener.
    /// Idempotent — safe to call multiple times; listener is started at most once.
    func startTransactionListener() {
        guard listenerTask == nil else { return }
        listenerTask = Task {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                if transaction.productID == Self.fullAccessProductID {
                    systemEntitlement = true
                    await transaction.finish()
                }
                // Unknown product IDs are intentionally left unfinished —
                // a future central transaction router can handle them.
            }
        }
    }

    // MARK: - Test Support

    #if DEBUG
    /// Sets systemEntitlement directly. Use only from tests with debugOverride = .system.
    func simulateEntitlement(_ entitled: Bool) {
        systemEntitlement = entitled
    }
    #endif

    // MARK: - Purchase

    func purchase() async {
        if product == nil {
            await loadProduct()
        }
        guard let product else {
            purchaseState = .error(.productUnavailable)
            return
        }
        purchaseState = .loading
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    Self.logger.error("Purchase verification failed for '\(Self.fullAccessProductID, privacy: .public)'")
                    purchaseState = .error(.verificationFailed)
                    return
                }
                systemEntitlement = true
                await transaction.finish()
                purchaseState = .idle
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            Self.logger.error("Purchase failed: \(error.localizedDescription, privacy: .public)")
            purchaseState = .error(.purchaseFailed)
        }
    }

    // MARK: - Restore

    /// Triggers AppStore.sync() (shows system authentication prompt), then refreshes entitlements.
    func restorePurchases() async {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if systemEntitlement {
                purchaseState = .idle
            } else {
                purchaseState = .info(.nothingToRestore)
            }
        } catch {
            Self.logger.error("Restore failed: \(error.localizedDescription, privacy: .public)")
            purchaseState = .error(.restoreFailed)
        }
    }
}
