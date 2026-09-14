import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredAttentionProfile.updatedAt, order: .reverse) private var storedProfiles: [StoredAttentionProfile]
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]
    @Query private var externalProfiles: [StoredExternalAIProfile]
    @State private var path: [AppRoute] = []
    @State private var didHandleLaunchArguments = false
    @State private var didDiscardSupersededEvidence = false

    private var currentProfile: AttentionProfile? {
        storedProfiles.first?.profile
    }

    /// Schema-v1 records are superseded and never counted as evidence.
    private var hasExternalEvidence: Bool {
        externalProfiles.contains { !$0.isSuperseded }
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
                        hasExternalEvidence: hasExternalEvidence,
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
            if ProcessInfo.processInfo.arguments.contains("-uiTestingReset") {
                resetLocalTestData()
            }
            didDiscardSupersededEvidence = QuestionnairePersistence
                .discardSupersededExternalProfiles(in: modelContext)
        }
        .alert("AI evidence needs to be added again", isPresented: $didDiscardSupersededEvidence) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The analysis prompt changed: assistants now describe what they observe instead of scoring you. The evidence stored under the old format was removed rather than converted, so nothing invented a result. Your questionnaire answers are unchanged.")
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
}

#Preview {
    AppRootView()
        .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self, StoredExternalAIProfile.self], inMemory: true)
}
