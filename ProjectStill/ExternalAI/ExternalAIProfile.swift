import Foundation

struct ExternalAIProfilePayload: Codable, Hashable {
    let schemaVersion: Int
    let selfReportSummary: String
    let behavioralSummary: String
    let dimensions: [ExternalAIDimension]
    let keyDisagreements: [String]
    let alternativeInterpretations: [ExternalAIAlternative]
    let overallConfidence: Double
    let limitations: [String]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case selfReportSummary = "self_report_summary"
        case behavioralSummary = "behavioral_summary"
        case dimensions
        case keyDisagreements = "key_disagreements"
        case alternativeInterpretations = "alternative_interpretations"
        case overallConfidence = "overall_confidence"
        case limitations
    }
}

struct ExternalAIDimension: Codable, Hashable {
    let name: String
    let score: Double
    let confidence: Double
    let evidenceSummary: String
    let counterEvidence: String

    private enum CodingKeys: String, CodingKey {
        case name, score, confidence
        case evidenceSummary = "evidence_summary"
        case counterEvidence = "counter_evidence"
    }
}

struct ExternalAIAlternative: Codable, Hashable {
    let label: String
    let confidence: Double
    let reason: String
}

enum ExternalAIValidationError: Error, Equatable, LocalizedError {
    case empty
    case tooLarge
    case invalidJSON
    case unsupportedSchema
    case incompleteDimensions
    case duplicateDimensions
    case unknownDimension(String)
    case outOfRange
    case missingText
    case unsafeLanguage(String)

    var errorDescription: String? {
        switch self {
        case .empty: "Paste the JSON profile first."
        case .tooLarge: "This result is larger than the supported 40 KB profile limit."
        case .invalidJSON: "This is not valid profile JSON. Ask your AI to return only the requested JSON."
        case .unsupportedSchema: "This profile uses an unsupported schema version. Copy the current prompt and try again."
        case .incompleteDimensions: "The profile must contain every requested attention dimension exactly once."
        case .duplicateDimensions: "The profile contains the same dimension more than once."
        case .unknownDimension(let name): "The profile contains an unknown dimension: \(name)."
        case .outOfRange: "Every score and confidence value must be between 0 and 1."
        case .missingText: "A required evidence or summary field is empty."
        case .unsafeLanguage(let term): "The result includes diagnostic or unsafe inference language (‘\(term)’). Ask your AI to follow the non-diagnostic prompt."
        }
    }
}

struct ExternalAIProfileParser {
    static let dimensionNames: [String: AttentionDimension] = [
        "attentional_switching": .attentionalSwitching,
        "focus_persistence": .focusPersistence,
        "associative_branching": .associativeBranching,
        "disengagement_difficulty": .disengagementDifficulty,
        "novelty_dependence": .noveltyDependence,
        "emotional_capture": .emotionalCapture,
        "energy_dullness": .energyDullness,
        "low_stimulation_tolerance": .lowStimulationTolerance,
        "metacognitive_noticing": .metacognitiveNoticing,
        "sensory_orientation": .sensoryOrientation
    ]

    private let maximumBytes = 40_000
    private let unsafeTerms = [
        "adhd", "attention deficit", "anxiety disorder", "depression",
        "autism", "bipolar", "ptsd", "personality disorder", "you have a disorder",
        "diagnosed with", "clinical diagnosis"
    ]

    func parse(_ text: String) throws -> ExternalAIProfilePayload {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ExternalAIValidationError.empty }
        guard trimmed.utf8.count <= maximumBytes else { throw ExternalAIValidationError.tooLarge }
        guard let data = trimmed.data(using: .utf8),
              let payload = try? JSONDecoder().decode(ExternalAIProfilePayload.self, from: data) else {
            throw ExternalAIValidationError.invalidJSON
        }
        guard payload.schemaVersion == 1 else { throw ExternalAIValidationError.unsupportedSchema }
        guard payload.dimensions.count == Self.dimensionNames.count else {
            throw ExternalAIValidationError.incompleteDimensions
        }
        let names = payload.dimensions.map(\.name)
        guard Set(names).count == names.count else { throw ExternalAIValidationError.duplicateDimensions }
        if let unknown = names.first(where: { Self.dimensionNames[$0] == nil }) {
            throw ExternalAIValidationError.unknownDimension(unknown)
        }

        let numericValues = payload.dimensions.flatMap { [$0.score, $0.confidence] }
            + [payload.overallConfidence]
            + payload.alternativeInterpretations.map(\.confidence)
        guard numericValues.allSatisfy({ $0.isFinite && (0...1).contains($0) }) else {
            throw ExternalAIValidationError.outOfRange
        }

        let requiredText = [payload.selfReportSummary, payload.behavioralSummary]
            + payload.dimensions.flatMap { [$0.evidenceSummary, $0.counterEvidence] }
            + payload.alternativeInterpretations.flatMap { [$0.label, $0.reason] }
            + payload.keyDisagreements
            + payload.limitations
        guard requiredText.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.count <= 800 }) else {
            throw ExternalAIValidationError.missingText
        }

        let normalized = requiredText.joined(separator: " ").lowercased()
        if let term = unsafeTerms.first(where: normalized.contains) {
            throw ExternalAIValidationError.unsafeLanguage(term)
        }
        return payload
    }
}

enum ExternalEvidenceConverter {
    static func signals(
        from payload: ExternalAIProfilePayload,
        provider: AIProvider,
        approvedAt: Date,
        userNote: String?
    ) -> [ObservedSignal] {
        payload.dimensions.flatMap { item -> [ObservedSignal] in
            guard let dimension = ExternalAIProfileParser.dimensionNames[item.name] else { return [] }
            let confidence = item.confidence * payload.overallConfidence
            let direction = item.score * 2 - 1
            var result = [
                ObservedSignal(
                    id: "external.\(provider.rawValue).\(item.name).primary",
                    source: .externalAI(provider: provider),
                    questionID: "external.\(item.name)",
                    dimension: dimension,
                    direction: direction,
                    weight: 1,
                    summary: item.evidenceSummary,
                    confidence: confidence,
                    timestamp: approvedAt,
                    category: .behavioralObservation,
                    userApprovedNote: userNote
                )
            ]
            let counter = item.counterEvidence.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedCounter = counter.lowercased()
            if !counter.isEmpty,
               !normalizedCounter.hasPrefix("none"),
               !normalizedCounter.contains("insufficient evidence") {
                result.append(
                    ObservedSignal(
                        id: "external.\(provider.rawValue).\(item.name).counter",
                        source: .externalAI(provider: provider),
                        questionID: "external.\(item.name).counter",
                        dimension: dimension,
                        direction: direction == 0 ? 0 : -direction,
                        weight: 0.25,
                        summary: "Counter-evidence: \(counter)",
                        confidence: confidence,
                        timestamp: approvedAt,
                        category: .behavioralObservation,
                        userApprovedNote: userNote
                    )
                )
            }
            return result
        }
    }
}
