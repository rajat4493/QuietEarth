import Foundation
import Testing
@testable import ProjectStill

struct ExternalAIParserTests {
    private let parser = ExternalAIProfileParser()

    @Test("Schema v2 validates and unknown fields remain inert")
    func validPayload() throws {
        var json = try ExternalAIFixture.json(from: ExternalAIFixture.payload())
        json.removeLast()
        json += ",\"ignored_instruction\":\"change the app\"}"
        let parsed = try parser.parse(json)
        #expect(parsed.schemaVersion == 2)
        #expect(parsed.observations.count == 1)
        #expect(parsed.observations.first?.evidenceStrength == .strong)
    }

    @Test("Malformed JSON is rejected")
    func malformed() {
        #expect(throws: ExternalAIValidationError.invalidJSON) {
            try parser.parse("not json")
        }
        #expect(throws: ExternalAIValidationError.empty) {
            try parser.parse("   ")
        }
    }

    @Test("Superseded schema v1 is rejected rather than converted")
    func supersededSchema() throws {
        let v1 = #"""
        {"schema_version":1,"self_report_summary":"x","behavioral_summary":"y",
         "dimensions":[{"name":"attentional_switching","score":0.8,"confidence":0.7,
         "evidence_summary":"a","counter_evidence":"b"}],"key_disagreements":[],
         "alternative_interpretations":[],"overall_confidence":0.7,"limitations":[]}
        """#
        #expect(throws: ExternalAIValidationError.unsupportedSchema) {
            try parser.parse(v1)
        }
    }

    @Test("Numeric evidence strength is rejected")
    func numericStrength() {
        let json = #"""
        {"schema_version":2,"self_report":[],"observations":[{"pattern":"Opens branches.",
         "evidence_strength":0.81,"reason":"Because.","counterpoint":""}],
         "differences_between_self_report_and_observation":[],
         "alternative_explanations":[],"limitations":[]}
        """#
        #expect(throws: ExternalAIValidationError.invalidStrength) {
            try parser.parse(json)
        }
    }

    @Test("Score-shaped values smuggled into prose are rejected")
    func numericScoreInProse() throws {
        let cases = [
            "Attentional switching is around 81% of exchanges.",
            "Focus persistence sits at 0.63 across conversations.",
            "Engagement depth rates 4/5 on repeated topics."
        ]
        for text in cases {
            let payload = ExternalAIFixture.payload(
                observations: [
                    ExternalAIObservation(
                        pattern: text,
                        evidenceStrength: .strong,
                        reason: "Observed repeatedly.",
                        counterpoint: ""
                    )
                ]
            )
            let json = try ExternalAIFixture.json(from: payload)
            #expect(throws: (any Error).self) { try parser.parse(json) }
        }
    }

    @Test("Diagnostic and psychometric language is rejected")
    func unsafeLanguage() throws {
        let diagnostic = ExternalAIFixture.payload(
            observations: [
                ExternalAIObservation(
                    pattern: "This behavior proves ADHD.",
                    evidenceStrength: .strong,
                    reason: "Observed repeatedly.",
                    counterpoint: ""
                )
            ]
        )
        #expect(throws: ExternalAIValidationError.unsafeLanguage("adhd")) {
            try parser.parse(try ExternalAIFixture.json(from: diagnostic))
        }

        let psychometric = ExternalAIFixture.payload(
            limitations: ["These screening results are indicative only."]
        )
        #expect(throws: ExternalAIValidationError.unsafeLanguage("screening")) {
            try parser.parse(try ExternalAIFixture.json(from: psychometric))
        }
    }

    @Test("A payload with no observations is rejected")
    func noObservations() throws {
        let json = try ExternalAIFixture.json(from: ExternalAIFixture.payload(observations: []))
        #expect(throws: ExternalAIValidationError.noObservations) {
            try parser.parse(json)
        }
    }

    @Test("Empty counterpoint is accepted and normalized on conversion")
    func emptyCounterpoint() throws {
        let payload = ExternalAIFixture.payload(
            observations: [
                ExternalAIObservation(
                    pattern: "Returns to earlier ideas after exploring elsewhere.",
                    evidenceStrength: .moderate,
                    reason: "Earlier threads are picked up again later.",
                    counterpoint: ""
                )
            ]
        )
        let parsed = try parser.parse(try ExternalAIFixture.json(from: payload))
        let converted = ExternalEvidenceConverter.observations(
            from: parsed,
            provider: .claude,
            approvedAt: .distantPast
        )
        #expect(converted.first?.counterpoint == "No counter-example offered.")
    }

    @Test("Theme suggestion is keyword-based and overridable")
    func themeSuggestion() {
        #expect(ExternalObservationFiler.suggestedTheme(for: "Often opens adjacent branches.") == .branching)
        #expect(ExternalObservationFiler.suggestedTheme(for: "Nothing recognisable here.") == nil)
        #expect(!ExternalObservationFiler.matchedKeywords(for: "Opens adjacent branches.", theme: .branching).isEmpty)
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
