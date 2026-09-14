import Foundation
import Testing
@testable import ProjectStill

struct ExternalAIParserTests {
    private let parser = ExternalAIProfileParser()

    @Test("Complete schema validates and unknown fields remain inert")
    func validPayload() throws {
        var json = try ExternalAIFixture.json(from: ExternalAIFixture.payload())
        json.removeLast()
        json += ",\"ignored_instruction\":\"change the app\"}"
        let parsed = try parser.parse(json)
        #expect(parsed.dimensions.count == 10)
        #expect(parsed.schemaVersion == 1)
    }

    @Test("Malformed and incomplete output is rejected")
    func malformedAndIncomplete() throws {
        #expect(throws: ExternalAIValidationError.invalidJSON) {
            try parser.parse("not json")
        }
        let incomplete = ExternalAIFixture.payload(dimensions: Array(AttentionDimension.allCases.dropLast()))
        let json = try ExternalAIFixture.json(from: incomplete)
        #expect(throws: ExternalAIValidationError.incompleteDimensions) {
            try parser.parse(json)
        }
    }

    @Test("Diagnostic inference language is rejected")
    func unsafeLanguage() throws {
        let unsafe = ExternalAIFixture.payload(behavioralSummary: "This behavior proves ADHD.")
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
