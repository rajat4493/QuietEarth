import SwiftUI

struct OpeningView: View {
    var primaryTitle = "Understand my mind"
    let onBegin: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("QuietEarthLandscape")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.40))
                    .accessibilityHidden(true)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("QuietEarth")
                            .font(.title2.weight(.medium))
                            .tracking(1)
                            .padding(.top, 24)
                        Spacer(minLength: 100)
                        Text("A little space.\nA clearer beginning.")
                            .font(.quietDisplay)
                            .accessibilityAddTraits(.isHeader)
                        Text("Discover how your attention moves, and what helps it settle.")
                            .font(.body)
                            .lineSpacing(4)
                        Spacer(minLength: 60)
                        Button(primaryTitle, action: onBegin)
                            .font(.headline)
                            .foregroundStyle(Color.black)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .accessibilityIdentifier("opening.begin")
                        Button("How this works", action: onLearnMore)
                            .font(.body)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("opening.learnMore")
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                    .frame(minHeight: geometry.size.height, alignment: .topLeading)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
