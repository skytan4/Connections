//
//  EntitlementStore.swift
//  Connections
//

import Foundation
import StoreKit

@Observable
@MainActor
final class EntitlementStore {

    // MARK: - Product ID

    /// ⚠️ Replace with your real App Store Connect non-consumable product identifier before shipping.
    static let fullAccessProductID = "connections.full_access"

    // MARK: - Beta Unlock

    /// ⚠️ SET TO FALSE BEFORE APP STORE RELEASE.
    /// Grants all premium access during user testing while StoreKit/App Store Connect setup is incomplete.
    /// Does not set systemEntitlement or simulate a purchase — it is a separate build-time gate.
    static let betaUnlockEnabled: Bool = true

    static var betaUnlockAppliesInCurrentBuild: Bool {
        betaUnlockEnabled
    }

    // MARK: - Purchase State

    enum PurchaseState: Equatable {
        case idle
        case loading
        case error(String)
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
        case .system:
            if Self.betaUnlockAppliesInCurrentBuild { return true }
            return systemEntitlement
        }
        #else
        if Self.betaUnlockAppliesInCurrentBuild { return true }
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

    // MARK: - Startup

    /// Fetches the full-access product from the App Store. Safe to call multiple times.
    func loadProduct() async {
        guard product == nil else { return }
        if let loaded = try? await Product.products(for: [Self.fullAccessProductID]).first {
            product = loaded
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
        guard let product else {
            #if DEBUG
            purchaseState = .error("Purchases are not configured in this local build. Use Settings > Debug > Forced Premium to unlock for testing.")
            #else
            purchaseState = .error("Product unavailable. Please try again later.")
            #endif
            return
        }
        purchaseState = .loading
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    purchaseState = .error("Purchase could not be verified. Please contact support.")
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
            purchaseState = .error("Purchase failed. Please try again.")
        }
    }

    // MARK: - Restore

    /// Triggers AppStore.sync() (shows system authentication prompt), then refreshes entitlements.
    func restorePurchases() async {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseState = .idle
        } catch {
            purchaseState = .error("Restore failed. Please try again.")
        }
    }
}
