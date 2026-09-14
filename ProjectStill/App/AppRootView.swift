import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredAttentionProfile.updatedAt, order: .reverse) private var storedProfiles: [StoredAttentionProfile]
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]
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
                    ProfileView(profile: currentProfile)
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
                    PrivacyChoiceView {
                        path.append(.questionnaire)
                    }
                case .questionnaire:
                    QuestionnaireView {
                        path.removeAll()
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
        }
    }

    private func resetLocalTestData() {
        if let sessions = try? modelContext.fetch(FetchDescriptor<QuestionnaireSession>()) {
            sessions.forEach(modelContext.delete)
        }
        if let profiles = try? modelContext.fetch(FetchDescriptor<StoredAttentionProfile>()) {
            profiles.forEach(modelContext.delete)
        }
        try? modelContext.save()
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self], inMemory: true)
}
