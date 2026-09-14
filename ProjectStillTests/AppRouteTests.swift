import Testing
@testable import ProjectStill

struct AppRouteTests {
    @Test("Every M0 route has a meaningful accessibility title")
    func routeAccessibilityTitles() {
        #expect(AppRoute.howItWorks.accessibilityTitle == "How this works")
        #expect(AppRoute.privacyChoice.accessibilityTitle == "Choose what to share")
        #expect(AppRoute.questionnaire.accessibilityTitle == "Questionnaire")
    }
}

