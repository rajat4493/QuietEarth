import Combine
import SwiftUI
import UIKit

/// Ultra-minimal session. No feed, no streak, no badges, no controls beyond
/// pause and end. Works entirely offline: timed text and haptics only.
struct PracticeSessionView: View {
    let recommendation: PracticeRecommendation
    let onFinish: (_ completedSeconds: Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var elapsed: Int = 0
    @State private var isRunning = true
    @State private var showsEndConfirmation = false

    private var steps: [PracticeStep] {
        recommendation.template.steps(minutes: recommendation.minutes, anchor: recommendation.anchor)
    }

    private var totalSeconds: Int {
        max(1, steps.reduce(0) { $0 + $1.seconds })
    }

    private var currentStepIndex: Int {
        var boundary = 0
        for (index, step) in steps.enumerated() {
            boundary += step.seconds
            if elapsed < boundary { return index }
        }
        return max(0, steps.count - 1)
    }

    private var currentStep: PracticeStep { steps[currentStepIndex] }

    private var remaining: Int { max(0, totalSeconds - elapsed) }

    var body: some View {
        VStack(spacing: QuietSpacing.section) {
            Spacer(minLength: 0)

            VStack(spacing: QuietSpacing.standard) {
                Text(currentStep.title)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .tracking(1.6)
                    .foregroundStyle(Color.quietInk.opacity(0.6))
                    .accessibilityIdentifier("session.stepTitle")

                Text(currentStep.instruction)
                    .font(.quietTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.quietInk)
                    .padding(.horizontal, QuietSpacing.generous)
                    .id(currentStep.id)
                    .transition(.opacity)
            }

            ring

            Spacer(minLength: 0)

            VStack(spacing: QuietSpacing.standard) {
                Button(isRunning ? "Pause" : "Resume") {
                    isRunning.toggle()
                }
                .buttonStyle(.primaryAction)
                .accessibilityIdentifier("session.pause")

                Button("End session") {
                    showsEndConfirmation = true
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(Color.quietInk.opacity(0.7))
                .accessibilityIdentifier("session.end")
            }
            .padding(.horizontal, QuietSpacing.generous)
        }
        .padding(.vertical, QuietSpacing.generous)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .confirmationDialog(
            "End this session?",
            isPresented: $showsEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End and reflect", role: .destructive) { onFinish(elapsed) }
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("Ending early is fine, and it is recorded as it happened.")
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.quietInk.opacity(0.12), lineWidth: 6)
            Circle()
                .trim(from: 0, to: min(1, Double(elapsed) / Double(totalSeconds)))
                .stroke(Color.quietInk.opacity(0.55), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .linear(duration: 1), value: elapsed)
            Text(timeString(remaining))
                .font(.system(.largeTitle, design: .default, weight: .light))
                .monospacedDigit()
                .foregroundStyle(Color.quietInk)
                .accessibilityIdentifier("session.remaining")
        }
        .frame(width: 200, height: 200)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(timeString(remaining)) remaining")
    }

    private func tick() {
        guard isRunning else { return }
        let previousStep = currentStepIndex
        elapsed = min(totalSeconds, elapsed + 1)

        if currentStepIndex != previousStep {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        if elapsed >= totalSeconds {
            isRunning = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onFinish(elapsed)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
