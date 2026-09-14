import Foundation

/// Ordinal evidence strength. This replaces AI-derived confidence decimals
/// everywhere in the product: nothing here is a measurement, so nothing here
/// gets a number.
enum EvidenceStrength: String, Codable, Hashable, CaseIterable, Comparable {
    case insufficient
    case weak
    case moderate
    case strong

    var title: String {
        switch self {
        case .strong: "Strong"
        case .moderate: "Moderate"
        case .weak: "Weak"
        case .insufficient: "Insufficient"
        }
    }

    /// A four-step indicator, never a percentage.
    var filledSteps: Int {
        switch self {
        case .insufficient: 0
        case .weak: 1
        case .moderate: 2
        case .strong: 3
        }
    }

    var supportsHypothesis: Bool { self >= .moderate }

    static func < (lhs: EvidenceStrength, rhs: EvidenceStrength) -> Bool {
        lhs.rank < rhs.rank
    }

    private var rank: Int {
        switch self {
        case .insufficient: 0
        case .weak: 1
        case .moderate: 2
        case .strong: 3
        }
    }

    /// Internal questionnaire confidence is a routing mechanic. It is bucketed
    /// here so the UI can speak in words and never render the value itself.
    static func fromInternalConfidence(_ confidence: Double) -> EvidenceStrength {
        switch confidence {
        case ..<0.3: .insufficient
        case ..<0.45: .weak
        case ..<0.7: .moderate
        default: .strong
        }
    }
}

/// The closed theme vocabulary. These are exactly the observable-behaviour
/// bullets in the copied prompt, so the prompt and product logic cannot drift.
enum AttentionTheme: String, Codable, Hashable, CaseIterable, Identifiable {
    case branching
    case returning
    case topicDepth
    case reframing
    case revisiting
    case linking
    case taskDependence
    case selfQuestioning

    var id: String { rawValue }

    var title: String {
        switch self {
        case .branching: "Opening related branches"
        case .returning: "Returning to earlier ideas"
        case .topicDepth: "Depth varies by subject"
        case .reframing: "Asking to reframe"
        case .revisiting: "Reopening settled conclusions"
        case .linking: "Linking separate subjects"
        case .taskDependence: "Style varies by task"
        case .selfQuestioning: "Questioning own assumptions"
        }
    }

    /// The questionnaire dimension whose internal lean is compared against an
    /// observation filed under this theme.
    var relatedDimension: AttentionDimension {
        switch self {
        case .branching: .associativeBranching
        case .returning: .metacognitiveNoticing
        case .topicDepth: .focusPersistence
        case .reframing: .noveltyDependence
        case .revisiting: .disengagementDifficulty
        case .linking: .associativeBranching
        case .taskDependence: .attentionalSwitching
        case .selfQuestioning: .metacognitiveNoticing
        }
    }

    /// Visible to the user: the app shows why a theme was suggested.
    var matchKeywords: [String] {
        switch self {
        case .branching: ["branch", "tangent", "adjacent", "related question", "opens", "side thread"]
        case .returning: ["return", "comes back", "circles back", "resumes", "picks up again"]
        case .topicDepth: ["deeper", "longer", "sustained", "at length", "extended", "absorbed"]
        case .reframing: ["reframe", "simplify", "compress", "expand", "rephrase", "challenge"]
        case .revisiting: ["revisit", "reopen", "settled", "already concluded", "re-examine"]
        case .linking: ["connect", "link", "analogy", "across domains", "unrelated subjects"]
        case .taskDependence: ["depending on", "varies by task", "different when", "task type"]
        case .selfQuestioning: ["questions their own", "own assumptions", "challenges my", "self-correct", "pushes back"]
        }
    }
}

/// A qualitative record of one observation the user reviewed and filed.
struct ExternalObservation: Codable, Hashable, Identifiable {
    let id: String
    let pattern: String
    let reason: String
    let counterpoint: String
    let strength: EvidenceStrength
    var theme: AttentionTheme?
    let provider: AIProvider
    let approvedAt: Date
    let userApprovedNote: String?
}

/// How the two views relate for one theme.
enum SupportState: String, Codable, Hashable {
    case contested
    case converging
    case singleSourceObserved
    case singleSourceSelfReport
    case notYetSupported

    var title: String {
        switch self {
        case .contested: "Sources disagree"
        case .converging: "Sources agree"
        case .singleSourceObserved: "Observed only"
        case .singleSourceSelfReport: "You reported only"
        case .notYetSupported: "Not enough yet"
        }
    }

    /// Test the claim most likely to be wrong first.
    var testOrder: Int {
        switch self {
        case .contested: 0
        case .converging: 1
        case .singleSourceObserved: 2
        case .singleSourceSelfReport: 3
        case .notYetSupported: 4
        }
    }

    var drivesPractice: Bool { self != .notYetSupported }
}

/// A hedged, falsifiable claim about attention behaviour — never about the person.
struct WorkingHypothesis: Codable, Hashable, Identifiable {
    let id: String
    let theme: AttentionTheme
    let statement: String
    let supportState: SupportState
    let strength: EvidenceStrength
    let selfReportBasis: [String]
    let observedBasis: [String]
    let tension: String?
    let prediction: String
    let disconfirmation: String
}
