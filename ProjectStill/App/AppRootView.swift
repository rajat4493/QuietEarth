import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredAttentionProfile.updatedAt, order: .reverse) private var storedProfiles: [StoredAttentionProfile]
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]
    @Query private var externalProfiles: [StoredExternalAIProfile]
    @State private var path: [AppRoute] = []
    @State private var didHandleLaunchArguments = false

    private var currentProfile: AttentionProfile? {
        storedProfiles.first?.profile
    }

    private var hasQuestionnaireProgress: Bool {
        guard let session = sessions.first else { return false }
        return !session.answers.isEmpty && !session.isComplete
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let currentProfile {
                    ProfileView(
                        profile: currentProfile,
                        hasQuestionnaireEvidence: sessions.first?.isComplete == true,
                        hasExternalEvidence: !externalProfiles.isEmpty,
                        onQuestionnaire: { path.append(.questionnaire) },
                        onUseAI: { path.append(.externalAIIntake) }
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
        }
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
}

#Preview {
    AppRootView()
        .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self, StoredExternalAIProfile.self], inMemory: true)
}
