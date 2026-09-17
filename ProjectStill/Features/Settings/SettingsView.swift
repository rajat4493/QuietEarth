import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let onReset: () -> Void

    @State private var showsResetConfirmation = false

    var body: some View {
        Form {
            Section {
                NavigationLink("Appearance") {
                    AppearanceSettingsView()
                }
            }

            Section {
                Text("Everything you have entered stays on this device. QuietEarth has no account, no backend, and makes no network requests.")
                    .font(.footnote)
                    .foregroundStyle(Color.quietInk.opacity(0.75))
            } header: {
                Text("Your data")
            }

            Section {
                Button("Delete everything", role: .destructive) {
                    showsResetConfirmation = true
                }
                .accessibilityIdentifier("settings.reset")
            } footer: {
                Text("Removes your questionnaire answers, profile, any imported AI observations, your practice history, your note, and your appearance choices. This cannot be undone.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete everything?",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive) {
                PracticePersistence.resetAllLocalData(in: modelContext)
                onReset()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes all local data, including your practice history. It cannot be undone.")
        }
    }
}
