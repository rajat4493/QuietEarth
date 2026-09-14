import SwiftUI
import SwiftData

@main
struct ProjectStillApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self])
    }
}
