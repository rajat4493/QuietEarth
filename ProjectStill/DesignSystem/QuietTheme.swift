import SwiftUI
import UIKit

extension Color {
    static let quietPaper = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 16 / 255, green: 36 / 255, blue: 31 / 255, alpha: 1)
                : UIColor(red: 255 / 255, green: 249 / 255, blue: 239 / 255, alpha: 1)
        }
    )

    static let quietInk = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 248 / 255, green: 255 / 255, blue: 249 / 255, alpha: 1)
                : UIColor(red: 23 / 255, green: 61 / 255, blue: 53 / 255, alpha: 1)
        }
    )

    static let quietNeem = Color(red: 47 / 255, green: 107 / 255, blue: 91 / 255)
    static let quietOnAccent = Color(red: 255 / 255, green: 254 / 255, blue: 250 / 255)
    static let quietClay = Color(red: 241 / 255, green: 132 / 255, blue: 104 / 255)
    static let quietSaffron = Color(red: 245 / 255, green: 214 / 255, blue: 111 / 255)
    static let quietSeaGlass = Color(red: 114 / 255, green: 182 / 255, blue: 162 / 255)
    static let quietMint = Color(red: 221 / 255, green: 242 / 255, blue: 232 / 255)
    static let quietCoral = Color(red: 241 / 255, green: 132 / 255, blue: 104 / 255)
    static let quietSunlight = Color(red: 245 / 255, green: 214 / 255, blue: 111 / 255)
    static let quietSurface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 25 / 255, green: 51 / 255, blue: 44 / 255, alpha: 1)
                : UIColor(red: 255 / 255, green: 254 / 255, blue: 250 / 255, alpha: 1)
        }
    )
    static let quietMist = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 25 / 255, green: 51 / 255, blue: 44 / 255, alpha: 1)
                : UIColor(red: 221 / 255, green: 242 / 255, blue: 232 / 255, alpha: 1)
        }
    )
}

enum QuietSpacing {
    static let compact: CGFloat = 8
    static let standard: CGFloat = 16
    static let generous: CGFloat = 24
    static let section: CGFloat = 36
}

extension Font {
    static let quietDisplay = Font.system(.largeTitle, design: .serif, weight: .medium)
    static let quietTitle = Font.system(.title2, design: .serif, weight: .semibold)
    static let quietBody = Font.system(.body, design: .default, weight: .regular)
}

private struct QuietCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.quietSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.quietSeaGlass.opacity(0.3), lineWidth: 1)
            }
    }
}

extension View {
    func quietCard() -> some View {
        modifier(QuietCardModifier())
    }
}
