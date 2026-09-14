import SwiftUI
import SwiftData

/// Compares statements, not scores. Nothing on this screen is a number.
struct EvidenceComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let profile: AttentionProfile

    private var comparisons: [SourceComparison] { profile.sourceComparisons ?? [] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QuietSpacing.section) {
                    Text("How the two views compare")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("comparison.title")

                    if !profile.externalSelfReportStatements.isEmpty {
                        section("You described yourself as", profile.externalSelfReportStatements)
                    }
                    section("What was observed in your conversations", profile.observations.map(\.pattern))

                    if !profile.externalDifferences.isEmpty {
                        section("Where those differ", profile.externalDifferences, tint: .quietClay)
                    }

                    VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                        Text("Our current interpretation")
                            .font(.quietTitle)
                            .foregroundStyle(Color.quietInk)
                        Text("\(profile.interpretation.title). \(profile.interpretation.summary)")
                            .font(.quietBody)
                            .foregroundStyle(Color.quietSecondaryInk)
                        HStack(spacing: QuietSpacing.compact) {
                            Text("How sure we are")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.quietSecondaryInk)
                            EvidenceStrengthBadge(strength: profile.overallStrength)
                        }
                    }

                    if !comparisons.isEmpty {
                        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                            Text("Theme by theme")
                                .font(.quietTitle)
                                .foregroundStyle(Color.quietInk)
                            ForEach(comparisons) { comparison in
                                SourceComparisonCard(comparison: comparison)
                            }
                        }
                    }

                    if let alternatives = profile.alternativeInterpretations, !alternatives.isEmpty {
                        section("Other explanations we considered", alternatives)
                    }
                    if !profile.externalLimitations.isEmpty {
                        section("Limitations your AI noted", profile.externalLimitations)
                    }

                    Button("Remove AI evidence", role: .destructive) {
                        QuestionnairePersistence.removeExternalProfile(in: modelContext)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .accessibilityIdentifier("comparison.removeAI")

                    Text("Removing this evidence restores the questionnaire-only profile. Your pasted source text was never uploaded.")
                        .font(.footnote)
                        .foregroundStyle(Color.quietSecondaryInk)
                }
                .padding(QuietSpacing.generous)
            }
            .background(
                ZStack(alignment: .top) {
                    Color.quietPaper
                    ContourField(alignment: .topTrailing, mode: .divergent)
                        .frame(height: 200)
                }
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func section(_ title: String, _ items: [String], tint: Color = .quietSecondaryInk) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title)
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            if items.isEmpty {
                Text("Nothing recorded here yet.")
                    .font(.quietBody)
                    .foregroundStyle(Color.quietSecondaryInk)
            } else {
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "circle.fill")
                        .labelStyle(.titleAndIcon)
                        .imageScale(.small)
                        .font(.subheadline)
                        .foregroundStyle(tint)
                }
            }
        }
    }
}

private struct SourceComparisonCard: View {
    let comparison: SourceComparison

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            HStack(alignment: .top) {
                Text(comparison.theme.title)
                    .font(.headline)
                    .foregroundStyle(Color.quietInk)
                Spacer()
                Text(relationshipTitle)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(relationshipWash)
                    .foregroundStyle(Color.quietInk)
                    .clipShape(Capsule())
            }

            statements("You reported", comparison.questionnaireEvidence)
            statements("Observed", comparison.externalAIEvidence)

            if comparison.relationship == .disagreement {
                Label(
                    "These point in different directions. Both are kept, and this is what we test first.",
                    systemImage: "arrow.left.arrow.right"
                )
                .font(.caption)
                .foregroundStyle(Color.quietClay)
            }
        }
        .quietCard()
    }

    @ViewBuilder
    private func statements(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.quietSecondaryInk)
            if items.isEmpty {
                Text("—")
                    .font(.subheadline)
                    .foregroundStyle(Color.quietSecondaryInk)
            } else {
                ForEach(items.prefix(3), id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(Color.quietInk)
                }
            }
        }
    }

    private var relationshipTitle: String {
        switch comparison.relationship {
        case .agreement: "AGREES"
        case .disagreement: "DIFFERS"
        case .singleSource: "ONE SOURCE"
        }
    }

    private var relationshipWash: Color {
        switch comparison.relationship {
        case .agreement: .quietMintWash
        case .disagreement: .quietCoralWash
        case .singleSource: .quietLemonWash
        }
    }
}
