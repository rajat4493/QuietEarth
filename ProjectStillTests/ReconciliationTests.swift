import Foundation
import SwiftData
import Testing
@testable import ProjectStill

struct ReconciliationTests {
    private let engine = ProfileEngine()

    private let branchingAnswers = [
        QuestionAnswer(questionID: "branching", optionID: "many", answeredAt: .distantPast),
        QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast)
    ]

    @Test("Questionnaire and observation pointing the same way converge")
    func converging() {
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.branchingObservation(), .branching)
        ])
        let profile = engine.makeProfile(from: branchingAnswers, observations: observations)
        let hypothesis = profile.hypotheses.first { $0.theme == .branching }

        #expect(hypothesis?.supportState == .converging)
        #expect(hypothesis?.tension == nil)
        #expect(profile.sourceComparisons?.first { $0.theme == .branching }?.relationship == .agreement)
    }

    @Test("Sources that disagree stay contested and are tested first")
    func contested() throws {
        let answers = [
            QuestionAnswer(questionID: "persistence", optionID: "brief", answeredAt: .distantPast),
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast)
        ]
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.depthObservation(), .topicDepth)
        ])
        let profile = engine.makeProfile(from: answers, observations: observations)
        let hypothesis = try #require(profile.hypotheses.first { $0.theme == .topicDepth })

        #expect(hypothesis.supportState == .contested)
        #expect(hypothesis.tension != nil)
        // Contested claims come first: test what is most likely to be wrong.
        #expect(profile.testableHypotheses.first?.supportState == .contested)
        #expect(profile.sourceComparisons?.first { $0.theme == .topicDepth }?.relationship == .disagreement)
    }

    @Test("Weak self-reported focus plus observed depth keeps capacity and gating")
    func capacityAndGating() throws {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "brief", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "fragments", answeredAt: .distantPast)
        ]
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.depthObservation(), .topicDepth)
        ])
        let payload = ExternalAIFixture.payload()
        let profile = engine.makeProfile(from: answers, observations: observations, payload: payload)

        #expect(profile.interpretation.title == ProfileEngine.capacityGatingTitle)
        #expect(profile.alternativeInterpretations?.contains {
            $0.localizedCaseInsensitiveContains("generalized weak concentration")
        } == true)
        // Nothing here is flattened to a midpoint, and nothing here is a number.
        let hypothesis = try #require(profile.hypotheses.first { $0.theme == .topicDepth })
        #expect(hypothesis.supportState == .contested)
        #expect(!hypothesis.disconfirmation.isEmpty)
        #expect(!hypothesis.prediction.isEmpty)
    }

    @Test("Insufficient observations are shown but drive nothing")
    func insufficientEvidence() {
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.branchingObservation(strength: .insufficient), .branching)
        ])
        let profile = engine.makeProfile(from: [], observations: observations)

        #expect(profile.testableHypotheses.isEmpty)
        #expect(profile.unsupportedObservations.count == 1)
        #expect(profile.overallStrength == .insufficient)
    }

    @Test("An observation filed as None of these stays visible and drives nothing")
    func unfiledObservation() {
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.branchingObservation(), nil)
        ])
        let profile = engine.makeProfile(from: branchingAnswers, observations: observations)

        #expect(profile.hypotheses.allSatisfy { $0.observedBasis.isEmpty })
        #expect(profile.unsupportedObservations.count == 1)
    }

    @Test("Every hypothesis carries a prediction and a disconfirmation")
    func hypothesesAreFalsifiable() {
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.branchingObservation(), .branching),
            (ExternalAIFixture.depthObservation(), .topicDepth)
        ])
        let profile = engine.makeProfile(from: branchingAnswers, observations: observations)

        #expect(!profile.testableHypotheses.isEmpty)
        for hypothesis in profile.testableHypotheses {
            #expect(!hypothesis.prediction.isEmpty)
            #expect(!hypothesis.disconfirmation.isEmpty)
        }
    }

    @MainActor
    @Test("Removing AI evidence restores questionnaire-only dimensions exactly")
    func deletionReversion() throws {
        let context = try Self.makeContext()
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "rarely", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "very_long", answeredAt: .distantPast)
        ]
        context.insert(QuestionnaireSession(answers: answers, currentIndex: 2, isComplete: true))
        QuestionnairePersistence.rebuildProfile(in: context)
        let questionnaireOnly = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)

        QuestionnairePersistence.saveExternalProfile(
            provider: .chatGPT,
            payload: ExternalAIFixture.payload(),
            observations: ExternalAIFixture.observations([
                (ExternalAIFixture.branchingObservation(), .branching)
            ]),
            userNote: "Approved fixture",
            in: context
        )
        #expect(try context.fetch(FetchDescriptor<StoredExternalAIProfile>()).count == 1)

        QuestionnairePersistence.removeExternalProfile(in: context)
        let reverted = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)
        #expect(try context.fetch(FetchDescriptor<StoredExternalAIProfile>()).isEmpty)
        #expect(reverted.dimensions == questionnaireOnly.dimensions)
        #expect(reverted.interpretation == questionnaireOnly.interpretation)
        #expect(reverted.sourceComparisons == nil)
        #expect(reverted.observations.isEmpty)
        #expect(reverted.hypotheses.isEmpty)
    }

    @MainActor
    @Test("Re-filing an observation under a different theme regenerates hypotheses")
    func refilingObservation() throws {
        let context = try Self.makeContext()
        context.insert(QuestionnaireSession(answers: branchingAnswers, currentIndex: 2, isComplete: true))
        let observations = ExternalAIFixture.observations([
            (ExternalAIFixture.branchingObservation(), .branching)
        ])
        QuestionnairePersistence.saveExternalProfile(
            provider: .chatGPT,
            payload: ExternalAIFixture.payload(),
            observations: observations,
            userNote: nil,
            in: context
        )

        QuestionnairePersistence.updateObservationTheme(
            observationID: observations[0].id,
            theme: .linking,
            in: context
        )
        let profile = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)
        #expect(profile.observations.first?.theme == .linking)
        #expect(profile.hypotheses.contains { $0.theme == .linking })
    }

    @MainActor
    @Test("Stored schema-v1 evidence is discarded rather than migrated")
    func supersededRecordsDiscarded() throws {
        let context = try Self.makeContext()
        context.insert(QuestionnaireSession(answers: branchingAnswers, currentIndex: 2, isComplete: true))
        context.insert(
            StoredExternalAIProfile(
                provider: .chatGPT,
                payload: ExternalAIFixture.payload(schemaVersion: 1),
                observations: []
            )
        )
        try context.save()

        #expect(QuestionnairePersistence.discardSupersededExternalProfiles(in: context))
        #expect(try context.fetch(FetchDescriptor<StoredExternalAIProfile>()).isEmpty)
        let profile = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)
        #expect(profile.observations.isEmpty)
    }

    @MainActor
    private static func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: QuestionnaireSession.self,
            StoredAttentionProfile.self,
            StoredExternalAIProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }
}
