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
            VStack(alignment: .leading, spacing: QuietSpacing.generous) {
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
                        .foregroundStyle(Color.quietInk.opacity(0.74))
                        .lineSpacing(4)
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

                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("Why we think this")
                        .font(.quietTitle)
                        .foregroundStyle(Color.quietInk)
                    ForEach(profile.interpretation.reasons, id: \.self) { reason in
                        Label(reason, systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.quietInk.opacity(0.72))
                    }
                }

                VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                    HStack {
                        Text("What your answers suggest")
                            .font(.quietTitle)
                        Spacer()
                        Text("\(profile.evidenceStrength.title) evidence")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.quietNeem)
                    }

                    ForEach(profile.dimensions) { assessment in
                        DimensionCard(assessment: assessment)
                    }
                }

                if hasQuestionnaireEvidence {
                    Button("Review and revise answers") {
                        showsAnswerReview = true
                    }
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("profile.reviewAnswers")
                }

                Text("This is a provisional interpretation of questionnaire answers. The labels are descriptive ranges, not psychometric measurements, diagnoses, or permanent types.")
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
        .padding(QuietSpacing.standard)
        .quietCard()
    }
}
