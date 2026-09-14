import Foundation
import Testing
@testable import ProjectStill

struct ExternalAIParserTests {
    private let parser = ExternalAIProfileParser()

    @Test("Complete schema v2 validates as qualitative evidence")
    func validPayload() throws {
        let parsed = try parser.parse(ExternalAIFixture.json(from: ExternalAIFixture.payload()))
        #expect(parsed.schemaVersion == 2)
        #expect(parsed.observations.first?.evidenceStrength == .moderate)
    }

    @Test("Schema v1 and numeric inference are rejected")
    func numericInferenceRejected() throws {
        let v1 = #"{"schema_version":1,"score":0.8}"#
        #expect(throws: ExternalAIValidationError.numericInference("score")) {
            try parser.parse(v1)
        }

        var v2 = try ExternalAIFixture.json(from: ExternalAIFixture.payload())
        v2.removeLast()
        v2 += #", "confidence": 0.9}"#
        #expect(throws: ExternalAIValidationError.numericInference("confidence")) {
            try parser.parse(v2)
        }
    }

    @Test("Malformed, incomplete, and unknown-strength output is rejected")
    func malformedAndIncomplete() throws {
        #expect(throws: ExternalAIValidationError.invalidJSON) {
            try parser.parse("not json")
        }

        let incomplete = #"{"schema_version":2,"self_report":[],"observations":[],"differences_between_self_report_and_observation":[],"alternative_explanations":[],"limitations":[]}"#
        #expect(throws: ExternalAIValidationError.incompleteEvidence) {
            try parser.parse(incomplete)
        }

        let unknownStrength = try ExternalAIFixture.json(from: ExternalAIFixture.payload())
            .replacingOccurrences(of: "moderate", with: "87-percent")
        #expect(throws: ExternalAIValidationError.invalidJSON) {
            try parser.parse(unknownStrength)
        }
    }

    @Test("Diagnostic inference language is rejected")
    func unsafeLanguage() throws {
        let unsafe = ExternalAIFixture.payload(observationPattern: "This behavior proves ADHD.")
        let json = try ExternalAIFixture.json(from: unsafe)
        #expect(throws: ExternalAIValidationError.unsafeLanguage("adhd")) {
            try parser.parse(json)
        }
    }

    @Test("M1 questionnaire signals decode with default provenance fields")
    func legacySignalCompatibility() throws {
        let json = #"{"id":"legacy","source":"questionnaire","questionID":"switching","dimension":"attentionalSwitching","direction":0.5,"weight":1,"summary":"Legacy evidence."}"#
        let signal = try JSONDecoder().decode(ObservedSignal.self, from: Data(json.utf8))
        #expect(signal.source == .questionnaire)
        #expect(signal.confidence == 1)
        #expect(signal.category == .selfReport)
        #expect(signal.timestamp == .distantPast)
    }
}
