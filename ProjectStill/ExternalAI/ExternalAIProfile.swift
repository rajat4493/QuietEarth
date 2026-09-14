import Foundation

enum EvidenceStrength: String, CaseIterable, Codable, Hashable {
    case strong
    case moderate
    case weak
    case insufficient

    var title: String { rawValue.capitalized }
}

struct ExternalAISelfReport: Codable, Hashable {
    let statement: String
    let evidenceStrength: EvidenceStrength

    private enum CodingKeys: String, CodingKey {
        case statement
        case evidenceStrength = "evidence_strength"
    }
}

struct ExternalAIObservation: Codable, Hashable {
    let pattern: String
    let evidenceStrength: EvidenceStrength
    let reason: String
    let counterpoint: String

    private enum CodingKeys: String, CodingKey {
        case pattern, reason, counterpoint
        case evidenceStrength = "evidence_strength"
    }
}

struct ExternalAIProfilePayload: Codable, Hashable {
    let schemaVersion: Int
    let selfReport: [ExternalAISelfReport]
    let observations: [ExternalAIObservation]
    let differencesBetweenSelfReportAndObservation: [String]
    let alternativeExplanations: [String]
    let limitations: [String]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case selfReport = "self_report"
        case observations
        case differencesBetweenSelfReportAndObservation = "differences_between_self_report_and_observation"
        case alternativeExplanations = "alternative_explanations"
        case limitations
    }
}

enum ExternalAIValidationError: Error, Equatable, LocalizedError {
    case empty
    case tooLarge
    case invalidJSON
    case unsupportedSchema
    case unexpectedField(String)
    case numericInference(String)
    case incompleteEvidence
    case missingText
    case unsafeLanguage(String)

    var errorDescription: String? {
        switch self {
        case .empty: "Paste the JSON profile first."
        case .tooLarge: "This result is larger than the supported 40 KB profile limit."
        case .invalidJSON: "This is not valid profile JSON. Ask your AI to return only the requested JSON."
        case .unsupportedSchema: "This profile uses an unsupported schema version. Copy the current prompt and try again."
        case .unexpectedField(let field): "The result contains an unsupported field (‘\(field)’). Copy the current prompt and try again."
        case .numericInference(let field): "The result tries to assign a numeric rating (‘\(field)’). QuietEarth accepts qualitative observations only."
        case .incompleteEvidence: "The result needs at least one self-report item, observation, alternative explanation, and limitation."
        case .missingText: "A required statement, reason, counterpoint, or explanation is empty or too long."
        case .unsafeLanguage(let term): "The result includes diagnostic or unsafe inference language (‘\(term)’). Ask your AI to follow the non-diagnostic prompt."
        }
    }
}

struct ExternalAIProfileParser {
    private let maximumBytes = 40_000
    private let allowedTopLevelFields: Set<String> = [
        "schema_version", "self_report", "observations",
        "differences_between_self_report_and_observation",
        "alternative_explanations", "limitations"
    ]
    private let numericInferenceFields: Set<String> = [
        "score", "confidence", "probability", "rating", "percent", "percentage",
        "overall_confidence", "cognitive_score", "psychometric_score"
    ]
    private let unsafeTerms = [
        "adhd", "attention deficit", "anxiety disorder", "depression",
        "autism", "bipolar", "ptsd", "personality disorder", "you have a disorder",
        "diagnosed with", "clinical diagnosis", "cognitive type", "mind type"
    ]

    func parse(_ text: String) throws -> ExternalAIProfilePayload {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ExternalAIValidationError.empty }
        guard trimmed.utf8.count <= maximumBytes else { throw ExternalAIValidationError.tooLarge }
        guard let data = trimmed.data(using: .utf8),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ExternalAIValidationError.invalidJSON
        }

        if let forbidden = firstNumericInferenceField(in: raw) {
            throw ExternalAIValidationError.numericInference(forbidden)
        }
        if let unknown = Set(raw.keys).subtracting(allowedTopLevelFields).sorted().first {
            throw ExternalAIValidationError.unexpectedField(unknown)
        }
        guard (raw["schema_version"] as? NSNumber)?.intValue == 2 else {
            throw ExternalAIValidationError.unsupportedSchema
        }
        guard let payload = try? JSONDecoder().decode(ExternalAIProfilePayload.self, from: data) else {
            throw ExternalAIValidationError.invalidJSON
        }
        guard payload.schemaVersion == 2 else { throw ExternalAIValidationError.unsupportedSchema }
        guard !payload.selfReport.isEmpty,
              !payload.observations.isEmpty,
              !payload.alternativeExplanations.isEmpty,
              !payload.limitations.isEmpty else {
            throw ExternalAIValidationError.incompleteEvidence
        }

        let requiredText = payload.selfReport.map(\.statement)
            + payload.observations.flatMap { [$0.pattern, $0.reason, $0.counterpoint] }
            + payload.differencesBetweenSelfReportAndObservation
            + payload.alternativeExplanations
            + payload.limitations
        guard requiredText.allSatisfy({
            let value = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return !value.isEmpty && value.count <= 800
        }) else {
            throw ExternalAIValidationError.missingText
        }

        let normalized = requiredText.joined(separator: " ").lowercased()
        if let term = unsafeTerms.first(where: normalized.contains) {
            throw ExternalAIValidationError.unsafeLanguage(term)
        }
        return payload
    }

    private func firstNumericInferenceField(in value: Any) -> String? {
        if let dictionary = value as? [String: Any] {
            for key in dictionary.keys.sorted() {
                if numericInferenceFields.contains(key.lowercased()) { return key }
                if key != "schema_version", let number = dictionary[key] as? NSNumber,
                   CFGetTypeID(number) != CFBooleanGetTypeID() {
                    return key
                }
                if let nested = dictionary[key], let found = firstNumericInferenceField(in: nested) {
                    return found
                }
            }
        } else if let array = value as? [Any] {
            for item in array {
                if let found = firstNumericInferenceField(in: item) { return found }
            }
        }
        return nil
    }
}

struct QualitativeEvidenceRecord: Codable, Hashable, Identifiable {
    let id: String
    let source: EvidenceSource
    let timestamp: Date
    let category: EvidenceCategory
    let statement: String
    let strength: EvidenceStrength
    let reason: String?
    let counterpoint: String?
    let userApprovedNote: String?
}

struct ExternalEvidenceBundle: Codable, Hashable {
    let provider: AIProvider
    let records: [QualitativeEvidenceRecord]
    let differences: [String]
    let alternativeExplanations: [String]
    let limitations: [String]
    let approvedAt: Date

    var selfReports: [QualitativeEvidenceRecord] {
        records.filter { $0.category == .selfReport }
    }

    var observations: [QualitativeEvidenceRecord] {
        records.filter { $0.category == .behavioralObservation }
    }
}

enum ExternalEvidenceConverter {
    static func bundle(
        from payload: ExternalAIProfilePayload,
        provider: AIProvider,
        approvedAt: Date,
        userNote: String?
    ) -> ExternalEvidenceBundle {
        let source = EvidenceSource.externalAI(provider: provider)
        let selfReports = payload.selfReport.enumerated().map { index, item in
            QualitativeEvidenceRecord(
                id: "external.\(provider.rawValue).self-report.\(index)",
                source: source,
                timestamp: approvedAt,
                category: .selfReport,
                statement: item.statement,
                strength: item.evidenceStrength,
                reason: nil,
                counterpoint: nil,
                userApprovedNote: userNote
            )
        }
        let observations = payload.observations.enumerated().map { index, item in
            QualitativeEvidenceRecord(
                id: "external.\(provider.rawValue).observation.\(index)",
                source: source,
                timestamp: approvedAt,
                category: .behavioralObservation,
                statement: item.pattern,
                strength: item.evidenceStrength,
                reason: item.reason,
                counterpoint: item.counterpoint,
                userApprovedNote: userNote
            )
        }
        return ExternalEvidenceBundle(
            provider: provider,
            records: selfReports + observations,
            differences: payload.differencesBetweenSelfReportAndObservation,
            alternativeExplanations: payload.alternativeExplanations,
            limitations: payload.limitations,
            approvedAt: approvedAt
        )
    }
}
