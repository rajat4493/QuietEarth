import Foundation

enum AppRoute: Hashable {
    case howItWorks
    case privacyChoice
    case questionnaire
    case externalAIIntake
    case profile
    case practiceSession
    case reflection(completedSeconds: Int)
    case daySevenReview
    case settings

    var accessibilityTitle: String {
        switch self {
        case .howItWorks: "How this works"
        case .privacyChoice: "Choose what to share"
        case .questionnaire: "Questionnaire"
        case .externalAIIntake: "Use your AI"
        case .profile: "Your profile"
        case .practiceSession: "Practice session"
        case .reflection: "Reflection"
        case .daySevenReview: "Day seven review"
        case .settings: "Settings"
        }
    }
}
