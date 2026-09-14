import Foundation
import SwiftData

@Model
final class QuestionnaireSession {
    var answersData: Data
    var currentIndex: Int
    var isComplete: Bool
    var updatedAt: Date

    init(
        answers: [QuestionAnswer] = [],
        currentIndex: Int = 0,
        isComplete: Bool = false,
        updatedAt: Date = .now
    ) {
        self.answersData = (try? JSONEncoder().encode(answers)) ?? Data()
        self.currentIndex = currentIndex
        self.isComplete = isComplete
        self.updatedAt = updatedAt
    }

    var answers: [QuestionAnswer] {
        get { (try? JSONDecoder().decode([QuestionAnswer].self, from: answersData)) ?? [] }
        set { answersData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}

@Model
final class StoredAttentionProfile {
    var profileData: Data
    var updatedAt: Date

    init(profile: AttentionProfile) {
        self.profileData = (try? JSONEncoder().encode(profile)) ?? Data()
        self.updatedAt = profile.updatedAt
    }

    var profile: AttentionProfile? {
        get { try? JSONDecoder().decode(AttentionProfile.self, from: profileData) }
        set {
            guard let newValue else { return }
            profileData = (try? JSONEncoder().encode(newValue)) ?? Data()
            updatedAt = newValue.updatedAt
        }
    }
}

@MainActor
enum QuestionnairePersistence {
    static func session(in context: ModelContext) -> QuestionnaireSession {
        let descriptor = FetchDescriptor<QuestionnaireSession>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let created = QuestionnaireSession()
        context.insert(created)
        try? context.save()
        return created
    }

    static func saveProfile(_ profile: AttentionProfile, in context: ModelContext) {
        let descriptor = FetchDescriptor<StoredAttentionProfile>()
        if let existing = try? context.fetch(descriptor).first {
            existing.profile = profile
        } else {
            context.insert(StoredAttentionProfile(profile: profile))
        }
        try? context.save()
    }

    static func update(
        questionID: String,
        optionID: String,
        session: QuestionnaireSession,
        context: ModelContext
    ) -> [QuestionAnswer] {
        var answers = session.answers.filter { $0.questionID != questionID }
        answers.append(QuestionAnswer(questionID: questionID, optionID: optionID, answeredAt: .now))

        let validIDs = Set(QuestionnaireBank.questions(for: answers).map(\.id))
        answers.removeAll { !validIDs.contains($0.questionID) }
        session.answers = answers
        session.updatedAt = .now
        try? context.save()
        return answers
    }
}

