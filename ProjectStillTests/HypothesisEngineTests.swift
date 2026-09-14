import Foundation
import Testing
@testable import ProjectStill

struct HypothesisEngineTests {
    @Test("Questionnaire hypothesis has a prediction and disconfirmation")
    func questionnaireHypothesisIsFalsifiable() throws {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "branching", optionID: "many", answeredAt: .distantPast)
        ]
        let profile = ProfileEngine().makeProfile(from: answers, now: .distantPast)
        let hypothesis = try #require(HypothesisEngine().hypotheses(for: profile).first)

        #expect(hypothesis.support == .questionnaire)
        #expect(!hypothesis.prediction.isEmpty)
        #expect(!hypothesis.disconfirmation.isEmpty)
    }

    @Test("Explicit differences are tested first and not averaged")
    func contestedHypothesisComesFirst() throws {
        let bundle = ExternalEvidenceConverter.bundle(
            from: ExternalAIFixture.payload(),
            provider: .chatGPT,
            approvedAt: .distantPast,
            userNote: nil
        )
        let profile = ProfileEngine().makeProfile(from: [], externalEvidence: bundle, now: .distantPast)
        let hypotheses = HypothesisEngine().hypotheses(for: profile)

        #expect(hypotheses.first?.support == .contested)
        #expect(hypotheses.first?.statement == bundle.differences.first)
        #expect(profile.dimensions == ProfileEngine().makeProfile(from: [], now: .distantPast).dimensions)
    }

    @Test("External strength remains ordinal and observation text stays intact")
    func externalObservationIsQualitative() throws {
        let payload = ExternalAIFixture.payload(differences: [])
        let bundle = ExternalEvidenceConverter.bundle(
            from: payload,
            provider: .claude,
            approvedAt: .distantPast,
            userNote: nil
        )
        let profile = ProfileEngine().makeProfile(from: [], externalEvidence: bundle, now: .distantPast)
        let observation = try #require(
            HypothesisEngine().hypotheses(for: profile).first { $0.support == .externalObservation }
        )

        #expect(observation.statement == payload.observations.first?.pattern)
        #expect(observation.evidenceStrength == .moderate)
    }
}
