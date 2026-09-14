import SwiftUI

struct ProfileView: View {
    let profile: AttentionProfile
    @State private var showsAnswerReview = false

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
                        Text("Dimensions")
                            .font(.quietTitle)
                        Spacer()
                        Text("Confidence \(profile.overallConfidence, format: .percent.precision(.fractionLength(0)))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.quietNeem)
                    }

                    ForEach(profile.dimensions) { assessment in
                        DimensionCard(assessment: assessment)
                    }
                }

                Button("Review and revise answers") {
                    showsAnswerReview = true
                }
                .buttonStyle(.primaryAction)
                .accessibilityIdentifier("profile.reviewAnswers")

                Text("This is a provisional interpretation of questionnaire answers, not a diagnosis or a permanent type.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .sheet(isPresented: $showsAnswerReview) {
            AnswerReviewView()
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
                    Text(assessment.score, format: .percent.precision(.fractionLength(0)))
                        .font(.headline.monospacedDigit())
                }
                ProgressView(value: assessment.score)
                    .tint(.quietNeem)
                HStack {
                    Text(assessment.dimension.lowLabel)
                    Spacer()
                    Text("confidence \(assessment.confidence, format: .percent.precision(.fractionLength(0)))")
                    Spacer()
                    Text(assessment.dimension.highLabel)
                }
                .font(.caption2)
                .foregroundStyle(Color.quietInk.opacity(0.58))
            }
        }
        .padding(QuietSpacing.standard)
        .background(Color.quietMist)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

