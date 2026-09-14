import SwiftUI

struct ExternalAIProfilePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let payload: ExternalAIProfilePayload
    let provider: AIProvider
    let onApprove: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                    Text("Review what will be used")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("externalAI.previewTitle")

                    Text("Only these qualitative observations from \(provider.title) will be stored. Evidence labels stay descriptive — QuietEarth does not turn them into scores.")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk.opacity(0.72))

                    evidenceSection("Self-report found in conversation") {
                        ForEach(Array(payload.selfReport.enumerated()), id: \.offset) { _, item in
                            EvidencePreviewCard(
                                statement: item.statement,
                                strength: item.evidenceStrength
                            )
                        }
                    }

                    evidenceSection("Observable conversation patterns") {
                        ForEach(Array(payload.observations.enumerated()), id: \.offset) { _, item in
                            EvidencePreviewCard(
                                statement: item.pattern,
                                strength: item.evidenceStrength,
                                reason: item.reason,
                                counterpoint: item.counterpoint
                            )
                        }
                    }

                    if !payload.differencesBetweenSelfReportAndObservation.isEmpty {
                        textList("Where the views differ", payload.differencesBetweenSelfReportAndObservation)
                    }
                    textList("Alternative explanations", payload.alternativeExplanations)
                    textList("Limitations", payload.limitations)

                    Button("Approve and compare", action: onApprove)
                        .buttonStyle(.primaryAction)
                        .accessibilityIdentifier("externalAI.approve")

                    Button("Go back and edit") { dismiss() }
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(QuietSpacing.generous)
            }
            .background(Color.quietPaper.ignoresSafeArea())
        }
    }

    private func evidenceSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            Text(title).font(.quietTitle)
            content()
        }
    }

    private func textList(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title).font(.quietTitle)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "arrow.triangle.branch")
                    .font(.subheadline)
                    .foregroundStyle(Color.quietInk.opacity(0.72))
            }
        }
    }
}

struct EvidencePreviewCard: View {
    let statement: String
    let strength: EvidenceStrength
    var reason: String? = nil
    var counterpoint: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            HStack(alignment: .firstTextBaseline) {
                Text(statement)
                    .font(.headline)
                Spacer(minLength: QuietSpacing.compact)
                Text(strength.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.quietNeem)
            }
            if let reason {
                Text(reason)
                    .font(.subheadline)
                    .foregroundStyle(Color.quietInk.opacity(0.7))
            }
            if let counterpoint {
                Label(counterpoint, systemImage: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundStyle(Color.quietClay)
            }
        }
        .padding(QuietSpacing.standard)
        .quietCard()
    }
}
