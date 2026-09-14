import SwiftUI

struct PrivacyChoiceView: View {
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
                        badge: nil
                    )
                    EvidenceChoiceCard(
                        title: "Ask your AI",
                        detail: "Your chats stay with your AI provider. You bring back only the profile you approve.",
                        badge: "RECOMMENDED"
                    )
                    EvidenceChoiceCard(
                        title: "Import an export",
                        detail: "Experimental. Selected history will be analyzed on-device where possible.",
                        badge: "EXPERIMENTAL"
                    )
                }

                Text("Choice flows arrive in the next milestones.")
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

    var body: some View {
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
        .background(Color.quietMist)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        PrivacyChoiceView()
    }
}
