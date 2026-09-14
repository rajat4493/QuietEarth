import SwiftUI

struct OpeningView: View {
    @AppStorage("appearance.landscape") private var landscape = false
    @State private var showsAppearance = false
    var primaryTitle = "Understand my mind"
    let onBegin: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if landscape {
                Image(QuietTheme.landscapeAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.40))
                    .accessibilityHidden(true)
                } else {
                    Color.quietPaper
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("QuietEarth")
                            .font(.title2.weight(.medium))
                            .tracking(1)
                            .padding(.top, 24)
                        Button("Appearance") { showsAppearance = true }
                            .font(.subheadline)
                            .frame(minHeight: 44)
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
                            .foregroundStyle(landscape ? Color.black : Color.quietOnAccent)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(landscape ? Color.white : Color.quietNeem, in: RoundedRectangle(cornerRadius: QuietTheme.cardRadius))
                            .accessibilityIdentifier("opening.begin")
                        Button("How this works", action: onLearnMore)
                            .font(.body)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("opening.learnMore")
                    }
                    .foregroundStyle(landscape ? Color.white : Color.quietInk)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                    .frame(minHeight: geometry.size.height, alignment: .topLeading)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsAppearance) {
            NavigationStack {
                AppearanceSettingsView()
                    .toolbar { Button("Done") { showsAppearance = false } }
            }
        }
    }
}
