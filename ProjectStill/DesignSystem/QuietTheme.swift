import SwiftUI
import UIKit

extension Color {
    static let quietPaper = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 18 / 255, green: 18 / 255, blue: 20 / 255, alpha: 1)
                : UIColor(red: 247 / 255, green: 247 / 255, blue: 249 / 255, alpha: 1)
        }
    )

    static let quietInk = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 244 / 255, green: 244 / 255, blue: 246 / 255, alpha: 1)
                : UIColor(red: 30 / 255, green: 30 / 255, blue: 34 / 255, alpha: 1)
        }
    )

    static let quietNeem = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 238 / 255, green: 238 / 255, blue: 241 / 255, alpha: 1)
                : UIColor(red: 36 / 255, green: 36 / 255, blue: 41 / 255, alpha: 1)
        }
    )
    static let quietOnAccent = Color.white
    static let quietClay = Color(red: 224 / 255, green: 91 / 255, blue: 78 / 255)
    static let quietSaffron = Color(red: 247 / 255, green: 177 / 255, blue: 88 / 255)
    static let quietSeaGlass = Color(red: 168 / 255, green: 168 / 255, blue: 178 / 255)
    static let quietMint = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 35 / 255, green: 35 / 255, blue: 40 / 255, alpha: 1)
                : UIColor(red: 238 / 255, green: 238 / 255, blue: 242 / 255, alpha: 1)
        }
    )
    static let quietCoral = Color(red: 224 / 255, green: 91 / 255, blue: 78 / 255)
    static let quietSunlight = Color(red: 247 / 255, green: 177 / 255, blue: 88 / 255)
    static let quietSurface = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 29 / 255, green: 29 / 255, blue: 33 / 255, alpha: 1)
                : UIColor.white
        }
    )
    static let quietMist = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 38 / 255, green: 37 / 255, blue: 47 / 255, alpha: 1)
                : UIColor(red: 235 / 255, green: 232 / 255, blue: 249 / 255, alpha: 1)
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
    static let quietDisplay = Font.system(size: 38, weight: .bold, design: .rounded)
    static let quietTitle = Font.system(.title2, design: .rounded, weight: .semibold)
    static let quietBody = Font.system(.body, design: .default, weight: .regular)
}

private struct QuietCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.quietSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.quietInk.opacity(0.08), lineWidth: 1)
            }
    }
}

extension View {
    func quietCard() -> some View {
        modifier(QuietCardModifier())
    }
}
