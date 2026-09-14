import SwiftUI

/// Review and filing step. Each observation is shown verbatim beside a suggested
/// theme and the visible reason for that suggestion. Nothing enters product
/// logic until the user confirms it.
struct ExternalAIProfilePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let payload: ExternalAIPayload
    let provider: AIProvider
    let onApprove: ([ExternalObservation]) -> Void

    @State private var observations: [ExternalObservation]

    init(
        payload: ExternalAIPayload,
        provider: AIProvider,
        onApprove: @escaping ([ExternalObservation]) -> Void
    ) {
        self.payload = payload
        self.provider = provider
        self.onApprove = onApprove
        _observations = State(
            initialValue: ExternalEvidenceConverter.observations(
                from: payload,
                provider: provider,
                approvedAt: .now
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                    Text("Review what will be used")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("externalAI.previewTitle")

                    Text("Only what you confirm here is stored from \(provider.title). These are descriptions of conversational behaviour, not measurements of you.")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietSecondaryInk)

                    ForEach($observations) { $observation in
                        ObservationFilingCard(observation: $observation)
                    }

                    if !payload.selfReport.isEmpty {
                        listSection(
                            "What you've said about yourself elsewhere",
                            payload.selfReport.map(\.statement),
                            footnote: "Kept separate from the observations. It scores nothing."
                        )
                    }
                    if !payload.differences.isEmpty {
                        listSection("Where those differ", payload.differences)
                    }
                    if !payload.alternativeExplanations.isEmpty {
                        listSection("Other explanations offered", payload.alternativeExplanations)
                    }
                    if !payload.limitations.isEmpty {
                        listSection("Limitations", payload.limitations)
                    }

                    Button("Approve and compare") { onApprove(observations) }
                        .buttonStyle(.primaryAction)
                        .accessibilityIdentifier("externalAI.approve")

                    Button("Go back and edit") { dismiss() }
                        .buttonStyle(.quietSecondary)
                }
                .padding(QuietSpacing.generous)
            }
            .background(Color.quietPaper.ignoresSafeArea())
        }
    }

    private func listSection(_ title: String, _ items: [String], footnote: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title).font(.quietTitle).foregroundStyle(Color.quietInk)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.subheadline)
                    .foregroundStyle(Color.quietSecondaryInk)
                    .imageScale(.small)
            }
            if let footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(Color.quietSecondaryInk)
            }
        }
    }
}

private struct ObservationFilingCard: View {
    @Binding var observation: ExternalObservation

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            HStack(alignment: .top) {
                Text(observation.pattern)
                    .font(.headline)
                    .foregroundStyle(Color.quietInk)
                Spacer(minLength: QuietSpacing.compact)
                EvidenceStrengthBadge(strength: observation.strength)
            }

            Text(observation.reason)
                .font(.subheadline)
                .foregroundStyle(Color.quietSecondaryInk)

            Text(observation.counterpoint)
                .font(.footnote)
                .foregroundStyle(Color.quietSecondaryInk)
                .padding(QuietSpacing.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.quietLemonWash)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Divider().overlay(Color.quietHairline)

            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                Text("File this under")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.quietSecondaryInk)

                Menu {
                    ForEach(AttentionTheme.allCases) { theme in
                        Button(theme.title) { observation.theme = theme }
                    }
                    Divider()
                    Button("None of these") { observation.theme = nil }
                } label: {
                    HStack {
                        Text(observation.theme?.title ?? "None of these")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundStyle(Color.quietInk)
                    .padding(QuietSpacing.compact)
                    .frame(minHeight: 44)
                    .background(Color.quietMintWash)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .accessibilityIdentifier("externalAI.themePicker")

                if let theme = observation.theme {
                    let matched = ExternalObservationFiler.matchedKeywords(for: observation.pattern, theme: theme)
                    Text(matched.isEmpty
                         ? "You chose this theme."
                         : "Suggested because the text mentions: \(matched.joined(separator: ", ")).")
                        .font(.caption)
                        .foregroundStyle(Color.quietSecondaryInk)
                } else {
                    Text("This stays readable in your profile but will not be used to form a hypothesis.")
                        .font(.caption)
                        .foregroundStyle(Color.quietSecondaryInk)
                }
            }
        }
        .quietCard()
    }
}

/// Four steps, never a percentage.
struct EvidenceStrengthBadge: View {
    let strength: EvidenceStrength

    var body: some View {
        HStack(spacing: 6) {
            Text(strength.title)
                .font(.caption.weight(.semibold))
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index < strength.filledSteps ? Color.quietNeem : Color.quietHairline)
                        .frame(width: 10, height: 4)
                }
            }
        }
        .foregroundStyle(Color.quietSecondaryInk)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Evidence: \(strength.title)")
    }
}
