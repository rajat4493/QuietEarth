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

@Model
final class StoredExternalAIProfile {
    var providerRawValue: String
    var payloadData: Data
    var approvedAt: Date
    var userNote: String?

    init(
        provider: AIProvider,
        payload: ExternalAIProfilePayload,
        approvedAt: Date = .now,
        userNote: String? = nil
    ) {
        self.providerRawValue = provider.rawValue
        self.payloadData = (try? JSONEncoder().encode(payload)) ?? Data()
        self.approvedAt = approvedAt
        self.userNote = userNote
    }

    var provider: AIProvider { AIProvider(rawValue: providerRawValue) ?? .other }
    var payload: ExternalAIProfilePayload? {
        try? JSONDecoder().decode(ExternalAIProfilePayload.self, from: payloadData)
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

    static func saveExternalProfile(
        provider: AIProvider,
        payload: ExternalAIProfilePayload,
        userNote: String?,
        in context: ModelContext
    ) {
        if let existing = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()).first {
            existing.providerRawValue = provider.rawValue
            existing.payloadData = (try? JSONEncoder().encode(payload)) ?? Data()
            existing.approvedAt = .now
            existing.userNote = userNote
        } else {
            context.insert(StoredExternalAIProfile(provider: provider, payload: payload, userNote: userNote))
        }
        try? context.save()
        rebuildProfile(in: context)
    }

    static func removeExternalProfile(in context: ModelContext) {
        if let records = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()) {
            records.forEach(context.delete)
        }
        try? context.save()
        rebuildProfile(in: context)
    }

    static func rebuildProfile(in context: ModelContext) {
        let answers = (try? context.fetch(FetchDescriptor<QuestionnaireSession>()).first?.answers) ?? []
        let externalRecords = (try? context.fetch(FetchDescriptor<StoredExternalAIProfile>())) ?? []
        let external = externalRecords.first
        let payload = external?.payload
        let signals: [ObservedSignal]
        if let record = external, let payload = record.payload {
            signals = ExternalEvidenceConverter.signals(
                from: payload,
                provider: record.provider,
                approvedAt: record.approvedAt,
                userNote: record.userNote
            )
        } else {
            signals = []
        }
        let profile = ProfileEngine().makeProfile(
            from: answers,
            additionalSignals: signals,
            externalPayload: payload
        )
        saveProfile(profile, in: context)
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
