import SwiftUI
import SwiftData

struct AnswerReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]

    private var answers: [QuestionAnswer] { sessions.first?.answers ?? [] }
    private var questions: [QuestionnaireQuestion] { QuestionnaireBank.questions(for: answers) }

    var body: some View {
        NavigationStack {
            List(questions) { question in
                NavigationLink {
                    EditAnswerView(question: question)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(question.prompt)
                            .font(.subheadline.weight(.medium))
                        Text(selectedTitle(for: question) ?? "Not answered")
                            .font(.caption)
                            .foregroundStyle(Color.quietNeem)
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.quietPaper)
            .navigationTitle("Your answers")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func selectedTitle(for question: QuestionnaireQuestion) -> String? {
        guard let optionID = answers.first(where: { $0.questionID == question.id })?.optionID else {
            return nil
        }
        return question.options.first { $0.id == optionID }?.title
    }
}

private struct EditAnswerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuestionnaireSession.updatedAt, order: .reverse) private var sessions: [QuestionnaireSession]
    let question: QuestionnaireQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.generous) {
            Text(question.prompt)
                .font(.quietTitle)
                .foregroundStyle(Color.quietInk)

            ForEach(question.options) { option in
                Button(option.title) {
                    revise(option)
                }
                .font(.body.weight(.medium))
                .foregroundStyle(Color.quietInk)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .padding(.horizontal, QuietSpacing.standard)
                .background(Color.quietMist)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            Spacer()
        }
        .padding(QuietSpacing.generous)
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Revise answer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func revise(_ option: QuestionnaireOption) {
        guard let session = sessions.first else { return }
        _ = QuestionnairePersistence.update(
            questionID: question.id,
            optionID: option.id,
            session: session,
            context: modelContext
        )
        QuestionnairePersistence.rebuildProfile(in: modelContext)
        dismiss()
    }
}
