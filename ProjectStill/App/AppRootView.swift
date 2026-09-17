import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredAttentionProfile.updatedAt, order: .reverse) private var storedProfiles: [StoredAttentionProfile]
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]
    @Query private var externalProfiles: [StoredExternalAIProfile]
    @Query(sort: \StoredExperiment.startedAt, order: .reverse) private var storedExperiments: [StoredExperiment]
    @State private var path: [AppRoute] = []
    @State private var didHandleLaunchArguments = false

    private var currentProfile: AttentionProfile? {
        storedProfiles.first?.profile
    }

    private var hasQuestionnaireProgress: Bool {
        guard let session = sessions.first else { return false }
        return !session.answers.isEmpty && !session.isComplete
    }

    private var currentExperiment: Experiment? {
        storedExperiments.first { !$0.isArchived }?.experiment
    }

    private var hypotheses: [WorkingHypothesis] {
        guard let currentProfile else { return [] }
        return HypothesisEngine().hypotheses(for: currentProfile)
    }

    /// The live recommendation: the profile's own rules, plus any adjustment the
    /// last day-seven review decided on.
    private var recommendation: PracticeRecommendation? {
        guard let currentProfile else { return nil }
        let adjustment = storedExperiments
            .compactMap(\.experiment)
            .first { $0.review != nil }?
            .review?
            .adjustment
        return RecommendationEngine().recommend(
            profile: currentProfile,
            hypotheses: hypotheses,
            adjustment: currentExperiment == nil ? adjustment : nil
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let currentProfile, let experiment = currentExperiment, let recommendation {
                    HomeView(
                        experiment: experiment,
                        recommendation: activeRecommendation(for: experiment, fallback: recommendation),
                        profile: currentProfile,
                        onBegin: { path.append(.practiceSession) },
                        onReview: { path.append(.daySevenReview) },
                        onOpenProfile: { path.append(.profile) },
                        onSettings: { path.append(.settings) }
                    )
                } else if let currentProfile {
                    ProfileView(
                        profile: currentProfile,
                        hasQuestionnaireEvidence: sessions.first?.isComplete == true,
                        hasExternalEvidence: !externalProfiles.isEmpty,
                        onQuestionnaire: { path.append(.questionnaire) },
                        onUseAI: { path.append(.externalAIIntake) },
                        recommendation: recommendation,
                        onStartExperiment: startExperiment
                    )
                } else {
                    OpeningView(
                        primaryTitle: hasQuestionnaireProgress ? "Continue questionnaire" : "Understand my mind",
                        onBegin: {
                            path.append(hasQuestionnaireProgress ? .questionnaire : .privacyChoice)
                        },
                        onLearnMore: { path.append(.howItWorks) }
                    )
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .howItWorks:
                    HowItWorksView {
                        path.append(.privacyChoice)
                    }
                case .privacyChoice:
                    PrivacyChoiceView(
                        onQuestionnaire: { path.append(.questionnaire) },
                        onExternalAI: { path.append(.externalAIIntake) }
                    )
                case .questionnaire:
                    QuestionnaireView {
                        path.removeAll()
                    }
                case .externalAIIntake:
                    ExternalAIIntakeView {
                        if sessions.first?.isComplete == true {
                            path.removeAll()
                        } else {
                            path = [.questionnaire]
                        }
                    }
                case .profile:
                    if let currentProfile {
                        ProfileView(
                            profile: currentProfile,
                            hasQuestionnaireEvidence: sessions.first?.isComplete == true,
                            hasExternalEvidence: !externalProfiles.isEmpty,
                            onQuestionnaire: { path.append(.questionnaire) },
                            onUseAI: { path.append(.externalAIIntake) },
                            recommendation: nil,
                            onStartExperiment: nil
                        )
                    }
                case .practiceSession:
                    if let experiment = currentExperiment, let recommendation {
                        let active = activeRecommendation(for: experiment, fallback: recommendation)
                        PracticeSessionView(recommendation: active) { completedSeconds in
                            path.append(.reflection(completedSeconds: completedSeconds))
                        }
                    }
                case .reflection(let completedSeconds):
                    if let experiment = currentExperiment, let recommendation {
                        let active = activeRecommendation(for: experiment, fallback: recommendation)
                        ReflectionView(
                            recommendation: active,
                            plannedSeconds: active.seconds,
                            completedSeconds: completedSeconds
                        ) { outcome in
                            PracticePersistence.record(outcome, in: modelContext)
                            path.removeAll()
                        }
                    }
                case .daySevenReview:
                    if let experiment = currentExperiment, let currentProfile {
                        let review = experiment.review ?? AdaptationEngine().review(for: experiment)
                        let next = RecommendationEngine().recommend(
                            profile: currentProfile,
                            hypotheses: hypotheses,
                            adjustment: review.adjustment
                        )
                        DaySevenReviewView(
                            experiment: experiment,
                            review: review,
                            nextRecommendation: next
                        ) {
                            PracticePersistence.saveReview(review, in: modelContext)
                            PracticePersistence.startExperiment(
                                from: next,
                                hypothesis: hypotheses.first,
                                in: modelContext
                            )
                            path.removeAll()
                        }
                    }
                case .settings:
                    SettingsView {
                        path.removeAll()
                    }
                }
            }
        }
        .tint(.quietNeem)
        .task {
            guard !didHandleLaunchArguments else { return }
            didHandleLaunchArguments = true
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-uiTestingReset") {
                resetLocalTestData()
            }
            if arguments.contains("-uiTestingSeedProfile") {
                seedTestProfile(includeExternalEvidence: arguments.contains("-uiTestingSeedExternal"))
            }
            if arguments.contains("-uiTestingSeedExperiment") {
                seedTestExperiment(daysAgo: arguments.contains("-uiTestingSeedDaySeven") ? 6 : 0)
            }
        }
    }

    /// A running experiment keeps the practice it started with; the live
    /// recommendation only applies to the next one.
    private func activeRecommendation(
        for experiment: Experiment,
        fallback: PracticeRecommendation
    ) -> PracticeRecommendation {
        PracticeRecommendation(
            template: PracticeTemplate.template(experiment.templateID),
            anchor: experiment.anchor,
            minutes: experiment.minutes,
            reasons: fallback.reasons,
            hypothesisID: experiment.hypothesisID,
            hypothesisStatement: experiment.hypothesisStatement
        )
    }

    private func startExperiment() {
        guard let recommendation else { return }
        PracticePersistence.startExperiment(
            from: recommendation,
            hypothesis: hypotheses.first,
            in: modelContext
        )
    }

    private func resetLocalTestData() {
        if let sessions = try? modelContext.fetch(FetchDescriptor<QuestionnaireSession>()) {
            sessions.forEach(modelContext.delete)
        }
        if let profiles = try? modelContext.fetch(FetchDescriptor<StoredAttentionProfile>()) {
            profiles.forEach(modelContext.delete)
        }
        if let externalProfiles = try? modelContext.fetch(FetchDescriptor<StoredExternalAIProfile>()) {
            externalProfiles.forEach(modelContext.delete)
        }
        if let experiments = try? modelContext.fetch(FetchDescriptor<StoredExperiment>()) {
            experiments.forEach(modelContext.delete)
        }
        try? modelContext.save()
    }

    private func seedTestProfile(includeExternalEvidence: Bool) {
        let answers = [
            QuestionAnswer(questionID: "switching", optionID: "very_often", answeredAt: .distantPast),
            QuestionAnswer(questionID: "persistence", optionID: "brief", answeredAt: .distantPast),
            QuestionAnswer(questionID: "branching", optionID: "many", answeredAt: .distantPast),
            QuestionAnswer(questionID: "deadline", optionID: "fragments", answeredAt: .distantPast)
        ]
        modelContext.insert(QuestionnaireSession(answers: answers, currentIndex: 4, isComplete: true))
        if includeExternalEvidence {
            let payload = ExternalAIProfilePayload(
                schemaVersion: 2,
                selfReport: [
                    ExternalAISelfReport(
                        statement: "I often describe myself as unable to focus.",
                        evidenceStrength: .strong
                    )
                ],
                observations: [
                    ExternalAIObservation(
                        pattern: "Long-form engagement is sustained when the subject is personally meaningful, even when topics switch frequently.",
                        evidenceStrength: .moderate,
                        reason: "Several conversations return to a chosen subject and develop it in depth.",
                        counterpoint: "Chosen conversations may not represent routine or low-interest tasks."
                    )
                ],
                differencesBetweenSelfReportAndObservation: [
                    "Self-report emphasizes weak focus, while conversation shows context-specific persistence."
                ],
                alternativeExplanations: [
                    "Interest may affect attentional gating more than general capacity."
                ],
                limitations: ["Conversation is only one setting and cannot establish a cognitive trait."]
            )
            modelContext.insert(StoredExternalAIProfile(provider: .chatGPT, payload: payload, approvedAt: .distantPast))
        }
        QuestionnairePersistence.rebuildProfile(in: modelContext)
        try? modelContext.save()
    }

    private func seedTestExperiment(daysAgo: Int) {
        guard let profile = storedProfiles.first?.profile else { return }
        let started = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        let hypotheses = HypothesisEngine().hypotheses(for: profile)
        let recommendation = RecommendationEngine().recommend(profile: profile, hypotheses: hypotheses)
        let experiment = PracticePersistence.startExperiment(
            from: recommendation,
            hypothesis: hypotheses.first,
            now: started,
            in: modelContext
        )
        if daysAgo >= 6 {
            // Four completed sessions with returning getting easier: the
            // deterministic "lengthen" path.
            let eases: [ReturnEase] = [.hard, .mixed, .easy, .easy]
            for (index, ease) in eases.enumerated() {
                PracticePersistence.record(
                    PracticeOutcome(
                        id: "seed.\(index)",
                        templateID: experiment.templateID,
                        anchor: experiment.anchor,
                        plannedSeconds: experiment.minutes * 60,
                        completedSeconds: experiment.minutes * 60,
                        noticeRate: .many,
                        returnEase: ease,
                        afterward: .moreSettled,
                        note: nil,
                        recordedAt: Calendar.current.date(byAdding: .day, value: index, to: started) ?? started
                    ),
                    in: modelContext
                )
            }
        }
        try? modelContext.save()
    }
}

#Preview {
    AppRootView()
        .modelContainer(
            for: [
                QuestionnaireSession.self,
                StoredAttentionProfile.self,
                StoredExternalAIProfile.self,
                StoredExperiment.self
            ],
            inMemory: true
        )
}
