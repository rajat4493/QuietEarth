import SwiftUI

struct PrivacyChoiceView: View {
    let onQuestionnaire: () -> Void
    let onExternalAI: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                Text("How much do you want to share?")
                    .font(.quietDisplay)
                    .foregroundStyle(Color.quietInk)
                    .accessibilityAddTraits(.isHeader)

                Text("You can understand your attention without sharing conversation history.")
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk.opacity(0.76))

                VStack(spacing: QuietSpacing.standard) {
                    EvidenceChoiceCard(
                        title: "Questionnaire only",
                        detail: "Nothing imported.",
                        badge: nil,
                        isEnabled: true,
                        action: onQuestionnaire
                    )
                    EvidenceChoiceCard(
                        title: "Ask your AI",
                        detail: "Your chats stay with your AI provider. You bring back only the profile you approve.",
                        badge: nil,
                        isEnabled: true,
                        action: onExternalAI
                    )
                }

                Text("You can change your answers or add another view later.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Your privacy")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("privacyChoice.screen")
    }
}

private struct EvidenceChoiceCard: View {
    let title: String
    let detail: String
    let badge: String?
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(Color.quietClay)
                }

                Text(title)
                    .font(.quietTitle)
                    .foregroundStyle(Color.quietInk)

                Text(detail)
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk.opacity(0.72))
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(QuietSpacing.generous)
            .quietCard()
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.58)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isEnabled ? .isButton : [])
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var accessibilityIdentifier: String {
        if title == "Questionnaire only" { return "privacy.questionnaire" }
        if title == "Ask your AI" { return "privacy.externalAI" }
        return "privacy.future"
    }
}

#Preview {
    NavigationStack {
        PrivacyChoiceView(onQuestionnaire: {}, onExternalAI: {})
    }
}
