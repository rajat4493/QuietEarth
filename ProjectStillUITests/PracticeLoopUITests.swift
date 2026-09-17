import XCTest

/// The core loop: understand → hypothesize → practice → verify → adapt.
final class PracticeLoopUITests: XCTestCase {
    private func launch(_ extraArguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingReset", "-uiTestingSeedProfile"] + extraArguments
        app.launch()
        return app
    }

    @MainActor
    func testProfileOffersAnExperimentWithAStatedRationale() throws {
        let app = launch([])

        let start = app.buttons["profile.startExperiment"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))

        // "Why this practice" must be reachable before committing to a week.
        let why = app.buttons["profile.whyThisPractice"]
        XCTAssertTrue(why.exists)
        why.tap()

        start.tap()
        XCTAssertTrue(app.staticTexts["home.practiceTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["home.dayIndex"].exists)
        XCTAssertEqual(app.staticTexts["home.dayIndex"].label, "Day 1 of 7")
    }

    @MainActor
    func testSessionRunsAndReflectionIsRecorded() throws {
        let app = launch([])
        app.buttons["profile.startExperiment"].tap()

        let begin = app.buttons["home.begin"]
        XCTAssertTrue(begin.waitForExistence(timeout: 5))
        begin.tap()

        // The session shows a step and a countdown, with no streak or score UI.
        XCTAssertTrue(app.staticTexts["session.stepTitle"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["session.remaining"].exists)

        app.buttons["session.end"].tap()
        app.buttons["End and reflect"].tap()

        XCTAssertTrue(app.staticTexts["reflection.title"].waitForExistence(timeout: 5))
        let save = app.buttons["reflection.save"]
        XCTAssertFalse(save.isEnabled, "Saving should require all three answers")

        app.buttons["reflection.notice.many"].tap()
        app.buttons["reflection.return.mixed"].tap()
        app.buttons["reflection.afterward.moreSettled"].tap()
        XCTAssertTrue(save.isEnabled)
        save.tap()

        XCTAssertTrue(app.staticTexts["home.practiceTitle"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDaySevenReviewComparesPredictionWithTheWeek() throws {
        let app = launch(["-uiTestingSeedExperiment", "-uiTestingSeedDaySeven"])

        let review = app.buttons["home.review"]
        XCTAssertTrue(review.waitForExistence(timeout: 5))
        review.tap()

        XCTAssertTrue(app.staticTexts["dayseven.title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["dayseven.verdict"].exists)

        app.buttons["dayseven.continue"].tap()
        XCTAssertTrue(app.staticTexts["home.practiceTitle"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["home.dayIndex"].label, "Day 1 of 7")
    }

    @MainActor
    func testGlobalResetRemovesEverything() throws {
        let app = launch([])
        app.buttons["profile.startExperiment"].tap()
        XCTAssertTrue(app.staticTexts["home.practiceTitle"].waitForExistence(timeout: 5))

        app.buttons["home.settings"].tap()
        app.buttons["settings.reset"].tap()
        app.buttons["Delete everything"].firstMatch.tap()

        // Back to the opening screen with nothing retained.
        XCTAssertTrue(app.buttons["opening.begin"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testNoTraitNumbersAppearInTheLoop() throws {
        let app = launch(["-uiTestingSeedExperiment", "-uiTestingSeedDaySeven"])
        XCTAssertTrue(app.staticTexts["home.practiceTitle"].waitForExistence(timeout: 5))

        // Percentages are the shape the product forbids for traits. Minutes,
        // day counts and session counts are fine.
        for text in app.staticTexts.allElementsBoundByIndex {
            XCTAssertFalse(text.label.contains("%"), "Unexpected percentage in: \(text.label)")
        }
    }
}
