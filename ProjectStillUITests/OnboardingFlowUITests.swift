import XCTest

final class OnboardingFlowUITests: XCTestCase {
    @MainActor
    func testPrimaryRouteReachesPrivacyChoice() throws {
        let app = XCUIApplication()
        app.launch()

        let beginButton = app.buttons["opening.begin"]
        XCTAssertTrue(beginButton.waitForExistence(timeout: 3))
        beginButton.tap()

        XCTAssertTrue(app.staticTexts["How much do you want to share?"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Questionnaire only"].exists)
        XCTAssertTrue(app.staticTexts["Ask your AI"].exists)
    }

    @MainActor
    func testExplanationRouteContinuesToPrivacyChoice() throws {
        let app = XCUIApplication()
        app.launch()

        let learnMoreButton = app.buttons["opening.learnMore"]
        XCTAssertTrue(learnMoreButton.waitForExistence(timeout: 3))
        learnMoreButton.tap()

        let continueButton = app.buttons["howItWorks.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 3))
        continueButton.tap()

        XCTAssertTrue(app.staticTexts["How much do you want to share?"].waitForExistence(timeout: 3))
    }
}

