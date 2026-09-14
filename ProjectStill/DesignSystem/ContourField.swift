import SwiftUI

struct ContourField: View {
    var alignment: Alignment = .center

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(
                x: alignment == .topTrailing ? size.width * 0.76 : size.width * 0.5,
                y: alignment == .topTrailing ? size.height * 0.2 : size.height * 0.5
            )

            for index in 0..<7 {
                let inset = CGFloat(index) * 18
                let wobble = CGFloat(index % 3) * 5
                let rect = CGRect(
                    x: center.x - size.width * 0.55 + inset,
                    y: center.y - size.height * 0.34 + inset + wobble,
                    width: size.width * 1.1 - inset * 2,
                    height: size.height * 0.68 - inset * 2
                )
                let path = Path(ellipseIn: rect)
                context.stroke(path, with: .color(.quietNeem.opacity(0.13)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

