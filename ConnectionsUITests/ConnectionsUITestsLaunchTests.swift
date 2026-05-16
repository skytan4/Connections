//
//  ConnectionsUITestsLaunchTests.swift
//  ConnectionsUITests
//

import XCTest

final class AppStoreScreenshots: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-SkipOnboarding"]
        app.launch()
    }

    @MainActor
    func testCaptureScreenshots() throws {

        // 1 — Home screen
        snapshot("01-home")

        // 2 — Mode selection (tap "Start a session")
        let startButton = app.buttons["home.startSession"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5), "Start a session button not found")
        startButton.tap()
        snapshot("02-modes")

        // 3 — Intensity selection (tap Couples)
        let couplesCard = app.buttons["mode.Couples"]
        XCTAssertTrue(couplesCard.waitForExistence(timeout: 5), "Couples card not found")
        couplesCard.tap()
        snapshot("03-intensity")

        // 4 — Paywall (tap Unfiltered, which requires premium)
        let unfilteredCard = app.buttons["intensity.Unfiltered"]
        XCTAssertTrue(unfilteredCard.waitForExistence(timeout: 5), "Unfiltered card not found")
        unfilteredCard.tap()
        snapshot("06-paywall")

        // Dismiss paywall
        let notNow = app.buttons["paywall.notNow"]
        XCTAssertTrue(notNow.waitForExistence(timeout: 5), "Not now button not found")
        notNow.tap()

        // 5 — Session prompt (tap Honest → Start Session)
        let honestCard = app.buttons["intensity.Honest"]
        XCTAssertTrue(honestCard.waitForExistence(timeout: 5), "Honest card not found")
        honestCard.tap()

        let startSession = app.buttons["startSessionButton"]
        XCTAssertTrue(startSession.waitForExistence(timeout: 5), "Start Session button not found")
        startSession.tap()

        let promptText = app.staticTexts["promptText"]
        XCTAssertTrue(promptText.waitForExistence(timeout: 5), "Prompt text not found")
        snapshot("04-prompt")

        // 6 — Follow-up / Go deeper (tap if available)
        let goDeeper = app.buttons["goDeeperButton"]
        if goDeeper.waitForExistence(timeout: 3) {
            goDeeper.tap()
            snapshot("05-deeper")
        } else {
            // Advance one prompt so the follow-up appears
            let nextButton = app.buttons["nextPromptButton"]
            if nextButton.waitForExistence(timeout: 3) {
                nextButton.tap()
                _ = app.staticTexts["promptText"].waitForExistence(timeout: 3)
                if goDeeper.waitForExistence(timeout: 3) {
                    goDeeper.tap()
                }
            }
            snapshot("05-deeper")
        }
    }
}
