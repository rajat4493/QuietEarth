import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Color.quietOnAccent)
            .background(isEnabled ? Color.quietInk : Color.quietInk.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: QuietRadius.control, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(QuietMotion.select, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryActionButtonStyle {
    static var primaryAction: PrimaryActionButtonStyle { PrimaryActionButtonStyle() }
}

/// Secondary action: sea-glass tint, deep spruce label. Never white on accent.
struct QuietSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(Color.quietInk)
            .background(Color.quietMintWash)
            .clipShape(RoundedRectangle(cornerRadius: QuietRadius.control, style: .continuous))
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(QuietMotion.select, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == QuietSecondaryButtonStyle {
    static var quietSecondary: QuietSecondaryButtonStyle { QuietSecondaryButtonStyle() }
}
