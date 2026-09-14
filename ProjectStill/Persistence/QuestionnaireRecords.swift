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
    var providerRawValue: String = AIProvider.other.rawValue
    var payloadData: Data = Data()
    var observationsData: Data = Data()
    var schemaVersion: Int = 2
    var approvedAt: Date = Date.distantPast
    var userNote: String?

    init(
        provider: AIProvider,
        payload: ExternalAIPayload,
        observations: [ExternalObservation],
        approvedAt: Date = .now,
        userNote: String? = nil
    ) {
        self.providerRawValue = provider.rawValue
        self.payloadData = (try? JSONEncoder().encode(payload)) ?? Data()
        self.observationsData = (try? JSONEncoder().encode(observations)) ?? Data()
        self.schemaVersion = payload.schemaVersion
        self.approvedAt = approvedAt
        self.userNote = userNote
    }

    var provider: AIProvider { AIProvider(rawValue: providerRawValue) ?? .other }

    var payload: ExternalAIPayload? {
        try? JSONDecoder().decode(ExternalAIPayload.self, from: payloadData)
    }

    var observations: [ExternalObservation] {
        get { (try? JSONDecoder().decode([ExternalObservation].self, from: observationsData)) ?? [] }
        set { observationsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    /// Superseded schema-v1 records are deleted, never migrated: converting old
    /// scores into synthetic observations would manufacture the evidence M1.6 removed.
    var isSuperseded: Bool { schemaVersion != 2 || payload == nil }
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
        payload: ExternalAIPayload,
        observations: [ExternalObservation],
        userNote: String?,
        in context: ModelContext
    ) {
        if let records = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()) {
            records.forEach(context.delete)
        }
        context.insert(
            StoredExternalAIProfile(
                provider: provider,
                payload: payload,
                observations: observations,
                userNote: userNote
            )
        )
        try? context.save()
        rebuildProfile(in: context)
    }

    /// Discards any stored schema-v1 external evidence. Returns true when a
    /// record was dropped, so the UI can tell the user to add AI evidence again.
    @discardableResult
    static func discardSupersededExternalProfiles(in context: ModelContext) -> Bool {
        guard let records = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()) else { return false }
        let superseded = records.filter(\.isSuperseded)
        guard !superseded.isEmpty else { return false }
        superseded.forEach(context.delete)
        try? context.save()
        rebuildProfile(in: context)
        return true
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
        let external = externalRecords.first { !$0.isSuperseded }
        let profile = ProfileEngine().makeProfile(
            from: answers,
            observations: external?.observations ?? [],
            payload: external?.payload
        )
        saveProfile(profile, in: context)
    }

    /// Re-files one observation under a different theme, then recomputes.
    static func updateObservationTheme(
        observationID: String,
        theme: AttentionTheme?,
        in context: ModelContext
    ) {
        guard let record = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()).first else { return }
        var observations = record.observations
        guard let index = observations.firstIndex(where: { $0.id == observationID }) else { return }
        observations[index].theme = theme
        record.observations = observations
        try? context.save()
        rebuildProfile(in: context)
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
