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
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color.quietMint.opacity(0.75))

                Circle()
                    .fill(Color.quietSunlight)
                    .frame(width: 84, height: 84)
                    .offset(x: proxy.size.width * 0.25, y: -proxy.size.height * 0.22)

                Circle()
                    .fill(Color.quietCoral.opacity(0.92))
                    .frame(width: 34, height: 34)
                    .offset(x: -proxy.size.width * 0.31, y: proxy.size.height * 0.22)

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
                        with: .color(.quietNeem),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                    )
                    context.stroke(
                        path,
                        with: .color(.quietSurface.opacity(0.85)),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 13])
                    )
                }
                .padding(18)
                .offset(y: isMoving ? -3 : 3)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.quietSurface)
                    .padding(14)
                    .background(Color.quietNeem)
                    .clipShape(Circle())
                    .offset(x: proxy.size.width * 0.13, y: proxy.size.height * 0.14)
                    .rotationEffect(.degrees(isMoving ? 7 : -7))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.quietSeaGlass.opacity(0.35), lineWidth: 1)
            }
        }
        .frame(height: 230)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isMoving = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("An illustrated attention path wanders through sunlight and returns to a leaf.")
    }
}
