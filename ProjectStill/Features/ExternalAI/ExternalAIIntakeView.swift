import SwiftUI
import SwiftData
import UIKit

struct ExternalAIIntakeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var provider: AIProvider = .chatGPT
    @State private var pastedText = ""
    @State private var userNote = ""
    @State private var previewSelection: ExternalAIPreviewSelection?
    @State private var validationMessage: String?
    @State private var copied = false
    @FocusState private var isEditorFocused: Bool

    let onComplete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuietSpacing.generous) {
                Text("Use your AI for another view")
                    .font(.quietDisplay)
                    .foregroundStyle(Color.quietInk)
                    .accessibilityAddTraits(.isHeader)

                Text("Your conversations stay with your AI provider. Copy our prompt there, then bring back only its qualitative observations — no cognitive scores or probabilities.")
                    .font(.quietBody)
                    .foregroundStyle(Color.quietInk.opacity(0.72))

                Picker("AI provider", selection: $provider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.title).tag(provider)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                    Text("1. Copy the analysis prompt")
                        .font(.quietTitle)
                    ScrollView {
                        Text(ExternalAIPrompt.text)
                            .font(.caption.monospaced())
                            .foregroundStyle(Color.quietInk.opacity(0.68))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 180)
                    .padding(QuietSpacing.standard)
                    .quietCard()

                    Button(copied ? "Prompt copied" : "Copy prompt") {
                        UIPasteboard.general.string = ExternalAIPrompt.text
                        copied = true
                    }
                    .buttonStyle(.primaryAction)
                    .accessibilityIdentifier("externalAI.copyPrompt")
                }

                VStack(alignment: .leading, spacing: QuietSpacing.standard) {
                    Text("2. Paste the approved JSON")
                        .font(.quietTitle)

                    TextEditor(text: $pastedText)
                        .font(.caption.monospaced())
                        .frame(minHeight: 220)
                        .padding(QuietSpacing.compact)
                        .scrollContentBackground(.hidden)
                        .quietCard()
                        .overlay(alignment: .topLeading) {
                            if pastedText.isEmpty {
                                Text("Paste JSON only")
                                    .font(.body)
                                    .foregroundStyle(Color.quietInk.opacity(0.42))
                                    .padding(QuietSpacing.standard)
                                    .allowsHitTesting(false)
                            }
                        }
                        .focused($isEditorFocused)
                        .accessibilityIdentifier("externalAI.jsonEditor")

                    Button("Paste from clipboard") {
                        pastedText = UIPasteboard.general.string ?? ""
                        validationMessage = nil
                    }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("externalAI.paste")

                    TextField("Optional note you approve", text: $userNote)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("externalAI.note")
                }

                Button("Review profile") {
                    validate()
                }
                .buttonStyle(.primaryAction)
                .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("externalAI.review")

                Text("Nothing is sent from this app. Evidence-strength labels remain qualitative and the pasted buffer is stored only after you approve the normalized preview.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.58))
            }
            .padding(QuietSpacing.generous)
        }
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Use your AI")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            if let validationMessage {
                Label(validationMessage, systemImage: "exclamationmark.triangle")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.quietInk)
                    .padding(QuietSpacing.standard)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.quietCoral)
                    .accessibilityIdentifier("externalAI.validationError")
            }
        }
        .sheet(item: $previewSelection) { selection in
            ExternalAIProfilePreviewView(
                payload: selection.payload,
                provider: provider,
                onApprove: { approve(selection.payload) }
            )
        }
    }

    private func validate() {
        isEditorFocused = false
        do {
            let parsedProfile = try ExternalAIProfileParser().parse(pastedText)
            previewSelection = ExternalAIPreviewSelection(payload: parsedProfile)
            validationMessage = nil
        } catch {
            previewSelection = nil
            validationMessage = (error as? LocalizedError)?.errorDescription ?? "This profile could not be validated."
        }
    }

    private func approve(_ parsedProfile: ExternalAIProfilePayload) {
        QuestionnairePersistence.saveExternalProfile(
            provider: provider,
            payload: parsedProfile,
            userNote: userNote.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            in: modelContext
        )
        previewSelection = nil
        onComplete()
    }
}

private struct ExternalAIPreviewSelection: Identifiable {
    let id = UUID()
    let payload: ExternalAIProfilePayload
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
