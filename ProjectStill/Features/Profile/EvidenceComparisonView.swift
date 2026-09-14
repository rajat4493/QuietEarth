import SwiftUI
import SwiftData

struct EvidenceComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let profile: AttentionProfile

    private var comparisons: [SourceComparison] { profile.sourceComparisons ?? [] }

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
                        title: "You reported",
                        text: questionnaireSummary
                    )
                    comparisonSummary(
                        title: "Your AI behavior profile suggests",
                        text: profile.externalBehavioralSummary ?? "No behavioral summary was retained."
                    )
                    comparisonSummary(
                        title: "Our current interpretation",
                        text: "\(profile.interpretation.title). \(profile.interpretation.summary)"
                    )

                    VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                        Text("Dimension by dimension")
                            .font(.quietTitle)
                        ForEach(comparisons) { comparison in
                            SourceComparisonCard(comparison: comparison)
                        }
                    }

                    if let alternatives = profile.alternativeInterpretations, !alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                            Text("Alternative interpretations")
                                .font(.quietTitle)
                            ForEach(alternatives, id: \.self) { alternative in
                                Label(alternative, systemImage: "arrow.triangle.branch")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.quietInk.opacity(0.74))
                            }
                        }
                    }

                    Button("Remove AI evidence", role: .destructive) {
                        QuestionnairePersistence.removeExternalProfile(in: modelContext)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .accessibilityIdentifier("comparison.removeAI")

                    Text("Removing this evidence restores the questionnaire-only profile. Your pasted source text was never uploaded.")
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

    private var questionnaireSummary: String {
        let evidence = comparisons.flatMap(\.questionnaireEvidence)
        return evidence.isEmpty
            ? "No questionnaire evidence is available yet."
            : evidence.prefix(3).joined(separator: " ")
    }

    private func comparisonSummary(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title)
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            Text(text)
                .font(.quietBody)
                .foregroundStyle(Color.quietInk.opacity(0.72))
        }
    }
}

private struct SourceComparisonCard: View {
    let comparison: SourceComparison

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            HStack {
                Text(comparison.dimension.title)
                    .font(.headline)
                Spacer()
                Text(relationshipTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(relationshipColor)
            }
            HStack(spacing: QuietSpacing.generous) {
                score(title: "You", value: comparison.questionnaireScore)
                score(title: "AI evidence", value: comparison.externalAIScore)
            }
            if comparison.relationship == .disagreement {
                Text("These sources point in different directions. Both remain in the profile and confidence is reduced.")
                    .font(.caption)
                    .foregroundStyle(Color.quietClay)
            }
        }
        .padding(QuietSpacing.standard)
        .background(Color.quietMist)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func score(title: String, value: Double?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption)
            Text(value?.formatted(.percent.precision(.fractionLength(0))) ?? "—")
                .font(.headline.monospacedDigit())
        }
        .foregroundStyle(Color.quietInk.opacity(0.72))
    }

    private var relationshipTitle: String {
        switch comparison.relationship {
        case .agreement: "AGREES"
        case .disagreement: "DIFFERS"
        case .singleSource: "ONE SOURCE"
        }
    }

    private var relationshipColor: Color {
        comparison.relationship == .disagreement ? .quietClay : .quietNeem
    }
}
