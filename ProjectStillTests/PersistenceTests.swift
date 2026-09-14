import Foundation
import SwiftData
import Testing
@testable import ProjectStill

struct PersistenceTests {
    @MainActor
    @Test("Questionnaire progress and profile survive a fresh model context")
    func roundTrip() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: QuestionnaireSession.self,
            StoredAttentionProfile.self,
            configurations: configuration
        )
        let firstContext = ModelContext(container)
        let answers = [QuestionAnswer(questionID: "switching", optionID: "often", answeredAt: .distantPast)]
        let session = QuestionnaireSession(answers: answers, currentIndex: 1)
        let profile = ProfileEngine().makeProfile(from: answers, now: .distantPast)
        firstContext.insert(session)
        firstContext.insert(StoredAttentionProfile(profile: profile))
        try firstContext.save()

        let reopenedContext = ModelContext(container)
        let reopenedSession = try #require(reopenedContext.fetch(FetchDescriptor<QuestionnaireSession>()).first)
        let reopenedProfile = try #require(reopenedContext.fetch(FetchDescriptor<StoredAttentionProfile>()).first?.profile)

        #expect(reopenedSession.currentIndex == 1)
        #expect(reopenedSession.answers == answers)
        #expect(reopenedProfile == profile)
    }

    @MainActor
    @Test("Revising an answer changes the derived profile without losing evidence")
    func revisionRecalculatesProfile() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: QuestionnaireSession.self,
            StoredAttentionProfile.self,
            configurations: configuration
        )
        let context = ModelContext(container)
        let initialAnswers = [
            QuestionAnswer(questionID: "switching", optionID: "rarely", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "locks", answeredAt: .distantPast)
        ]
        let session = QuestionnaireSession(answers: initialAnswers, currentIndex: 2, isComplete: true)
        context.insert(session)
        let initial = ProfileEngine().makeProfile(from: initialAnswers)

        let revisedAnswers = QuestionnairePersistence.update(
            questionID: "switching",
            optionID: "very_often",
            session: session,
            context: context
        )
        let revised = ProfileEngine().makeProfile(from: revisedAnswers)

        #expect(revised.assessment(for: .attentionalSwitching).score > initial.assessment(for: .attentionalSwitching).score)
        #expect(revised.assessment(for: .attentionalSwitching).evidence.count == 2)
        #expect(!revised.assessment(for: .attentionalSwitching).contradictions.isEmpty)
    }
}
