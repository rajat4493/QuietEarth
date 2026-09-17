import SwiftUI

/// "What survived the experiment?" — initial belief against the observed week.
struct DaySevenReviewView: View {
    let experiment: Experiment
    let review: DaySevenReview
    let nextRecommendation: PracticeRecommendation
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("What survived the experiment?")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("dayseven.title")
                    Text(review.summary)
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk.opacity(0.8))
                }

                section("What we thought at the start") {
                    Text(experiment.hypothesisStatement ?? "A general starting point, with no specific claim under test.")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk)
                    Label(experiment.prediction, systemImage: "arrow.right.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.quietInk.opacity(0.75))
                }

                section("What the week actually showed") {
                    ForEach(review.observed, id: \.self) { line in
                        Label(line, systemImage: "circle.fill")
                            .labelStyle(.titleAndIcon)
                            .imageScale(.small)
                            .font(.subheadline)
                            .foregroundStyle(Color.quietInk.opacity(0.8))
                    }
                }

                section("Verdict") {
                    HStack(spacing: QuietSpacing.compact) {
                        Image(systemName: verdictIcon)
                            .foregroundStyle(verdictTint)
                        Text(verdictTitle)
                            .font(.headline)
                            .foregroundStyle(Color.quietInk)
                    }
                    .accessibilityIdentifier("dayseven.verdict")

                    ForEach(review.reasons, id: \.self) { reason in
                        Text(reason)
                            .font(.subheadline)
                            .foregroundStyle(Color.quietInk.opacity(0.78))
                    }
                }

                section("Next week") {
                    Text("\(nextRecommendation.template.title) · \(nextRecommendation.minutes) minutes · \(nextRecommendation.anchor.title.lowercased())")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk)
                    Text(review.outcome == .insufficientEvidence
                         ? "We are keeping everything the same and gathering more sessions."
                         : "\(review.outcome.title). The change is based only on what you reported.")
                        .font(.subheadline)
                        .foregroundStyle(Color.quietInk.opacity(0.75))
                }

                Button("Start the next week", action: onContinue)
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("dayseven.continue")

                Text("Nothing here is a measurement of you. It is a record of what you reported across \(experiment.outcomes.count) sessions.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Day 7")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var verdictTitle: String {
        switch review.predictionHeld {
        case .some(true): "What we expected is what happened"
        case .some(false): "What we expected is not what happened"
        case .none: "Not enough to say either way"
        }
    }

    private var verdictIcon: String {
        switch review.predictionHeld {
        case .some(true): "checkmark.circle"
        case .some(false): "arrow.triangle.2.circlepath"
        case .none: "questionmark.circle"
        }
    }

    private var verdictTint: Color {
        switch review.predictionHeld {
        case .some(false): Color.quietClay
        default: Color.quietInk.opacity(0.7)
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title)
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(QuietSpacing.standard)
        .quietCard()
    }
}
