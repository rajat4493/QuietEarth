import XCTest

final class OnboardingFlowUITests: XCTestCase {
    @MainActor
    func testPrimaryRouteReachesPrivacyChoice() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset"]
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
        app.launchArguments = ["-uiTestingReset"]
        app.launch()

        let learnMoreButton = app.buttons["opening.learnMore"]
        XCTAssertTrue(learnMoreButton.waitForExistence(timeout: 3))
        learnMoreButton.tap()

        let continueButton = app.buttons["howItWorks.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 3))
        continueButton.tap()

        XCTAssertTrue(app.staticTexts["How much do you want to share?"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testQuestionnaireResumesAfterRelaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset"]
        app.launch()
        app.buttons["opening.begin"].tap()
        app.buttons["privacy.questionnaire"].tap()
        XCTAssertTrue(app.buttons["questionnaire.option.0"].waitForExistence(timeout: 3))
        app.buttons["questionnaire.option.0"].tap()

        app.terminate()
        app.launchArguments = []
        app.launch()

        let continueButton = app.buttons["opening.begin"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 3))
        XCTAssertEqual(continueButton.label, "Continue questionnaire")
        continueButton.tap()
        XCTAssertTrue(app.staticTexts["Once something has your interest, how long can you usually stay with it?"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testCompletedProfileSurvivesRelaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset"]
        app.launch()
        app.buttons["opening.begin"].tap()
        app.buttons["privacy.questionnaire"].tap()

        for _ in 0..<12 {
            let option = app.buttons["questionnaire.option.0"]
            XCTAssertTrue(option.waitForExistence(timeout: 3))
            option.tap()
        }

        XCTAssertTrue(app.staticTexts["profile.title"].waitForExistence(timeout: 5))
        let titleBeforeRelaunch = app.staticTexts["profile.title"].label
        app.terminate()
        app.launchArguments = []
        app.launch()

        let persistedTitle = app.staticTexts["profile.title"]
        XCTAssertTrue(persistedTitle.waitForExistence(timeout: 4))
        XCTAssertEqual(persistedTitle.label, titleBeforeRelaunch)
    }

    @MainActor
    func testMalformedExternalAIProfileIsRejected() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset"]
        app.launch()
        app.buttons["opening.begin"].tap()
        app.buttons["privacy.externalAI"].tap()

        let editor = app.textViews["externalAI.jsonEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 3))
        editor.tap()
        editor.typeText("not json")
        app.buttons["externalAI.review"].tap()

        let error = app.staticTexts["externalAI.validationError"]
        XCTAssertTrue(error.waitForExistence(timeout: 3))
        XCTAssertTrue(error.label.contains("not valid profile JSON"))
    }

    @MainActor
    func testSeededQualitativeProfileHasNoPsychometricPercentages() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset", "-uiTestingSeedProfile", "-uiTestingSeedExternal"]
        app.launch()

        XCTAssertTrue(app.staticTexts["profile.title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["profile.hypothesis.difference.0"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS '%'" )).firstMatch.exists)

        app.buttons["profile.compareEvidence"].tap()
        XCTAssertTrue(app.staticTexts["comparison.title"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Where the views differ"].exists)
    }
}
