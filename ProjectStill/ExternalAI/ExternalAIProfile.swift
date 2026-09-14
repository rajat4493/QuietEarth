import Foundation

// Schema version 2 (M1.6). External assistants describe observable
// conversational behaviour. They return no numbers, and nothing here converts
// their text into a score.

struct ExternalAIPayload: Codable, Hashable {
    let schemaVersion: Int
    let selfReport: [ExternalAISelfReport]
    let observations: [ExternalAIObservation]
    let differences: [String]
    let alternativeExplanations: [String]
    let limitations: [String]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case selfReport = "self_report"
        case observations
        case differences = "differences_between_self_report_and_observation"
        case alternativeExplanations = "alternative_explanations"
        case limitations
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.decode(Int.self, forKey: .schemaVersion)
        selfReport = try values.decodeIfPresent([ExternalAISelfReport].self, forKey: .selfReport) ?? []
        observations = try values.decodeIfPresent([ExternalAIObservation].self, forKey: .observations) ?? []
        differences = try values.decodeIfPresent([String].self, forKey: .differences) ?? []
        alternativeExplanations = try values.decodeIfPresent([String].self, forKey: .alternativeExplanations) ?? []
        limitations = try values.decodeIfPresent([String].self, forKey: .limitations) ?? []
    }

    init(
        schemaVersion: Int = 2,
        selfReport: [ExternalAISelfReport] = [],
        observations: [ExternalAIObservation] = [],
        differences: [String] = [],
        alternativeExplanations: [String] = [],
        limitations: [String] = []
    ) {
        self.schemaVersion = schemaVersion
        self.selfReport = selfReport
        self.observations = observations
        self.differences = differences
        self.alternativeExplanations = alternativeExplanations
        self.limitations = limitations
    }
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
        case pattern
        case evidenceStrength = "evidence_strength"
        case reason
        case counterpoint
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pattern = try values.decode(String.self, forKey: .pattern)
        evidenceStrength = try values.decode(EvidenceStrength.self, forKey: .evidenceStrength)
        reason = try values.decode(String.self, forKey: .reason)
        counterpoint = try values.decodeIfPresent(String.self, forKey: .counterpoint) ?? ""
    }

    init(pattern: String, evidenceStrength: EvidenceStrength, reason: String, counterpoint: String) {
        self.pattern = pattern
        self.evidenceStrength = evidenceStrength
        self.reason = reason
        self.counterpoint = counterpoint
    }
}

enum ExternalAIValidationError: Error, Equatable, LocalizedError {
    case empty
    case tooLarge
    case invalidJSON
    case unsupportedSchema
    case noObservations
    case tooManyEntries
    case invalidStrength
    case missingText
    case numericScore(String)
    case unsafeLanguage(String)

    var errorDescription: String? {
        switch self {
        case .empty:
            "Paste the JSON result first."
        case .tooLarge:
            "This result is larger than the supported 40 KB limit."
        case .invalidJSON:
            "This is not valid JSON. Ask your AI to return only the requested JSON."
        case .unsupportedSchema:
            "This prompt has been replaced. Copy the current prompt and run it again."
        case .noObservations:
            "The result contains no observations."
        case .tooManyEntries:
            "The result contains more entries than this app accepts (12 per section)."
        case .invalidStrength:
            "Evidence strength must be strong, moderate, weak, or insufficient — not a number or a rating."
        case .missingText:
            "A required field is empty or longer than 600 characters."
        case .numericScore(let found):
            "This result contains a score-like value (‘\(found)’). QuietEarth does not accept numeric ratings of you — ask your AI to describe what it observes instead."
        case .unsafeLanguage(let term):
            "The result includes diagnostic or assessment language (‘\(term)’). Ask your AI to follow the prompt exactly."
        }
    }
}

struct ExternalAIProfileParser {
    private let maximumBytes = 40_000
    private let maximumEntries = 12
    private let maximumFieldLength = 600

    /// Diagnostic language, plus the psychometric vocabulary added at M1.6.
    private let unsafeTerms = [
        "adhd", "attention deficit", "anxiety disorder", "depression",
        "autism", "bipolar", "ptsd", "personality disorder", "you have a disorder",
        "diagnosed with", "clinical diagnosis", "clinically",
        "percentile", "score of", "rating of", "assessment indicates",
        "test results", "screening"
    ]

    /// The schema carries no numbers. Numbers smuggled into prose are numbers
    /// all the same, so they are rejected rather than stripped.
    private static let numericPatterns = [
        #"\b\d{1,3}\s?%"#,
        #"\b0\.\d+\b"#,
        #"\b\d(?:\.\d+)?\s*/\s*(?:5|7|10|100)\b"#,
        #"\b(?:top|bottom)\s+\w+\s+(?:percentile|decile|quartile)\b"#
    ]

    func parse(_ text: String) throws -> ExternalAIPayload {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ExternalAIValidationError.empty }
        guard trimmed.utf8.count <= maximumBytes else { throw ExternalAIValidationError.tooLarge }
        guard let data = trimmed.data(using: .utf8) else { throw ExternalAIValidationError.invalidJSON }

        let payload: ExternalAIPayload
        do {
            payload = try JSONDecoder().decode(ExternalAIPayload.self, from: data)
        } catch let error as DecodingError {
            throw Self.validationError(for: error, data: data)
        } catch {
            throw ExternalAIValidationError.invalidJSON
        }

        guard payload.schemaVersion == 2 else { throw ExternalAIValidationError.unsupportedSchema }
        guard !payload.observations.isEmpty else { throw ExternalAIValidationError.noObservations }
        guard payload.observations.count <= maximumEntries,
              payload.selfReport.count <= maximumEntries,
              payload.differences.count <= maximumEntries,
              payload.alternativeExplanations.count <= maximumEntries,
              payload.limitations.count <= maximumEntries else {
            throw ExternalAIValidationError.tooManyEntries
        }

        let requiredText = payload.observations.flatMap { [$0.pattern, $0.reason] }
            + payload.selfReport.map(\.statement)
            + payload.differences
            + payload.alternativeExplanations
            + payload.limitations
        guard requiredText.allSatisfy({
            let value = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return !value.isEmpty && value.count <= maximumFieldLength
        }) else {
            throw ExternalAIValidationError.missingText
        }
        guard payload.observations.allSatisfy({ $0.counterpoint.count <= maximumFieldLength }) else {
            throw ExternalAIValidationError.missingText
        }

        let allText = (requiredText + payload.observations.map(\.counterpoint)).joined(separator: " ")
        if let found = Self.firstNumericScore(in: allText) {
            throw ExternalAIValidationError.numericScore(found)
        }
        let normalized = allText.lowercased()
        if let term = unsafeTerms.first(where: normalized.contains) {
            throw ExternalAIValidationError.unsafeLanguage(term)
        }
        return payload
    }

    static func firstNumericScore(in text: String) -> String? {
        for pattern in numericPatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            if let match = regex.firstMatch(in: text, range: range),
               let matched = Range(match.range, in: text) {
                return String(text[matched])
            }
        }
        return nil
    }

    /// An `evidence_strength` that is a number or an unexpected word is the most
    /// likely decoding failure, so it gets its own message rather than "invalid JSON".
    private static func validationError(for error: DecodingError, data: Data) -> ExternalAIValidationError {
        if case .dataCorrupted(let context) = error,
           context.codingPath.contains(where: { $0.stringValue == "evidence_strength" }) {
            return .invalidStrength
        }
        if case .typeMismatch(_, let context) = error,
           context.codingPath.contains(where: { $0.stringValue == "evidence_strength" }) {
            return .invalidStrength
        }
        guard let object = try? JSONSerialization.jsonObject(with: data),
              let root = object as? [String: Any] else {
            return .invalidJSON
        }
        if let version = root["schema_version"] as? Int, version != 2 {
            return .unsupportedSchema
        }
        // The v1 scoring payload: reject it as superseded rather than "malformed".
        if root["dimensions"] != nil {
            return .unsupportedSchema
        }
        // The likeliest v2 failure is a strength that is a number or an
        // unexpected word. The coding path is not reliable across decoders, so
        // the raw value is checked directly.
        let entries = (root["observations"] as? [[String: Any]] ?? [])
            + (root["self_report"] as? [[String: Any]] ?? [])
        let valid = Set(EvidenceStrength.allCases.map(\.rawValue))
        for entry in entries {
            guard let raw = entry["evidence_strength"] else { continue }
            if let text = raw as? String, valid.contains(text) { continue }
            return .invalidStrength
        }
        return .invalidJSON
    }
}

/// Converts an approved payload into qualitative records. Nothing here produces
/// an `ObservedSignal`: external text never enters the questionnaire scoring engine.
enum ExternalEvidenceConverter {
    static func observations(
        from payload: ExternalAIPayload,
        provider: AIProvider,
        approvedAt: Date,
        themes: [Int: AttentionTheme?] = [:],
        userNote: String? = nil
    ) -> [ExternalObservation] {
        payload.observations.enumerated().map { index, item in
            ExternalObservation(
                id: "external.\(provider.rawValue).\(index)",
                pattern: item.pattern,
                reason: item.reason,
                counterpoint: item.counterpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "No counter-example offered."
                    : item.counterpoint,
                strength: item.evidenceStrength,
                theme: themes[index] ?? ExternalObservationFiler.suggestedTheme(for: item.pattern),
                provider: provider,
                approvedAt: approvedAt,
                userApprovedNote: userNote
            )
        }
    }
}

/// Suggests a theme from a small, visible keyword list. The user confirms or
/// reassigns it — nothing is filed into product logic unconfirmed.
enum ExternalObservationFiler {
    static func suggestedTheme(for pattern: String) -> AttentionTheme? {
        let text = pattern.lowercased()
        let best = AttentionTheme.allCases
            .map { theme in (theme, theme.matchKeywords.filter(text.contains).count) }
            .filter { $0.1 > 0 }
            .max { $0.1 < $1.1 }
        return best?.0
    }

    static func matchedKeywords(for pattern: String, theme: AttentionTheme) -> [String] {
        let text = pattern.lowercased()
        return theme.matchKeywords.filter(text.contains)
    }
}
