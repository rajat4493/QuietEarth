import SwiftUI

/// Three fast inputs, under thirty seconds. Nothing here is scored.
struct ReflectionView: View {
    let recommendation: PracticeRecommendation
    let plannedSeconds: Int
    let completedSeconds: Int
    let onSave: (PracticeOutcome) -> Void

    @State private var noticeRate: NoticeRate?
    @State private var returnEase: ReturnEase?
    @State private var afterward: AfterwardState?
    @State private var note = ""

    private var canSave: Bool {
        noticeRate != nil && returnEase != nil && afterward != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.section) {
                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("How was that?")
                        .font(.quietDisplay)
                        .foregroundStyle(Color.quietInk)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("reflection.title")
                    Text("Three quick answers. There is no better or worse answer here — this is the evidence the app learns from.")
                        .font(.quietBody)
                        .foregroundStyle(Color.quietInk.opacity(0.7))
                }

                choice("How often did you notice wandering?", NoticeRate.allCases, $noticeRate, identifier: "notice")
                choice("How easy was returning?", ReturnEase.allCases, $returnEase, identifier: "return")
                choice("Afterward you feel…", AfterwardState.allCases, $afterward, identifier: "afterward")

                VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                    Text("Anything worth remembering? (optional)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.quietInk)
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("reflection.note")
                }

                Button("Save") {
                    guard let noticeRate, let returnEase, let afterward else { return }
                    onSave(
                        PracticeOutcome(
                            id: "outcome.\(Date.now.timeIntervalSince1970)",
                            templateID: recommendation.template.id,
                            anchor: recommendation.anchor,
                            plannedSeconds: plannedSeconds,
                            completedSeconds: completedSeconds,
                            noticeRate: noticeRate,
                            returnEase: returnEase,
                            afterward: afterward,
                            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
                            recordedAt: .now
                        )
                    )
                }
                .buttonStyle(.primaryAction)
                .disabled(!canSave)
                .accessibilityIdentifier("reflection.save")
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func choice<Option: ReflectionOption>(
        _ title: String,
        _ options: [Option],
        _ selection: Binding<Option?>,
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: QuietSpacing.compact) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.quietInk)
            HStack(spacing: QuietSpacing.compact) {
                ForEach(options) { option in
                    let isSelected = selection.wrappedValue == option
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        Text(option.title)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .foregroundStyle(isSelected ? Color.quietOnAccent : Color.quietInk)
                            .background(isSelected ? Color.quietNeem : Color.quietMint)
                            .clipShape(RoundedRectangle(cornerRadius: QuietTheme.cardRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("reflection.\(identifier).\(option.id)")
                    .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
                }
            }
        }
    }

}
