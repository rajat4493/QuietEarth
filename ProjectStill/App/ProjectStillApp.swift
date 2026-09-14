import SwiftUI
import SwiftData

@main
struct ProjectStillApp: App {
    @AppStorage("appearance.mode") private var appearance = "system"
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
        }
        .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self, StoredExternalAIProfile.self])
    }
}
