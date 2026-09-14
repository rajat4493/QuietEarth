import SwiftUI
import SwiftData

struct EvidenceComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let profile: AttentionProfile

    private var evidence: ExternalEvidenceBundle? { profile.externalEvidence }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                    Text("How the two views compare")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("comparison.title")

                    comparisonSummary(
                        eyebrow: "YOU REPORTED",
                        title: profile.interpretation.title,
                        text: profile.interpretation.summary,
                        color: .quietSunlight
                    )

                    if let evidence {
                        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                            Text("Your AI conversation review noticed")
                                .font(.quietTitle)
                            ForEach(evidence.observations) { record in
                                EvidencePreviewCard(
                                    statement: record.statement,
                                    strength: record.strength,
                                    reason: record.reason,
                                    counterpoint: record.counterpoint
                                )
                            }
                        }

                        if evidence.differences.isEmpty {
                            comparisonSummary(
                                eyebrow: "CURRENT READ",
                                title: "The views add context",
                                text: "The imported review did not identify a clear conflict. It remains a separate source, not extra points added to your questionnaire.",
                                color: .quietMint
                            )
                        } else {
                            textList(
                                eyebrow: "KEEP BOTH IN VIEW",
                                title: "Where the views differ",
                                items: evidence.differences,
                                symbol: "arrow.left.arrow.right",
                                color: .quietCoral
                            )
                        }

                        textList(
                            eyebrow: "ALSO POSSIBLE",
                            title: "Alternative explanations",
                            items: evidence.alternativeExplanations,
                            symbol: "arrow.triangle.branch",
                            color: .quietMint
                        )
                        textList(
                            eyebrow: "EVIDENCE BOUNDARY",
                            title: "Limitations",
                            items: evidence.limitations,
                            symbol: "info.circle",
                            color: .quietMint
                        )
                    }

                    Button("Remove AI evidence", role: .destructive) {
                        QuestionnairePersistence.removeExternalProfile(in: modelContext)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .accessibilityIdentifier("comparison.removeAI")

                    Text("Removing this evidence restores the questionnaire-only view. Your pasted source text was never uploaded.")
                        .font(.footnote)
                        .foregroundStyle(Color.quietInk.opacity(0.6))
                }
                .padding(QuietSpacing.generous)
            }
            .background(Color.quietPaper.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func comparisonSummary(
        eyebrow: String,
        title: String,
        text: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(eyebrow)
                .font(.caption.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(Color.quietNeem)
            Text(title).font(.quietTitle)
            Text(text)
                .font(.quietBody)
                .foregroundStyle(Color.quietInk.opacity(0.72))
        }
        .padding(QuietSpacing.standard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.42))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func textList(
        eyebrow: String,
        title: String,
        items: [String],
        symbol: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(eyebrow)
                .font(.caption.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(Color.quietNeem)
            Text(title).font(.quietTitle)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: symbol)
                    .font(.subheadline)
                    .foregroundStyle(Color.quietInk.opacity(0.74))
            }
        }
        .padding(QuietSpacing.standard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.42))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
