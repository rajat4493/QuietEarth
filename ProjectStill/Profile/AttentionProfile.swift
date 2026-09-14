import Foundation

enum AttentionDimension: String, CaseIterable, Codable, Hashable, Identifiable {
    case attentionalSwitching
    case focusPersistence
    case associativeBranching
    case disengagementDifficulty
    case noveltyDependence
    case emotionalCapture
    case energyDullness
    case lowStimulationTolerance
    case metacognitiveNoticing
    case sensoryOrientation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .attentionalSwitching: "Attention switching"
        case .focusPersistence: "Focus persistence"
        case .associativeBranching: "Associative branching"
        case .disengagementDifficulty: "Disengagement difficulty"
        case .noveltyDependence: "Novelty dependence"
        case .emotionalCapture: "Emotional capture"
        case .energyDullness: "Energy / dullness"
        case .lowStimulationTolerance: "Low-stimulation tolerance"
        case .metacognitiveNoticing: "Noticing attention"
        case .sensoryOrientation: "Sensory orientation"
        }
    }

    var lowLabel: String {
        switch self {
        case .energyDullness: "More alert"
        case .sensoryOrientation: "More conceptual"
        default: "Lower"
        }
    }

    var highLabel: String {
        switch self {
        case .energyDullness: "More dull"
        case .sensoryOrientation: "More sensory"
        default: "Higher"
        }
    }
}

struct QuestionAnswer: Codable, Hashable {
    let questionID: String
    let optionID: String
    let answeredAt: Date
}

struct ObservedSignal: Codable, Hashable, Identifiable {
    let id: String
    let source: EvidenceSource
    let questionID: String
    let dimension: AttentionDimension
    let direction: Double
    let weight: Double
    let summary: String
}

enum EvidenceSource: String, Codable, Hashable {
    case questionnaire
}

struct DimensionAssessment: Codable, Hashable, Identifiable {
    var id: AttentionDimension { dimension }
    let dimension: AttentionDimension
    let score: Double
    let confidence: Double
    let evidence: [ObservedSignal]
    let contradictions: [String]
}

struct ProfileInterpretation: Codable, Hashable {
    let title: String
    let summary: String
    let reasons: [String]
}

struct AttentionProfile: Codable, Hashable {
    let dimensions: [DimensionAssessment]
    let interpretation: ProfileInterpretation
    let overallConfidence: Double
    let updatedAt: Date

    func assessment(for dimension: AttentionDimension) -> DimensionAssessment {
        dimensions.first { $0.dimension == dimension }
            ?? DimensionAssessment(
                dimension: dimension,
                score: 0.5,
                confidence: 0,
                evidence: [],
                contradictions: []
            )
    }
}

