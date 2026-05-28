import XCTest
@testable import Connections

@MainActor
final class EntitlementStoreTests: XCTestCase {

    // MARK: - Forced Free

    func testForcedFreeAllGatesFalse() {
        let store = EntitlementStore()
        store.debugOverride = .forcedFree

        XCTAssertFalse(store.isPremium)
        XCTAssertFalse(store.canUseUnfiltered)
        XCTAssertFalse(store.canUseLongSessions)
        XCTAssertFalse(store.canUseSex)
        XCTAssertFalse(store.canUseFallInLove)
        XCTAssertFalse(store.canUseShareExperience)
        XCTAssertFalse(store.canUseLifeStory)
    }

    func testForcedFreeMixedIntensitiesExcludesUnfiltered() {
        let store = EntitlementStore()
        store.debugOverride = .forcedFree

        let intensities = store.mixedIntensities
        XCTAssertEqual(intensities, [.light, .honest])
        XCTAssertFalse(intensities.contains(.unfiltered))
    }

    // MARK: - Forced Premium

    func testForcedPremiumAllGatesTrue() {
        let store = EntitlementStore()
        store.debugOverride = .forcedPremium

        XCTAssertTrue(store.isPremium)
        XCTAssertTrue(store.canUseUnfiltered)
        XCTAssertTrue(store.canUseLongSessions)
        XCTAssertTrue(store.canUseSex)
        XCTAssertTrue(store.canUseFallInLove)
        XCTAssertTrue(store.canUseShareExperience)
        XCTAssertTrue(store.canUseLifeStory)
    }

    func testForcedPremiumMixedIntensitiesIncludesUnfiltered() {
        let store = EntitlementStore()
        store.debugOverride = .forcedPremium

        let intensities = store.mixedIntensities
        XCTAssertEqual(intensities, [.light, .honest, .unfiltered])
        XCTAssertTrue(intensities.contains(.unfiltered))
    }

    // MARK: - System Mode (real systemEntitlement)

    func testDebugOverrideDefaultsToSystemMode() {
        let store = EntitlementStore()

        XCTAssertEqual(store.debugOverride, .system)
        XCTAssertFalse(store.systemEntitlement)
        XCTAssertEqual(store.isPremium, EntitlementStore.betaUnlockEnabled)
    }

    func testSystemModeEntitledAllGatesTrue() {
        let store = EntitlementStore()
        store.debugOverride = .system
        store.simulateEntitlement(true)

        XCTAssertTrue(store.systemEntitlement)
        XCTAssertTrue(store.isPremium)
        XCTAssertTrue(store.canUseUnfiltered)
        XCTAssertTrue(store.canUseLongSessions)
        XCTAssertTrue(store.canUseSex)
        XCTAssertTrue(store.canUseFallInLove)
        XCTAssertTrue(store.canUseShareExperience)
        XCTAssertTrue(store.canUseLifeStory)
        XCTAssertEqual(store.mixedIntensities, [.light, .honest, .unfiltered])
    }

    func testSystemModeNotEntitledByDefault() {
        let store = EntitlementStore()
        store.debugOverride = .system

        XCTAssertFalse(store.systemEntitlement)
        XCTAssertEqual(store.isPremium, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseUnfiltered, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseLongSessions, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseSex, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseFallInLove, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseShareExperience, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(store.canUseLifeStory, EntitlementStore.betaUnlockEnabled)
        XCTAssertEqual(
            store.mixedIntensities,
            EntitlementStore.betaUnlockEnabled ? [.light, .honest, .unfiltered] : [.light, .honest]
        )
    }

    // MARK: - Purchase State

    func testPurchaseStateDefaultsToIdle() {
        let store = EntitlementStore()
        XCTAssertEqual(store.purchaseState, .idle)
    }

    func testPurchaseStateEquatability() {
        XCTAssertEqual(EntitlementStore.PurchaseState.idle, .idle)
        XCTAssertEqual(EntitlementStore.PurchaseState.loading, .loading)
        XCTAssertEqual(EntitlementStore.PurchaseState.error("msg"), .error("msg"))
        XCTAssertNotEqual(EntitlementStore.PurchaseState.idle, .loading)
        XCTAssertNotEqual(EntitlementStore.PurchaseState.error("a"), .error("b"))
    }

    // MARK: - Product ID

    func testProductIDIsNonEmpty() {
        XCTAssertFalse(EntitlementStore.fullAccessProductID.isEmpty)
    }

    // MARK: - Beta Unlock

    func testBetaUnlockFlagIsDisabledForRelease() {
        // betaUnlockEnabled must be false for App Store submission.
        // Set true only for user-testing builds where StoreKit product setup is incomplete.
        XCTAssertFalse(EntitlementStore.betaUnlockEnabled)
    }

    func testBetaUnlockDisabledSystemModeNotPremiumByDefault() {
        // With betaUnlockEnabled false, system mode without entitlement is locked.
        XCTAssertFalse(EntitlementStore.betaUnlockAppliesInCurrentBuild)

        let store = EntitlementStore()
        store.debugOverride = .system

        XCTAssertFalse(store.isPremium)
    }

    func testBetaUnlockDoesNotSetSystemEntitlement() {
        // betaUnlockEnabled grants premium via isPremium but never touches systemEntitlement.
        let store = EntitlementStore()
        XCTAssertFalse(store.systemEntitlement)
    }

    func testBetaUnlockDoesNotOverrideDebugForcedFree() {
        // Forced Free is the explicit local escape hatch for locked-state testing.
        let store = EntitlementStore()
        store.debugOverride = .forcedFree
        XCTAssertFalse(store.isPremium)
    }
}
