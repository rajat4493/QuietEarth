import SwiftUI

struct ProfileView: View {
    let profile: AttentionProfile
    let hasQuestionnaireEvidence: Bool
    let hasExternalEvidence: Bool
    let onQuestionnaire: () -> Void
    let onUseAI: () -> Void
    @State private var showsAnswerReview = false
    @State private var showsComparison = false

    private var hypotheses: [WorkingHypothesis] {
        HypothesisEngine().hypotheses(for: profile)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("QUIETEARTH / YOUR REFLECTION")
                        .font(.caption.weight(.semibold))
                        .tracking(1.8)
                        .foregroundStyle(Color.quietNeem)

                    Text(profile.interpretation.title)
                        .font(.system(.title, design: .default, weight: .regular))
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("profile.title")

                }

                if let primaryHypothesis = hypotheses.first {
                    VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                        Text("Working hypothesis")
                            .font(.quietTitle)
                        Text("A claim to test, not a conclusion about you.")
                            .font(.subheadline)
                            .foregroundStyle(Color.quietInk.opacity(0.6))
                        HypothesisCard(hypothesis: primaryHypothesis)
                    }
                }

                if !hasQuestionnaireEvidence {
                    Button("Complete questionnaire to compare", action: onQuestionnaire)
                        .buttonStyle(.primaryAction)
                        .accessibilityIdentifier("profile.completeQuestionnaire")
                } else if hasExternalEvidence {
                    Button("How the two views compare") {
                        showsComparison = true
                    }
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("profile.compareEvidence")
                } else {
                    Button("Use your AI for another view", action: onUseAI)
                        .buttonStyle(.primaryAction)
                        .accessibilityIdentifier("profile.useAI")
                }

                DisclosureGroup("More evidence and details") {
                    VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                        ForEach(Array(hypotheses.dropFirst())) { hypothesis in
                            HypothesisCard(hypothesis: hypothesis)
                        }

                        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                            Text("Why we think this").font(.headline)
                            ForEach(profile.interpretation.reasons, id: \.self) { reason in
                                Text(reason)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.quietInk.opacity(0.68))
                            }
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Questionnaire detail")
                                .font(.headline)
                                .padding(.bottom, QuietSpacing.compact)
                            ForEach(profile.dimensions) { assessment in
                                DimensionCard(assessment: assessment)
                                if assessment.id != profile.dimensions.last?.id {
                                    Divider().opacity(0.5)
                                }
                            }
                        }
                    }
                    .padding(.top, QuietSpacing.standard)
                }
                .font(.headline)
                .foregroundStyle(Color.quietInk)

                if hasQuestionnaireEvidence {
                    Button("Review and revise answers") {
                        showsAnswerReview = true
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .foregroundStyle(Color.quietInk)
                    .background(Color.quietSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.quietInk.opacity(0.12), lineWidth: 1)
                    }
                    .accessibilityIdentifier("profile.reviewAnswers")
                }

                Text("Provisional and descriptive—not a diagnosis or permanent type.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .sheet(isPresented: $showsAnswerReview) {
            AnswerReviewView()
        }
        .sheet(isPresented: $showsComparison) {
            EvidenceComparisonView(profile: profile)
        }
    }
}

private struct HypothesisCard: View {
    let hypothesis: WorkingHypothesis

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                if !hypothesis.basis.isEmpty {
                    VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                        Text("Basis").font(.caption.weight(.bold))
                        ForEach(hypothesis.basis, id: \.self) { item in
                            Text(item).font(.subheadline)
                        }
                    }
                }
                if let counterpoint = hypothesis.counterpoint {
                    Label(counterpoint, systemImage: "arrow.left.arrow.right")
                        .font(.subheadline)
                        .foregroundStyle(Color.quietCoral)
                }
                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("What would support it").font(.caption.weight(.bold))
                    Text(hypothesis.prediction).font(.subheadline)
                    Text("What would weaken it").font(.caption.weight(.bold))
                    Text(hypothesis.disconfirmation).font(.subheadline)
                }
                .foregroundStyle(Color.quietInk.opacity(0.72))
            }
            .padding(.top, QuietSpacing.standard)
        } label: {
            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                HStack {
                    Text(hypothesis.support.title.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(Color.quietInk.opacity(0.7))
                    Spacer()
                    Text("\(hypothesis.evidenceStrength.title) evidence")
                        .font(.caption2)
                        .foregroundStyle(Color.quietInk.opacity(0.56))
                }
                Text(hypothesis.statement)
                    .multilineTextAlignment(.leading)
                    .font(.body)
                    .foregroundStyle(Color.quietInk)
            }
        }
        .padding(QuietSpacing.standard)
        .background(Color.quietMint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityIdentifier("profile.hypothesis.\(hypothesis.id)")
    }
}

private struct DimensionCard: View {
    let assessment: DimensionAssessment

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                ForEach(assessment.evidence) { signal in
                    Label(signal.summary, systemImage: signal.direction >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.subheadline)
                        .foregroundStyle(Color.quietInk.opacity(0.72))
                }
                ForEach(assessment.contradictions, id: \.self) { contradiction in
                    Label(contradiction, systemImage: "arrow.left.arrow.right")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.quietClay)
                }
            }
            .padding(.top, QuietSpacing.standard)
        } label: {
            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                HStack {
                    Text(assessment.dimension.title)
                        .font(.headline)
                    Spacer()
                    Text(assessment.qualitativeLevel)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.quietNeem)
                }
                HStack {
                    Image(systemName: "leaf.fill")
                    Text("\(assessment.evidenceStrength.title) questionnaire evidence")
                }
                .font(.caption2)
                .foregroundStyle(Color.quietInk.opacity(0.58))
            }
        }
        .padding(.vertical, QuietSpacing.standard)
    }
}
