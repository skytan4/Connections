import XCTest

@MainActor
final class SnapshotTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }

    func testCaptureScreenshots() throws {
        dismissOnboardingIfPresent()

        // 1 — Home
        XCTAssert(app.staticTexts["Connections"].waitForExistence(timeout: 5))
        snapshot("01_Home")

        // 2 — Mode selection
        app.buttons["Start a session"].tap()
        XCTAssert(app.staticTexts["Choose a mode"].waitForExistence(timeout: 3))
        snapshot("02_ModeSelection")

        // 3 — Intensity selection
        app.staticTexts["Couples"].tap()
        XCTAssert(app.staticTexts["Set the tone"].waitForExistence(timeout: 3))
        snapshot("03_Intensity")
    }

    private func dismissOnboardingIfPresent() {
        let skip = app.buttons["Skip"]
        if skip.waitForExistence(timeout: 2) {
            skip.tap()
        }
    }
}
