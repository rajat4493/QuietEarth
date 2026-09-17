import Foundation
import SwiftData
import Testing
@testable import ProjectStill

struct PracticePersistenceTests {
    @MainActor
    private static func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: QuestionnaireSession.self,
            StoredAttentionProfile.self,
            StoredExternalAIProfile.self,
            StoredExperiment.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    @MainActor
    private func seededProfile(in context: ModelContext) -> AttentionProfile {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "branching", optionID: "many", answeredAt: .distantPast),
            QuestionAnswer(questionID: "low_stimulation", optionID: "okay", answeredAt: .distantPast)
        ]
        context.insert(QuestionnaireSession(answers: answers, currentIndex: 3, isComplete: true))
        QuestionnairePersistence.rebuildProfile(in: context)
        return (try? context.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile) ?? ProfileEngine().makeProfile(from: answers)
    }

    @MainActor
    @Test("An experiment stores outcomes and survives a refetch")
    func outcomesPersist() throws {
        let context = try Self.makeContext()
        let profile = seededProfile(in: context)
        let recommendation = RecommendationEngine().recommend(profile: profile)
        PracticePersistence.startExperiment(from: recommendation, hypothesis: nil, in: context)

        let outcome = PracticeOutcome(
            id: "outcome.1",
            templateID: recommendation.template.id,
            anchor: recommendation.anchor,
            plannedSeconds: recommendation.seconds,
            completedSeconds: recommendation.seconds,
            noticeRate: .many,
            returnEase: .mixed,
            afterward: .moreSettled,
            note: "Busy but fine.",
            recordedAt: .now
        )
        PracticePersistence.record(outcome, in: context)

        let reloaded = try #require(PracticePersistence.currentExperiment(in: context))
        #expect(reloaded.outcomes.count == 1)
        #expect(reloaded.completedSessions.count == 1)
        #expect(reloaded.outcomes.first?.note == "Busy but fine.")
    }

    @MainActor
    @Test("Starting a new experiment archives the previous one and keeps its history")
    func archivesPrevious() throws {
        let context = try Self.makeContext()
        let profile = seededProfile(in: context)
        let recommendation = RecommendationEngine().recommend(profile: profile)
        PracticePersistence.startExperiment(from: recommendation, hypothesis: nil, in: context)
        PracticePersistence.startExperiment(from: recommendation, hypothesis: nil, in: context)

        #expect(PracticePersistence.history(in: context).count == 2)
        let active = try context.fetch(FetchDescriptor<StoredExperiment>()).filter { !$0.isArchived }
        #expect(active.count == 1)
    }

    @MainActor
    @Test("A half-finished session is recorded as incomplete, not discarded")
    func incompleteSessionRecorded() throws {
        let context = try Self.makeContext()
        let profile = seededProfile(in: context)
        let recommendation = RecommendationEngine().recommend(profile: profile)
        PracticePersistence.startExperiment(from: recommendation, hypothesis: nil, in: context)

        PracticePersistence.record(
            PracticeOutcome(
                id: "outcome.partial",
                templateID: recommendation.template.id,
                anchor: recommendation.anchor,
                plannedSeconds: 300,
                completedSeconds: 60,
                noticeRate: .few,
                returnEase: .hard,
                afterward: .moreScattered,
                note: nil,
                recordedAt: .now
            ),
            in: context
        )

        let reloaded = try #require(PracticePersistence.currentExperiment(in: context))
        #expect(reloaded.outcomes.count == 1)
        #expect(reloaded.completedSessions.isEmpty)
    }

    @MainActor
    @Test("Global reset removes every local store and the keys held outside them")
    func globalReset() throws {
        let context = try Self.makeContext()
        let profile = seededProfile(in: context)
        PracticePersistence.startExperiment(
            from: RecommendationEngine().recommend(profile: profile),
            hypothesis: nil,
            in: context
        )
        for key in PracticePersistence.userDefaultsKeys {
            UserDefaults.standard.set("value", forKey: key)
        }

        PracticePersistence.resetAllLocalData(in: context)

        #expect(try context.fetch(FetchDescriptor<QuestionnaireSession>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<StoredAttentionProfile>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<StoredExternalAIProfile>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<StoredExperiment>()).isEmpty)
        for key in PracticePersistence.userDefaultsKeys {
            #expect(UserDefaults.standard.object(forKey: key) == nil)
        }
    }

    @MainActor
    @Test("A day-seven review is stored on the experiment it reviewed")
    func reviewPersists() throws {
        let context = try Self.makeContext()
        let profile = seededProfile(in: context)
        PracticePersistence.startExperiment(
            from: RecommendationEngine().recommend(profile: profile),
            hypothesis: nil,
            in: context
        )
        let experiment = try #require(PracticePersistence.currentExperiment(in: context))
        let review = AdaptationEngine().review(for: experiment)
        PracticePersistence.saveReview(review, in: context)

        let reloaded = try #require(PracticePersistence.currentExperiment(in: context))
        #expect(reloaded.review?.outcome == .insufficientEvidence)
        #expect(!reloaded.isReadyForReview())
    }
}
