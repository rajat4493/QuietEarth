import Foundation
import SwiftData

@Model
final class StoredExperiment {
    var experimentData: Data = Data()
    var startedAt: Date = Date.distantPast
    var isArchived: Bool = false

    init(experiment: Experiment) {
        self.experimentData = (try? JSONEncoder().encode(experiment)) ?? Data()
        self.startedAt = experiment.startedAt
        self.isArchived = false
    }

    var experiment: Experiment? {
        get { try? JSONDecoder().decode(Experiment.self, from: experimentData) }
        set {
            guard let newValue else { return }
            experimentData = (try? JSONEncoder().encode(newValue)) ?? Data()
            startedAt = newValue.startedAt
        }
    }
}

@MainActor
enum PracticePersistence {
    /// Keys owned outside SwiftData. Global reset must clear all of them.
    static let userDefaultsKeys = [
        "profile.userPerspective",
        "appearance.mode",
        "appearance.landscape"
    ]

    static func currentExperiment(in context: ModelContext) -> Experiment? {
        var descriptor = FetchDescriptor<StoredExperiment>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first?.experiment
    }

    private static func currentRecord(in context: ModelContext) -> StoredExperiment? {
        var descriptor = FetchDescriptor<StoredExperiment>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    @discardableResult
    static func startExperiment(
        from recommendation: PracticeRecommendation,
        hypothesis: WorkingHypothesis?,
        now: Date = .now,
        in context: ModelContext
    ) -> Experiment {
        archiveCurrent(in: context)
        let experiment = Experiment(
            id: "experiment.\(now.timeIntervalSince1970)",
            startedAt: now,
            templateID: recommendation.template.id,
            anchor: recommendation.anchor,
            minutes: recommendation.minutes,
            hypothesisID: hypothesis?.id ?? recommendation.hypothesisID,
            hypothesisStatement: hypothesis?.statement ?? recommendation.hypothesisStatement,
            prediction: hypothesis?.prediction ?? "We expect this practice to be completable, and to become a little easier to return in across the week.",
            disconfirmation: hypothesis?.disconfirmation ?? "Sessions that stay equally hard all week, or are repeatedly cut short, would tell us this is the wrong starting point.",
            outcomes: [],
            review: nil
        )
        context.insert(StoredExperiment(experiment: experiment))
        try? context.save()
        return experiment
    }

    static func record(_ outcome: PracticeOutcome, in context: ModelContext) {
        guard let record = currentRecord(in: context), var experiment = record.experiment else { return }
        experiment.outcomes.append(outcome)
        record.experiment = experiment
        try? context.save()
    }

    static func saveReview(_ review: DaySevenReview, in context: ModelContext) {
        guard let record = currentRecord(in: context), var experiment = record.experiment else { return }
        experiment.review = review
        record.experiment = experiment
        try? context.save()
    }

    static func archiveCurrent(in context: ModelContext) {
        guard let record = currentRecord(in: context) else { return }
        record.isArchived = true
        try? context.save()
    }

    static func history(in context: ModelContext) -> [Experiment] {
        let descriptor = FetchDescriptor<StoredExperiment>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        return ((try? context.fetch(descriptor)) ?? []).compactMap(\.experiment)
    }

    /// M7: removes every local trace — SwiftData stores and the settings and
    /// note held outside them.
    static func resetAllLocalData(in context: ModelContext) {
        if let sessions = try? context.fetch(FetchDescriptor<QuestionnaireSession>()) {
            sessions.forEach(context.delete)
        }
        if let profiles = try? context.fetch(FetchDescriptor<StoredAttentionProfile>()) {
            profiles.forEach(context.delete)
        }
        if let external = try? context.fetch(FetchDescriptor<StoredExternalAIProfile>()) {
            external.forEach(context.delete)
        }
        if let experiments = try? context.fetch(FetchDescriptor<StoredExperiment>()) {
            experiments.forEach(context.delete)
        }
        try? context.save()
        for key in userDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
