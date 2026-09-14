import SwiftUI
import UIKit

extension Color {
    static let quietPaper = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 22 / 255, green: 26 / 255, blue: 23 / 255, alpha: 1)
                : UIColor(red: 244 / 255, green: 240 / 255, blue: 231 / 255, alpha: 1)
        }
    )

    static let quietInk = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 244 / 255, green: 240 / 255, blue: 231 / 255, alpha: 1)
                : UIColor(red: 37 / 255, green: 42 / 255, blue: 38 / 255, alpha: 1)
        }
    )

    static let quietNeem = Color(red: 94 / 255, green: 110 / 255, blue: 91 / 255)
    static let quietOnAccent = Color(red: 244 / 255, green: 240 / 255, blue: 231 / 255)
    static let quietClay = Color(red: 183 / 255, green: 121 / 255, blue: 94 / 255)
    static let quietSaffron = Color(red: 211 / 255, green: 154 / 255, blue: 69 / 255)
    static let quietMist = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 33 / 255, green: 39 / 255, blue: 34 / 255, alpha: 1)
                : UIColor(red: 221 / 255, green: 226 / 255, blue: 215 / 255, alpha: 1)
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
