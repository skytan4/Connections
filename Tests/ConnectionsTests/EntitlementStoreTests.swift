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
        XCTAssertFalse(store.canUseMortalityConversations)
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
        XCTAssertTrue(store.canUseMortalityConversations)
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
        XCTAssertTrue(store.canUseMortalityConversations)
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
        XCTAssertFalse(store.canUseMortalityConversations)
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
        XCTAssertEqual(EntitlementStore.PurchaseState.error(.productUnavailable), .error(.productUnavailable))
        XCTAssertEqual(EntitlementStore.PurchaseState.info(.nothingToRestore), .info(.nothingToRestore))
        XCTAssertNotEqual(EntitlementStore.PurchaseState.idle, .loading)
        XCTAssertNotEqual(EntitlementStore.PurchaseState.error(.productUnavailable), .error(.purchaseFailed))
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
