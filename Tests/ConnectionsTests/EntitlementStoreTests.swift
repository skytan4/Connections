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
        XCTAssertFalse(store.isPremium)
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
        XCTAssertFalse(store.isPremium)
        XCTAssertFalse(store.canUseUnfiltered)
        XCTAssertFalse(store.canUseLongSessions)
        XCTAssertFalse(store.canUseSex)
        XCTAssertFalse(store.canUseFallInLove)
        XCTAssertFalse(store.canUseShareExperience)
        XCTAssertFalse(store.canUseLifeStory)
        XCTAssertEqual(store.mixedIntensities, [.light, .honest])
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

    // MARK: - Debug Override Safety

    func testForcedFreeRemainsLocked() {
        let store = EntitlementStore()
        store.debugOverride = .forcedFree
        XCTAssertFalse(store.isPremium)
    }
}
