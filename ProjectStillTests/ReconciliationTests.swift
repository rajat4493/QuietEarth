import Foundation
import SwiftData
import Testing
@testable import ProjectStill

struct ReconciliationTests {
    private let engine = ProfileEngine()

    @Test("Questionnaire and external evidence can strongly agree")
    func agreement() {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "fragments", answeredAt: .distantPast)
        ]
        let payload = ExternalAIFixture.payload(scores: [.attentionalSwitching: 0.9])
        let signals = ExternalEvidenceConverter.signals(from: payload, provider: .chatGPT, approvedAt: .distantPast, userNote: nil)
        let profile = engine.makeProfile(from: answers, additionalSignals: signals, externalPayload: payload)
        let comparison = profile.sourceComparisons?.first { $0.dimension == .attentionalSwitching }

        #expect(comparison?.relationship == .agreement)
        #expect(profile.assessment(for: .attentionalSwitching).contradictions.isEmpty)
    }

    @Test("Partial disagreement stays visible and reduces confidence")
    func disagreement() {
        let lowSwitching = [
            QuestionAnswer(questionID: "switching", optionID: "rarely", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "locks", answeredAt: .distantPast)
        ]
        let highSwitching = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "fragments", answeredAt: .distantPast)
        ]
        let payload = ExternalAIFixture.payload(scores: [.attentionalSwitching: 0.9])
        let signals = ExternalEvidenceConverter.signals(from: payload, provider: .claude, approvedAt: .distantPast, userNote: nil)
        let disagreeing = engine.makeProfile(from: lowSwitching, additionalSignals: signals, externalPayload: payload)
        let agreeing = engine.makeProfile(from: highSwitching, additionalSignals: signals, externalPayload: payload)
        let comparison = disagreeing.sourceComparisons?.first { $0.dimension == .attentionalSwitching }

        #expect(comparison?.relationship == .disagreement)
        #expect(!disagreeing.assessment(for: .attentionalSwitching).contradictions.isEmpty)
        #expect(disagreeing.assessment(for: .attentionalSwitching).confidence < agreeing.assessment(for: .attentionalSwitching).confidence)
    }

    @Test("Low self-reported focus plus observed persistence preserves capacity and gating")
    func capacityAndGating() {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "brief", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "fragments", answeredAt: .distantPast)
        ]
        let payload = ExternalAIFixture.payload(scores: [
            .attentionalSwitching: 0.85,
            .focusPersistence: 0.9
        ])
        let signals = ExternalEvidenceConverter.signals(from: payload, provider: .chatGPT, approvedAt: .distantPast, userNote: nil)
        let profile = engine.makeProfile(from: answers, additionalSignals: signals, externalPayload: payload)

        #expect(profile.interpretation.title == "Capacity present, gating appears variable")
        #expect(profile.alternativeInterpretations?.contains(where: {
            $0.localizedCaseInsensitiveContains("generalized weak concentration")
        }) == true)
        #expect(profile.sourceComparisons?.first(where: { $0.dimension == .focusPersistence })?.relationship == .disagreement)
    }

    @MainActor
    @Test("Removing AI evidence restores questionnaire-only dimensions exactly")
    func deletionReversion() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: QuestionnaireSession.self,
            StoredAttentionProfile.self,
            StoredExternalAIProfile.self,
            configurations: configuration
        )
        let context = ModelContext(container)
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "rarely", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "very_long", answeredAt: .distantPast)
        ]
        context.insert(QuestionnaireSession(answers: answers, currentIndex: 2, isComplete: true))
        QuestionnairePersistence.rebuildProfile(in: context)
        let questionnaireOnly = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)

        QuestionnairePersistence.saveExternalProfile(
            provider: .chatGPT,
            payload: ExternalAIFixture.payload(scores: [.attentionalSwitching: 0.9]),
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
    }
}

