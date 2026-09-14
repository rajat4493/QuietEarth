import SwiftUI

struct ContourField: View {
    var alignment: Alignment = .center

    var body: some View {
        Canvas { context, size in
            let originX = alignment == .topTrailing ? size.width * 0.7 : size.width * 0.5
            let originY = alignment == .topTrailing ? size.height * 0.16 : size.height * 0.5
            for index in 0..<4 {
                let radius = CGFloat(72 + index * 34)
                let rect = CGRect(
                    x: originX - radius,
                    y: originY - radius * 0.72,
                    width: radius * 2,
                    height: radius * 1.44
                )
                context.stroke(
                    Path(ellipseIn: rect),
                    with: .color(.quietSeaGlass.opacity(0.08)),
                    lineWidth: 1
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct AttentionPathHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isMoving = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .stroke(Color.quietInk.opacity(0.1), lineWidth: 18)
                    .frame(width: 150, height: 150)

                Canvas { context, size in
                    var path = Path()
                    path.move(to: CGPoint(x: size.width * 0.05, y: size.height * 0.7))
                    path.addCurve(
                        to: CGPoint(x: size.width * 0.46, y: size.height * 0.48),
                        control1: CGPoint(x: size.width * 0.18, y: size.height * 0.18),
                        control2: CGPoint(x: size.width * 0.28, y: size.height * 0.9)
                    )
                    path.addCurve(
                        to: CGPoint(x: size.width * 0.92, y: size.height * 0.3),
                        control1: CGPoint(x: size.width * 0.62, y: size.height * 0.12),
                        control2: CGPoint(x: size.width * 0.72, y: size.height * 0.62)
                    )
                    context.stroke(
                        path,
                        with: .color(.quietCoral),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                    )
                }
                .padding(28)
                .offset(y: isMoving ? -2 : 2)

                Image(systemName: "smallcircle.filled.circle")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.quietOnAccent)
                    .padding(12)
                    .background(Color.quietNeem)
                    .clipShape(Circle())
                    .offset(x: proxy.size.width * 0.13, y: proxy.size.height * 0.14)
                    .rotationEffect(.degrees(isMoving ? 7 : -7))
            }
        }
        .frame(height: 180)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isMoving = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("A simple line follows a wandering attention path.")
    }
}
