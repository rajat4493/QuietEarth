import Foundation
import SwiftData
import Testing
@testable import ProjectStill

struct ReconciliationTests {
    private let engine = ProfileEngine()

    @Test("External observations retain language, provenance, strength, and counterpoint")
    func qualitativeEvidencePreserved() {
        let payload = ExternalAIFixture.payload()
        let bundle = ExternalEvidenceConverter.bundle(
            from: payload,
            provider: .claude,
            approvedAt: .distantPast,
            userNote: "Approved fixture"
        )

        #expect(bundle.observations.first?.source == .externalAI(provider: .claude))
        #expect(bundle.observations.first?.strength == .moderate)
        #expect(bundle.observations.first?.counterpoint == payload.observations.first?.counterpoint)
        #expect(bundle.observations.first?.userApprovedNote == "Approved fixture")
    }

    @Test("External evidence never changes questionnaire dimensions")
    func noHiddenNumericReconciliation() {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "rarely", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "very_long", answeredAt: .distantPast)
        ]
        let questionnaireOnly = engine.makeProfile(from: answers, now: .distantPast)
        let bundle = ExternalEvidenceConverter.bundle(
            from: ExternalAIFixture.payload(),
            provider: .chatGPT,
            approvedAt: .distantPast,
            userNote: nil
        )
        let withExternal = engine.makeProfile(from: answers, externalEvidence: bundle, now: .distantPast)

        #expect(withExternal.dimensions == questionnaireOnly.dimensions)
        #expect(withExternal.interpretation == questionnaireOnly.interpretation)
        #expect(withExternal.externalEvidence?.differences.isEmpty == false)
    }

    @Test("Agreement fixture remains a separate source without fabricated score")
    func agreement() {
        let payload = ExternalAIFixture.payload(differences: [])
        let bundle = ExternalEvidenceConverter.bundle(
            from: payload,
            provider: .chatGPT,
            approvedAt: .distantPast,
            userNote: nil
        )
        let profile = engine.makeProfile(from: [], externalEvidence: bundle, now: .distantPast)

        #expect(profile.externalEvidence?.differences.isEmpty == true)
        #expect(profile.evidenceStrength == .insufficient)
        #expect(profile.externalEvidence?.observations.first?.strength == .moderate)
    }

    @MainActor
    @Test("Removing AI evidence restores questionnaire-only profile exactly")
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
            payload: ExternalAIFixture.payload(),
            userNote: "Approved fixture",
            in: context
        )
        let imported = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)
        #expect(imported.dimensions == questionnaireOnly.dimensions)
        #expect(imported.externalEvidence != nil)

        QuestionnairePersistence.removeExternalProfile(in: context)
        let reverted = try #require(context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)
        #expect(try context.fetch(FetchDescriptor<StoredExternalAIProfile>()).isEmpty)
        #expect(reverted.dimensions == questionnaireOnly.dimensions)
        #expect(reverted.interpretation == questionnaireOnly.interpretation)
        #expect(reverted.externalEvidence == nil)
    }
}
