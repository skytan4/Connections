//
//  ConnectionsUITestsLaunchTests.swift
//  ConnectionsUITests
//

import XCTest

@MainActor
final class AppStoreScreenshots: XCTestCase {

    var app: XCUIApplication!
    var snapshotLaunchArguments: [String] = []

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        snapshotLaunchArguments = app.launchArguments
    }

    @MainActor
    func testCaptureScreenshots() throws {
        launchApp(forcePremium: false)

        // 1 - Home screen.
        snapshot("01-home")

        // 2 - Full mode picker.
        openSessionBuilder()
        snapshot("02-modes")

        // 6 - Free user taps a Premium area and sees the full-product paywall.
        tap("mode.Couples")
        tap("intensity.Unfiltered")
        waitFor("paywall.notNow")
        snapshot("06-paywall")

        // 3 and 8 - Premium standard session, including Go deeper, a favorite,
        // and a completed session summary.
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.Couples")
        tap("intensity.Honest")
        tap("sessionLength.5")
        tap("startSessionButton")
        waitFor("promptText")
        snapshot("04-prompt")

        tap("favoritePromptButton")
        if app.buttons["goDeeperButton"].waitForExistence(timeout: 3) {
            app.buttons["goDeeperButton"].tap()
            waitBriefly()
        }

        completeShortSession()
        waitFor("sessionSummary", timeout: 8)
        snapshot("05-session-summary")

        // 4 - Premium Share Experiences.
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.ShareExperiences")
        waitFor("shareExperienceText")
        snapshot("07-share-experiences")

        // 5 - Premium Life Story.
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.LifeStory")
        waitFor("lifeStoryIntro.title")
        snapshot("08-life-history")

        // 7 - Premium Unfiltered prompt.
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.Couples")
        tap("intensity.Unfiltered")
        tap("sessionLength.5")
        tap("startSessionButton")
        waitFor("promptText")
        snapshot("09-premium-unfiltered")

        // 8 - Premium Mortality Conversations prompt.
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.MortalityConversations", scrollIfNeeded: true)
        waitFor("startMortalitySessionButton")
        tap("mortalityTopic.allTopics")
        tap("mortalitySessionLength.5")
        tap("startMortalitySessionButton")
        waitFor("mortalityPromptText")
        snapshot("10-mortality-question")
    }

    @MainActor
    func testCaptureSessionSetupScreenshot() throws {
        launchApp(forcePremium: true)
        openSessionBuilder()
        tap("mode.Couples")
        tap("intensity.Honest")
        tap("sessionLength.10")
        snapshot("03-session-setup")
    }

    private func launchApp(forcePremium: Bool) {
        if app.state != .notRunning {
            app.terminate()
        }
        app.launchArguments = snapshotLaunchArguments + [
            "-SkipOnboarding",
            forcePremium ? "-ForcePremiumForScreenshots" : "-ForceFreeForScreenshots"
        ]
        app.launch()
        waitFor("home.startSession")
    }

    private func openSessionBuilder() {
        tap("home.startSession")
        waitFor("mode.Couples")
    }

    private func completeShortSession() {
        for _ in 0..<5 {
            tap("nextPromptButton")
            waitBriefly()
        }
    }

    private func tap(_ identifier: String, timeout: TimeInterval = 5, scrollIfNeeded: Bool = false) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "\(identifier) button not found")
        if scrollIfNeeded && !button.isHittable {
            app.swipeUp()
            waitBriefly()
        }
        XCTAssertTrue(button.isHittable, "\(identifier) button not hittable")
        button.tap()
    }

    private func waitFor(_ identifier: String, timeout: TimeInterval = 5) {
        let element = app.descendants(matching: .any)[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "\(identifier) not found")
    }

    private func waitBriefly() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
    }
}
