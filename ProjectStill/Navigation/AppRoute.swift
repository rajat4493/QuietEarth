import Foundation

enum AppRoute: Hashable {
    case howItWorks
    case privacyChoice
    case questionnaire

    var accessibilityTitle: String {
        switch self {
        case .howItWorks:
            "How this works"
        case .privacyChoice:
            "Choose what to share"
        case .questionnaire:
            "Questionnaire"
        }
    }
}
