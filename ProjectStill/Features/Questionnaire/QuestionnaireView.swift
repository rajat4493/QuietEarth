import SwiftUI
import SwiftData

struct QuestionnaireView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var answers: [QuestionAnswer] = []
    @State private var currentIndex = 0
    @State private var hasLoaded = false

    let onComplete: () -> Void

    private var questions: [QuestionnaireQuestion] {
        QuestionnaireBank.questions(for: answers)
    }

    private var currentQuestion: QuestionnaireQuestion {
        questions[min(currentIndex, questions.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QuietSpacing.generous) {
            VStack(alignment: .leading, spacing: QuietSpacing.compact) {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.quietNeem)
                    .accessibilityLabel("Question \(currentIndex + 1) of approximately \(questions.count)")

                ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                    .tint(.quietNeem)
            }

            Text(currentQuestion.prompt)
                .font(.quietDisplay)
                .foregroundStyle(Color.quietInk)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("questionnaire.prompt")

            Text(currentQuestion.context)
                .font(.quietBody)
                .foregroundStyle(Color.quietInk.opacity(0.68))

            VStack(spacing: QuietSpacing.standard) {
                ForEach(Array(currentQuestion.options.enumerated()), id: \.element.id) { index, option in
                    Button {
                        select(option)
                    } label: {
                        Text(option.title)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.quietInk)
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                            .padding(.horizontal, QuietSpacing.standard)
                            .quietCard()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("questionnaire.option.\(index)")
                }
            }

            Spacer(minLength: QuietSpacing.standard)

            if currentIndex > 0 {
                Button("Previous question") {
                    currentIndex -= 1
                    let session = QuestionnairePersistence.session(in: modelContext)
                    session.currentIndex = currentIndex
                    session.updatedAt = .now
                    try? modelContext.save()
                }
                .frame(minHeight: 44)
                .foregroundStyle(Color.quietInk)
            }
        }
        .padding(QuietSpacing.generous)
        .background(Color.quietPaper.ignoresSafeArea())
        .navigationTitle("Your attention")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSession)
    }

    private func loadSession() {
        guard !hasLoaded else { return }
        let session = QuestionnairePersistence.session(in: modelContext)
        answers = session.answers
        currentIndex = min(session.currentIndex, max(0, QuestionnaireBank.questions(for: answers).count - 1))
        hasLoaded = true
    }

    private func select(_ option: QuestionnaireOption) {
        let session = QuestionnairePersistence.session(in: modelContext)
        answers = QuestionnairePersistence.update(
            questionID: currentQuestion.id,
            optionID: option.id,
            session: session,
            context: modelContext
        )
        let updatedQuestions = QuestionnaireBank.questions(for: answers)

        if currentIndex + 1 < updatedQuestions.count {
            currentIndex += 1
            session.currentIndex = currentIndex
            session.updatedAt = .now
            try? modelContext.save()
        } else {
            session.isComplete = true
            session.currentIndex = max(0, updatedQuestions.count - 1)
            QuestionnairePersistence.rebuildProfile(in: modelContext)
            try? modelContext.save()
            onComplete()
        }
    }
}

#Preview {
    NavigationStack {
        QuestionnaireView(onComplete: {})
    }
    .modelContainer(for: [QuestionnaireSession.self, StoredAttentionProfile.self, StoredExternalAIProfile.self], inMemory: true)
}
