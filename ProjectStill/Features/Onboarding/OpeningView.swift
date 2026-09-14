import SwiftUI

struct OpeningView: View {
    var primaryTitle = "Understand my mind"
    let onBegin: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        ZStack {
            Color.quietPaper.ignoresSafeArea()
            ContourField(alignment: .topTrailing)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                Text("PROJECT STILL")
                    .font(.caption.weight(.semibold))
                    .tracking(2.4)
                    .foregroundStyle(Color.quietNeem)

                AttentionPathHero()

                Text("Meditation should fit the mind doing it.")
                    .font(.quietDisplay)
                    .foregroundStyle(Color.quietInk)
                    .accessibilityAddTraits(.isHeader)

                Text("We start by understanding how your attention moves — not by assuming everyone needs the same practice.")
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk.opacity(0.76))
                    .lineSpacing(5)

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

                Spacer(minLength: 0)
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
