import SwiftUI

/// The attention path: flowing sunlit ribbons rather than thin contour lines.
///
/// The motif carries the method. `.single` is one drifting ribbon for
/// onboarding; `.divergent` draws two — self-report and observation — that
/// touch where they agree and separate where they differ.
struct ContourField: View {
    enum Mode {
        case single
        case divergent
    }

    var alignment: Alignment = .center
    var mode: Mode = .single

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let drift = reduceMotion
                    ? 0
                    : CGFloat(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 12) / 12)
                draw(in: &context, size: size, drift: drift)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, drift: CGFloat) {
        let anchorY = alignment == .topTrailing ? size.height * 0.26 : size.height * 0.5
        let washes: [Color] = [.quietNeem, .quietSaffron, .quietClay]

        for index in 0..<3 {
            let offset = CGFloat(index) * 26
            let sway = sin((drift + CGFloat(index) * 0.22) * .pi * 2) * 14
            let separation: CGFloat = mode == .divergent ? CGFloat(index) * 30 : 0

            var path = Path()
            path.move(to: CGPoint(x: -size.width * 0.1, y: anchorY + offset + sway))
            path.addCurve(
                to: CGPoint(x: size.width * 0.44, y: anchorY - offset * 0.6 + sway),
                control1: CGPoint(x: size.width * 0.08, y: anchorY - 40 + offset + sway),
                control2: CGPoint(x: size.width * 0.26, y: anchorY + 48 - offset + sway)
            )
            path.addCurve(
                to: CGPoint(x: size.width * 1.1, y: anchorY + offset * 0.4 - sway + separation),
                control1: CGPoint(x: size.width * 0.66, y: anchorY - 54 - offset - separation + sway),
                control2: CGPoint(x: size.width * 0.86, y: anchorY + 30 + offset + separation)
            )

            context.stroke(
                path,
                with: .color(washes[index % washes.count].opacity(0.34 - Double(index) * 0.07)),
                style: StrokeStyle(lineWidth: 10 - CGFloat(index) * 2, lineCap: .round)
            )
        }
    }
}
