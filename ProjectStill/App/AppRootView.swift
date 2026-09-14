import SwiftUI

struct AppRootView: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            OpeningView(
                onBegin: { path.append(.privacyChoice) },
                onLearnMore: { path.append(.howItWorks) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .howItWorks:
                    HowItWorksView {
                        path.append(.privacyChoice)
                    }
                case .privacyChoice:
                    PrivacyChoiceView()
                }
            }
        }
        .tint(.quietNeem)
    }
}

#Preview {
    AppRootView()
}

