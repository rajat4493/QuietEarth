import SwiftUI

/// Three zones only: today's practice, what we're learning, and the experiment.
struct HomeView: View {
    let experiment: Experiment
    let recommendation: PracticeRecommendation
    let profile: AttentionProfile
    let onBegin: () -> Void
    let onReview: () -> Void
    let onOpenProfile: () -> Void
    let onSettings: () -> Void

    private var dayIndex: Int { experiment.dayIndex() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                todayCard
                learningCard
                experimentCard
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("QuietEarth")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
                .accessibilityIdentifier("home.settings")
            }
        }
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.standard) {
            Text("TODAY")
                .font(.caption.weight(.semibold))
                .tracking(1.6)
                .foregroundStyle(Color.quietInk.opacity(0.6))

            Text(recommendation.template.title)
                .font(.quietDisplay)
                .foregroundStyle(Color.quietInk)
                .accessibilityIdentifier("home.practiceTitle")

            Text("\(recommendation.minutes) minutes · \(recommendation.anchor.title.lowercased())")
                .font(.subheadline)
                .foregroundStyle(Color.quietInk.opacity(0.7))

            Text(recommendation.template.purpose)
                .font(.quietBody)
                .foregroundStyle(Color.quietInk.opacity(0.8))

            DisclosureGroup("Why this practice") {
                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    ForEach(recommendation.reasons, id: \.self) { reason in
                        Label(reason, systemImage: "circle.fill")
                            .labelStyle(.titleAndIcon)
                            .imageScale(.small)
                            .font(.subheadline)
                            .foregroundStyle(Color.quietInk.opacity(0.78))
                    }
                    Text(recommendation.template.successMeaning)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.quietInk)
                        .padding(.top, QuietSpacing.compact)

                    if let reference = ClassicalReference.reference(for: recommendation.template.id) {
                        DisclosureGroup("Where this comes from") {
                            VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                                ProvenanceCard(reference: reference)
                                Text(ClassicalReference.frameNote)
                                    .font(.footnote)
                                    .foregroundStyle(Color.quietInk.opacity(0.6))
                            }
                            .padding(.top, QuietSpacing.compact)
                        }
                        .accessibilityIdentifier("home.whereThisComesFrom")
                        .padding(.top, QuietSpacing.compact)
                    }
                }
                .padding(.top, QuietSpacing.compact)
            }
            .accessibilityIdentifier("home.whyThisPractice")

            if experiment.isReadyForReview() {
                Button("See what survived the week", action: onReview)
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("home.review")
            } else if experiment.practisedToday() {
                Button("Practise again", action: onBegin)
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("home.begin")
                Text("You've already practised today. Another session is fine, not required.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
            } else {
                Button("Begin", action: onBegin)
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("home.begin")
            }
        }
        .padding(QuietSpacing.standard)
        .quietCard()
    }

    private var learningCard: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text("WHAT WE'RE LEARNING")
                .font(.caption.weight(.semibold))
                .tracking(1.6)
                .foregroundStyle(Color.quietInk.opacity(0.6))

            Text(experiment.hypothesisStatement ?? profile.interpretation.summary)
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)

            Label(experiment.prediction, systemImage: "arrow.right.circle")
                .font(.subheadline)
                .foregroundStyle(Color.quietInk.opacity(0.78))
            Label(experiment.disconfirmation, systemImage: "xmark.circle")
                .font(.subheadline)
                .foregroundStyle(Color.quietInk.opacity(0.78))

            Button("See the full profile", action: onOpenProfile)
                .font(.subheadline.weight(.medium))
                .frame(minHeight: 44)
                .accessibilityIdentifier("home.openProfile")
        }
        .padding(QuietSpacing.standard)
        .quietCard()
    }

    private var experimentCard: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text("YOUR EXPERIMENT")
                .font(.caption.weight(.semibold))
                .tracking(1.6)
                .foregroundStyle(Color.quietInk.opacity(0.6))

            Text("Day \(dayIndex) of 7")
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)
                .accessibilityIdentifier("home.dayIndex")

            // Counts of sessions actually completed — not a streak, not a score.
            Text("\(experiment.completedSessions.count) sessions completed so far. Missing a day costs nothing.")
                .font(.subheadline)
                .foregroundStyle(Color.quietInk.opacity(0.7))

            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { day in
                    Capsule()
                        .fill(day <= dayIndex ? Color.quietInk.opacity(0.45) : Color.quietInk.opacity(0.12))
                        .frame(height: 4)
                }
            }
            .accessibilityHidden(true)
        }
        .padding(QuietSpacing.standard)
        .quietCard()
    }
}
