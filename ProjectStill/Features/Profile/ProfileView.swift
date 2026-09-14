import SwiftUI

struct ProfileView: View {
    let profile: AttentionProfile
    let hasQuestionnaireEvidence: Bool
    let hasExternalEvidence: Bool
    let onQuestionnaire: () -> Void
    let onUseAI: () -> Void
    @State private var showsAnswerReview = false
    @State private var showsComparison = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                header
                actions
                reasons

                if !profile.testableHypotheses.isEmpty {
                    hypotheses
                }
                if !profile.unsupportedObservations.isEmpty {
                    unresolved
                }

                dimensions

                if hasQuestionnaireEvidence {
                    Button("Review and revise answers") {
                        showsAnswerReview = true
                    }
                    .buttonStyle(.quietSecondary)
                    .accessibilityIdentifier("profile.reviewAnswers")
                }

                Text("These are provisional readings of your own answers and, where you added them, observations you approved. They are not a diagnosis, a score, or a permanent type.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietSecondaryInk)
            }
            .padding(QuietSpacing.generous)
        }
        .background(
            ZStack(alignment: .top) {
                Color.quietPaper
                ContourField(alignment: .topTrailing, mode: hasExternalEvidence ? .divergent : .single)
                    .frame(height: 220)
                    .opacity(0.9)
            }
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showsAnswerReview) {
            AnswerReviewView()
        }
        .sheet(isPresented: $showsComparison) {
            EvidenceComparisonView(profile: profile)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text("WHAT WE THINK SO FAR")
                .font(.caption.weight(.semibold))
                .tracking(1.8)
                .foregroundStyle(Color.quietNeem)

            Text(profile.interpretation.title)
                .font(.quietDisplay)
                .foregroundStyle(Color.quietInk)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("profile.title")

            Text(profile.interpretation.summary)
                .font(.quietBody)
                .foregroundStyle(Color.quietSecondaryInk)
                .lineSpacing(4)

            HStack(spacing: QuietSpacing.compact) {
                Text("How sure we are")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.quietSecondaryInk)
                EvidenceStrengthBadge(strength: profile.overallStrength)
            }
            .padding(.top, QuietSpacing.compact)
            .accessibilityIdentifier("profile.strength")
        }
    }

    @ViewBuilder
    private var actions: some View {
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
    }

    private var reasons: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text("Why we think this")
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            ForEach(profile.interpretation.reasons, id: \.self) { reason in
                Label(reason, systemImage: "line.3.horizontal.decrease.circle")
                    .font(.subheadline)
                    .foregroundStyle(Color.quietSecondaryInk)
            }
        }
    }

    private var hypotheses: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            Text("What we're testing")
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            Text("Each of these is a hypothesis with a way it could be shown wrong. Practice is what settles them.")
                .font(.subheadline)
                .foregroundStyle(Color.quietSecondaryInk)

            ForEach(profile.testableHypotheses) { hypothesis in
                HypothesisCard(hypothesis: hypothesis)
            }
        }
        .accessibilityIdentifier("profile.hypotheses")
    }

    private var unresolved: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text("What we can't tell yet")
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            ForEach(profile.unsupportedObservations) { observation in
                VStack(alignment: .leading, spacing: 4) {
                    Text(observation.pattern)
                        .font(.subheadline)
                        .foregroundStyle(Color.quietInk)
                    EvidenceStrengthBadge(strength: observation.strength)
                }
                .quietCard()
            }
        }
        .accessibilityIdentifier("profile.unresolved")
    }

    private var dimensions: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            Text("What your answers lean toward")
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            ForEach(profile.dimensions) { assessment in
                DimensionCard(assessment: assessment)
            }
        }
    }
}

private struct HypothesisCard: View {
    let hypothesis: WorkingHypothesis

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            HStack(alignment: .top) {
                Text(hypothesis.theme.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.quietSecondaryInk)
                Spacer()
                Text(hypothesis.supportState.title.uppercased())
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(stateWash)
                    .foregroundStyle(Color.quietInk)
                    .clipShape(Capsule())
            }

            Text(hypothesis.statement)
                .font(.headline)
                .foregroundStyle(Color.quietInk)

            if let tension = hypothesis.tension {
                Label(tension, systemImage: "arrow.left.arrow.right")
                    .font(.subheadline)
                    .foregroundStyle(Color.quietClay)
            }

            detail("If this holds", hypothesis.prediction, icon: "arrow.right.circle")
            detail("What would show it's wrong", hypothesis.disconfirmation, icon: "xmark.circle")

            HStack(spacing: QuietSpacing.compact) {
                Text("Evidence so far")
                    .font(.caption)
                    .foregroundStyle(Color.quietSecondaryInk)
                EvidenceStrengthBadge(strength: hypothesis.strength)
            }
        }
        .quietCard()
    }

    private func detail(_ title: String, _ text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.quietSecondaryInk)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.quietInk)
        }
    }

    private var stateWash: Color {
        switch hypothesis.supportState {
        case .contested: .quietCoralWash
        case .converging: .quietMintWash
        default: .quietLemonWash
        }
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
                        .foregroundStyle(Color.quietSecondaryInk)
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
                Text(assessment.dimension.title)
                    .font(.headline)
                    .foregroundStyle(Color.quietInk)
                Text(lean)
                    .font(.subheadline)
                    .foregroundStyle(Color.quietSecondaryInk)
                EvidenceStrengthBadge(strength: .fromInternalConfidence(assessment.confidence))
            }
        }
        .tint(Color.quietNeem)
        .quietCard()
    }

    /// Words, never a percentage: the internal score is a routing mechanic.
    private var lean: String {
        let dimension = assessment.dimension
        switch assessment.score {
        case ..<0.34: "Leans clearly toward “\(dimension.lowLabel.lowercased())”"
        case ..<0.45: "Leans slightly toward “\(dimension.lowLabel.lowercased())”"
        case ..<0.56: "No clear lean either way"
        case ..<0.67: "Leans slightly toward “\(dimension.highLabel.lowercased())”"
        default: "Leans clearly toward “\(dimension.highLabel.lowercased())”"
        }
    }
}
