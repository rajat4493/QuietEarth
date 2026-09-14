import SwiftUI

struct HowItWorksView: View {
    let onContinue: () -> Void

    private let steps = [
        ("Understand", "Describe how your attention behaves and choose what evidence to share."),
        ("Experiment", "Try a short practice selected as a hypothesis, not a verdict."),
        ("Adapt", "Reflect on what happened so the recommendation can change with evidence.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                Text("A small experiment in attention")
                    .font(.quietDisplay)
                    .foregroundStyle(Color.quietInk)
                    .accessibilityAddTraits(.isHeader)

                Text("QuietEarth begins with a provisional picture of your attention. You can explore the evidence and revise your answers at any time.")
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk.opacity(0.76))
                    .lineSpacing(5)

                VStack(spacing: QuietSpacing.generous) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: QuietSpacing.standard) {
                            Text("\(index + 1)")
                                .font(.headline)
                                    .foregroundStyle(Color.quietOnAccent)
                                .frame(width: 36, height: 36)
                                .background(Color.quietNeem)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                                Text(step.0)
                                    .font(.quietTitle)
                                    .foregroundStyle(Color.quietInk)
                                Text(step.1)
                                    .font(.quietBody)
                                    .foregroundStyle(Color.quietInk.opacity(0.72))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button("Choose what to share", action: onContinue)
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("howItWorks.continue")
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("How this works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HowItWorksView(onContinue: {})
    }
}
