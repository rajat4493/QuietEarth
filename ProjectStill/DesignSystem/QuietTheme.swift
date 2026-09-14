import SwiftUI
import UIKit

// Sunlit QuietEarth (M1.6).
// Bright, spacious and optimistic rather than muted earthy calm. Dark mode is
// night, not gloom: accents stay bright instead of desaturating into a cave.
private func adaptive(
    light: (CGFloat, CGFloat, CGFloat),
    dark: (CGFloat, CGFloat, CGFloat)
) -> Color {
    Color(
        uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.0 / 255, green: rgb.1 / 255, blue: rgb.2 / 255, alpha: 1)
        }
    )
}

extension Color {
    /// Canvas. Sunlit ivory, never brown-beige.
    static let quietPaper = adaptive(light: (253, 247, 236), dark: (16, 27, 24))

    /// Primary text and primary action fill. Deep spruce.
    static let quietInk = adaptive(light: (18, 51, 43), dark: (242, 239, 230))

    /// Secondary text. Contrast-checked against both canvas and card.
    static let quietSecondaryInk = adaptive(light: (65, 89, 78), dark: (185, 201, 192))

    /// Card and sheet surfaces. White on ivory is what makes cards read as tactile.
    static let quietMist = adaptive(light: (255, 255, 255), dark: (24, 39, 34))

    /// Fresh sea glass: active states, illustration, large fills.
    static let quietNeem = adaptive(light: (63, 174, 140), dark: (111, 211, 180))

    /// Energy accent, and the colour of tension in the comparison UI.
    static let quietClay = adaptive(light: (238, 122, 82), dark: (255, 150, 112))

    /// Sunlight highlight. Used sparingly.
    static let quietSaffron = adaptive(light: (242, 193, 78), dark: (247, 214, 122))

    static let quietMintWash = adaptive(light: (220, 241, 232), dark: (28, 56, 47))
    static let quietCoralWash = adaptive(light: (253, 230, 219), dark: (61, 38, 30))
    static let quietLemonWash = adaptive(light: (251, 240, 206), dark: (58, 48, 26))

    static let quietHairline = adaptive(light: (232, 223, 206), dark: (42, 58, 51))

    /// Text placed on a filled primary action.
    static let quietOnAccent = adaptive(light: (255, 251, 243), dark: (16, 27, 24))
}

enum QuietSpacing {
    static let compact: CGFloat = 8
    static let standard: CGFloat = 16
    static let generous: CGFloat = 24
    static let section: CGFloat = 36
}

enum QuietRadius {
    static let card: CGFloat = 24
    static let control: CGFloat = 18
}

enum QuietMotion {
    /// Playful but not bouncy. Arrivals and selections.
    static let arrive = Animation.spring(response: 0.32, dampingFraction: 0.82)
    static let select = Animation.spring(response: 0.18, dampingFraction: 0.86)
}

extension Font {
    static let quietDisplay = Font.system(.largeTitle, design: .serif, weight: .medium)
    static let quietTitle = Font.system(.title2, design: .serif, weight: .semibold)
    static let quietBody = Font.system(.body, design: .default, weight: .regular)
}

/// A white card on the sunlit canvas, with one soft warm elevation.
struct QuietCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(QuietSpacing.standard)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.quietMist)
            .clipShape(RoundedRectangle(cornerRadius: QuietRadius.card, style: .continuous))
            .shadow(color: Color(red: 60 / 255, green: 40 / 255, blue: 20 / 255).opacity(0.06), radius: 12, y: 4)
    }
}

extension View {
    func quietCard() -> some View { modifier(QuietCardModifier()) }
}
