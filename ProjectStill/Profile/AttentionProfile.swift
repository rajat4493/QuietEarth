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
    let confidence: Double
    let timestamp: Date
    let category: EvidenceCategory
    let userApprovedNote: String?

    init(
        id: String,
        source: EvidenceSource,
        questionID: String,
        dimension: AttentionDimension,
        direction: Double,
        weight: Double,
        summary: String,
        confidence: Double = 1,
        timestamp: Date = .now,
        category: EvidenceCategory = .selfReport,
        userApprovedNote: String? = nil
    ) {
        self.id = id
        self.source = source
        self.questionID = questionID
        self.dimension = dimension
        self.direction = direction
        self.weight = weight
        self.summary = summary
        self.confidence = confidence
        self.timestamp = timestamp
        self.category = category
        self.userApprovedNote = userApprovedNote
    }

    private enum CodingKeys: String, CodingKey {
        case id, source, questionID, dimension, direction, weight, summary
        case confidence, timestamp, category, userApprovedNote
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        source = try values.decode(EvidenceSource.self, forKey: .source)
        questionID = try values.decode(String.self, forKey: .questionID)
        dimension = try values.decode(AttentionDimension.self, forKey: .dimension)
        direction = try values.decode(Double.self, forKey: .direction)
        weight = try values.decode(Double.self, forKey: .weight)
        summary = try values.decode(String.self, forKey: .summary)
        confidence = try values.decodeIfPresent(Double.self, forKey: .confidence) ?? 1
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp) ?? .distantPast
        category = try values.decodeIfPresent(EvidenceCategory.self, forKey: .category) ?? .selfReport
        userApprovedNote = try values.decodeIfPresent(String.self, forKey: .userApprovedNote)
    }
}

enum AIProvider: String, CaseIterable, Codable, Hashable, Identifiable {
    case chatGPT
    case claude
    case other

    var id: String { rawValue }
    var title: String {
        switch self {
        case .chatGPT: "ChatGPT"
        case .claude: "Claude"
        case .other: "Other"
        }
    }
}

enum EvidenceSource: Hashable, Codable {
    case questionnaire
    case externalAI(provider: AIProvider)
    case practiceOutcome

    var title: String {
        switch self {
        case .questionnaire: "Questionnaire"
        case .externalAI(let provider): provider.title
        case .practiceOutcome: "Practice outcome"
        }
    }

    var isExternalAI: Bool {
        if case .externalAI = self { return true }
        return false
    }

    private enum CodingKeys: String, CodingKey { case kind, provider }
    private enum Kind: String, Codable { case questionnaire, externalAI, practiceOutcome }

    init(from decoder: Decoder) throws {
        if let legacy = try? decoder.singleValueContainer().decode(String.self), legacy == "questionnaire" {
            self = .questionnaire
            return
        }
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch try values.decode(Kind.self, forKey: .kind) {
        case .questionnaire: self = .questionnaire
        case .practiceOutcome: self = .practiceOutcome
        case .externalAI:
            self = .externalAI(provider: try values.decode(AIProvider.self, forKey: .provider))
        }
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .questionnaire:
            try values.encode(Kind.questionnaire, forKey: .kind)
        case .externalAI(let provider):
            try values.encode(Kind.externalAI, forKey: .kind)
            try values.encode(provider, forKey: .provider)
        case .practiceOutcome:
            try values.encode(Kind.practiceOutcome, forKey: .kind)
        }
    }
}

enum EvidenceCategory: String, Codable, Hashable {
    case selfReport
    case behavioralObservation
    case practiceOutcome
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

enum EvidenceRelationship: String, Codable, Hashable {
    case agreement
    case disagreement
    case singleSource
}

struct SourceComparison: Codable, Hashable, Identifiable {
    var id: AttentionDimension { dimension }
    let dimension: AttentionDimension
    let relationship: EvidenceRelationship
    let questionnaireScore: Double?
    let externalAIScore: Double?
    let questionnaireEvidence: [String]
    let externalAIEvidence: [String]
}

struct AttentionProfile: Codable, Hashable {
    let dimensions: [DimensionAssessment]
    let interpretation: ProfileInterpretation
    let overallConfidence: Double
    let updatedAt: Date
    let sourceComparisons: [SourceComparison]?
    let alternativeInterpretations: [String]?
    let externalSelfReportSummary: String?
    let externalBehavioralSummary: String?

    init(
        dimensions: [DimensionAssessment],
        interpretation: ProfileInterpretation,
        overallConfidence: Double,
        updatedAt: Date,
        sourceComparisons: [SourceComparison]? = nil,
        alternativeInterpretations: [String]? = nil,
        externalSelfReportSummary: String? = nil,
        externalBehavioralSummary: String? = nil
    ) {
        self.dimensions = dimensions
        self.interpretation = interpretation
        self.overallConfidence = overallConfidence
        self.updatedAt = updatedAt
        self.sourceComparisons = sourceComparisons
        self.alternativeInterpretations = alternativeInterpretations
        self.externalSelfReportSummary = externalSelfReportSummary
        self.externalBehavioralSummary = externalBehavioralSummary
    }

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
