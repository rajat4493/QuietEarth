import SwiftUI

struct OpeningView: View {
    var primaryTitle = "Understand my mind"
    let onBegin: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        ZStack {
            Color.quietPaper.ignoresSafeArea()

            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                HStack {
                    Text("PROJECT STILL")
                        .font(.caption.weight(.semibold))
                        .tracking(2.4)
                    Spacer()
                    Image(systemName: "circle.dotted")
                        .font(.title2)
                        .foregroundStyle(Color.quietCoral)
                }

                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                    AttentionPathHero()
                    Text("Meditation should fit your mind.")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                    Text("First, notice how your attention moves.")
                        .font(.title3)
                        .foregroundStyle(Color.quietInk.opacity(0.62))
                }

                Spacer(minLength: 28)
                VStack(spacing: QuietSpacing.standard) {
                    Button(primaryTitle, action: onBegin)
                        .buttonStyle(.primaryAction)
                        .accessibilityIdentifier("opening.begin")

                    Button("How this works", action: onLearnMore)
                        .font(.headline)
                        .frame(minHeight: 44)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityIdentifier("opening.learnMore")
                }

            }
            .padding(.horizontal, QuietSpacing.generous)
            .padding(.vertical, QuietSpacing.section)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    OpeningView(onBegin: {}, onLearnMore: {})
}
