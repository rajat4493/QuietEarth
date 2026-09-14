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

                    Text("Only this normalized profile from \(provider.title) will be stored. Check it before adding it as evidence.")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk.opacity(0.72))

                    previewSection("Self-report summary", payload.selfReportSummary)
                    previewSection("Behavioral summary", payload.behavioralSummary)

                    VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                        Text("Dimension evidence")
                            .font(.quietTitle)
                        ForEach(payload.dimensions, id: \.name) { dimension in
                            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                                HStack {
                                    Text(title(for: dimension.name)).font(.headline)
                                    Spacer()
                                    Text(dimension.score, format: .percent.precision(.fractionLength(0)))
                                        .font(.headline.monospacedDigit())
                                }
                                Text(dimension.evidenceSummary)
                                    .font(.subheadline)
                                Text("Counter-evidence: \(dimension.counterEvidence)")
                                    .font(.caption)
                                    .foregroundStyle(Color.quietInk.opacity(0.62))
                            }
                            .padding(QuietSpacing.standard)
                            .background(Color.quietMist)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }

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

    private func previewSection(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title).font(.quietTitle)
            Text(text)
                .font(.quietBody)
                .foregroundStyle(Color.quietInk.opacity(0.72))
        }
    }

    private func title(for name: String) -> String {
        ExternalAIProfileParser.dimensionNames[name]?.title ?? name
    }
}

