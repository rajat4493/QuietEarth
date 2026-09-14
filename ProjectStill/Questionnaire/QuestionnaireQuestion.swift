import Foundation

struct SignalTemplate: Hashable {
    let dimension: AttentionDimension
    let direction: Double
    let weight: Double
    let summary: String
}

struct QuestionnaireOption: Identifiable, Hashable {
    let id: String
    let title: String
    let signals: [SignalTemplate]
}

struct QuestionnaireQuestion: Identifiable, Hashable {
    let id: String
    let prompt: String
    let context: String
    let options: [QuestionnaireOption]
}

enum QuestionnaireBank {
    static let core: [QuestionnaireQuestion] = [
        question(
            "switching",
            "When you work without interruptions, how often does your attention move to something else?",
            "Think about ordinary tasks, not your best or worst day.",
            .attentionalSwitching,
            [
                ("rarely", "Rarely", -0.9, "Attention usually stays with the chosen task."),
                ("sometimes", "Sometimes", -0.25, "Attention sometimes changes targets."),
                ("often", "Often", 0.45, "Attention often changes targets without an external interruption."),
                ("very_often", "Very often", 0.9, "Attention very often changes targets without an external interruption.")
            ]
        ),
        question(
            "persistence",
            "Once something has your interest, how long can you usually stay with it?",
            "Include work, reading, making, or learning.",
            .focusPersistence,
            [
                ("brief", "Only briefly", -0.9, "Engagement tends to fade quickly."),
                ("short", "For a short stretch", -0.3, "Engagement is usually sustained for a short stretch."),
                ("long", "For a long stretch", 0.55, "Engagement is often sustained for a long stretch."),
                ("very_long", "For a very long stretch", 0.95, "Engagement can remain sustained for a very long stretch.")
            ]
        ),
        question(
            "branching",
            "When one idea appears, what usually happens next?",
            "Choose the closest description of your thinking.",
            .associativeBranching,
            [
                ("single", "I stay with that idea", -0.85, "One idea tends to remain the main line of thought."),
                ("few", "A few related ideas appear", -0.15, "A small number of related ideas tend to appear."),
                ("several", "Several paths open", 0.55, "One idea often opens several related paths."),
                ("many", "Many paths open quickly", 0.95, "Ideas rapidly branch into many related paths.")
            ]
        ),
        question(
            "disengagement",
            "When it is time to leave an absorbing topic, how easy is the shift?",
            "This is about changing direction, not whether the topic was useful.",
            .disengagementDifficulty,
            [
                ("easy", "Easy", -0.9, "Leaving an absorbing topic is usually easy."),
                ("mostly_easy", "Mostly easy", -0.3, "Leaving an absorbing topic is usually manageable."),
                ("effort", "It takes effort", 0.5, "Leaving an absorbing topic often takes deliberate effort."),
                ("hard", "Very difficult", 0.9, "Attention tends to remain attached when it is time to shift.")
            ]
        ),
        question(
            "novelty",
            "How does repetition affect your attention?",
            "Think of a familiar task with little variation.",
            .noveltyDependence,
            [
                ("steady", "I remain steady", -0.85, "Repetition does not strongly reduce engagement."),
                ("mostly_steady", "I mostly remain steady", -0.25, "Repetition causes only a small drop in engagement."),
                ("fade", "My attention fades", 0.55, "Engagement often fades when novelty is low."),
                ("seek_change", "I quickly seek a change", 0.95, "Low novelty quickly leads attention to seek a different target.")
            ]
        ),
        question(
            "emotion",
            "After an emotionally charged moment, how long does it occupy your attention?",
            "Answer for a typical meaningful event.",
            .emotionalCapture,
            [
                ("passes", "It passes quickly", -0.85, "Emotional material usually releases attention quickly."),
                ("brief", "A short while", -0.25, "Emotional material holds attention for a short while."),
                ("returns", "It keeps returning", 0.55, "Attention repeatedly returns to emotionally charged material."),
                ("dominates", "It dominates for a long time", 0.95, "Emotionally charged material can dominate attention for a long time.")
            ]
        ),
        question(
            "dullness",
            "During a quiet part of the day, what most often happens to your alertness?",
            "Higher scores here mean a stronger low-energy or dullness tendency.",
            .energyDullness,
            [
                ("bright", "It stays bright", -0.9, "Alertness tends to remain bright during quiet periods."),
                ("stable", "It stays mostly stable", -0.35, "Alertness is mostly stable during quiet periods."),
                ("softens", "It softens or drifts", 0.5, "Alertness often softens during quiet periods."),
                ("sleepy", "I become sleepy or foggy", 0.95, "Quiet periods often bring sleepiness or mental fog.")
            ]
        ),
        question(
            "low_stimulation",
            "How comfortable is it to do one simple thing with little stimulation?",
            "For example, walking without audio or waiting without checking a screen.",
            .lowStimulationTolerance,
            [
                ("uncomfortable", "Very uncomfortable", -0.9, "Low-stimulation activity is difficult to remain with."),
                ("restless", "Somewhat uncomfortable", -0.35, "Low-stimulation activity often brings restlessness."),
                ("okay", "Mostly comfortable", 0.45, "Low-stimulation activity is usually manageable."),
                ("comfortable", "Very comfortable", 0.9, "Low-stimulation activity is easy to remain with.")
            ]
        ),
        question(
            "noticing",
            "How soon do you notice that your attention has wandered?",
            "Wandering is expected; this asks only about noticing.",
            .metacognitiveNoticing,
            [
                ("late", "Usually much later", -0.9, "Attention shifts are often noticed much later."),
                ("after", "After a while", -0.3, "Attention shifts are usually noticed after some time."),
                ("soon", "Fairly soon", 0.5, "Attention shifts are often noticed fairly soon."),
                ("immediate", "Almost immediately", 0.9, "Attention shifts are usually noticed almost immediately.")
            ]
        ),
        question(
            "sensory",
            "What most easily brings you back to the present task?",
            "Choose what tends to be available first.",
            .sensoryOrientation,
            [
                ("words", "A phrase or mental reminder", -0.85, "Verbal or conceptual reminders are the more available cue."),
                ("plan", "Remembering the plan", -0.4, "A conceptual plan is usually the more available cue."),
                ("body", "A bodily sensation", 0.55, "Bodily sensation is an available cue for returning."),
                ("senses", "Sound, sight, or touch", 0.9, "Immediate sensory information is the most available cue for returning.")
            ]
        ),
        multiQuestion(
            id: "deadline",
            prompt: "When a deadline is close, how does your attention usually change?",
            context: "This helps us check whether focus changes with context.",
            options: [
                option("fragments", "It fragments more", [
                    signal(.attentionalSwitching, 0.75, "Under deadline pressure, attention fragments more."),
                    signal(.focusPersistence, -0.55, "Deadline pressure reduces sustained engagement.")
                ]),
                option("same", "It stays similar", [
                    signal(.attentionalSwitching, 0, "Deadline pressure does not greatly change switching."),
                    signal(.focusPersistence, 0, "Deadline pressure does not greatly change persistence.")
                ]),
                option("steadies", "It becomes steadier", [
                    signal(.attentionalSwitching, -0.55, "A close deadline tends to steady attention."),
                    signal(.focusPersistence, 0.55, "A close deadline tends to increase persistence.")
                ]),
                option("locks", "It locks onto the task", [
                    signal(.attentionalSwitching, -0.9, "A close deadline strongly reduces switching."),
                    signal(.focusPersistence, 0.9, "A close deadline strongly increases persistence.")
                ])
            ]
        ),
        multiQuestion(
            id: "quiet_sit",
            prompt: "If you sit quietly for five minutes without a task, what is most likely?",
            context: "There is no preferred answer.",
            options: [
                option("restless", "I look for something to do", [
                    signal(.lowStimulationTolerance, -0.8, "Unstructured quiet tends to produce restlessness."),
                    signal(.noveltyDependence, 0.65, "Unstructured quiet tends to prompt a search for stimulation.")
                ]),
                option("thoughts", "Thoughts multiply", [
                    signal(.associativeBranching, 0.75, "In quiet, thoughts tend to multiply."),
                    signal(.lowStimulationTolerance, -0.25, "Unstructured quiet is somewhat difficult to remain with.")
                ]),
                option("sleepy", "I become dull or sleepy", [
                    signal(.energyDullness, 0.9, "Unstructured quiet tends to bring dullness or sleepiness."),
                    signal(.lowStimulationTolerance, -0.2, "Quiet is possible, though alertness may decline.")
                ]),
                option("settled", "I remain alert and settled", [
                    signal(.energyDullness, -0.75, "Alertness tends to remain present in unstructured quiet."),
                    signal(.lowStimulationTolerance, 0.85, "Unstructured quiet is comfortable to remain with.")
                ])
            ]
        )
    ]

    static let switchingFollowUp = multiQuestion(
        id: "switching_followup",
        prompt: "When your attention changes targets, how often do you notice the change as it happens?",
        context: "This distinguishes frequent switching from unnoticed switching.",
        options: [
            option("late", "Usually later", [
                signal(.metacognitiveNoticing, -0.75, "Frequent shifts are usually noticed later."),
                signal(.attentionalSwitching, 0.55, "Attention changes targets before the shift is noticed.")
            ]),
            option("sometimes", "Sometimes as it happens", [
                signal(.metacognitiveNoticing, 0, "Some attention shifts are noticed as they happen."),
                signal(.attentionalSwitching, 0.45, "Attention still changes targets frequently.")
            ]),
            option("often", "Often as it happens", [
                signal(.metacognitiveNoticing, 0.7, "Frequent shifts are often noticed as they happen."),
                signal(.attentionalSwitching, 0.4, "Attention changes targets frequently, with awareness.")
            ])
        ]
    )

    static let dullnessFollowUp = multiQuestion(
        id: "dullness_followup",
        prompt: "When low energy appears, does movement or sensory contact change it?",
        context: "Think of standing, walking, cool air, or opening your eyes.",
        options: [
            option("little", "Very little", [
                signal(.energyDullness, 0.75, "Low energy changes little with movement or sensory contact."),
                signal(.sensoryOrientation, -0.2, "Sensory activation has limited immediate effect.")
            ]),
            option("some", "Somewhat", [
                signal(.energyDullness, 0.35, "Movement or sensory contact partly changes low energy."),
                signal(.sensoryOrientation, 0.25, "Sensory activation is somewhat available.")
            ]),
            option("much", "A great deal", [
                signal(.energyDullness, -0.2, "Movement or sensory contact often restores alertness."),
                signal(.sensoryOrientation, 0.75, "Sensory activation is a strong route back to alertness.")
            ])
        ]
    )

    static let sustainedFollowUp = multiQuestion(
        id: "sustained_followup",
        prompt: "During long focus, can you stop when you intend to?",
        context: "Sustained attention and easy disengagement are different qualities.",
        options: [
            option("easy", "Usually easily", [
                signal(.focusPersistence, 0.65, "Long focus is sustained while intentional stopping remains easy."),
                signal(.disengagementDifficulty, -0.75, "Intentional disengagement from long focus is usually easy.")
            ]),
            option("effort", "With some effort", [
                signal(.focusPersistence, 0.7, "Long focus remains sustained."),
                signal(.disengagementDifficulty, 0.35, "Intentional stopping takes some effort.")
            ]),
            option("hard", "It is very difficult", [
                signal(.focusPersistence, 0.85, "Long focus remains strongly sustained."),
                signal(.disengagementDifficulty, 0.85, "Intentional stopping from long focus is very difficult.")
            ])
        ]
    )

    static func questions(for answers: [QuestionAnswer]) -> [QuestionnaireQuestion] {
        var result = core
        let selected = Dictionary(uniqueKeysWithValues: answers.map { ($0.questionID, $0.optionID) })

        if ["often", "very_often"].contains(selected["switching"]) {
            result.append(switchingFollowUp)
        }
        if ["softens", "sleepy"].contains(selected["dullness"]) {
            result.append(dullnessFollowUp)
        }
        if ["long", "very_long"].contains(selected["persistence"]) {
            result.append(sustainedFollowUp)
        }
        return result
    }

    static func question(id: String) -> QuestionnaireQuestion? {
        (core + [switchingFollowUp, dullnessFollowUp, sustainedFollowUp]).first { $0.id == id }
    }

    static func signals(for answers: [QuestionAnswer]) -> [ObservedSignal] {
        answers.flatMap { answer -> [ObservedSignal] in
            guard let question = question(id: answer.questionID),
                  let option = question.options.first(where: { $0.id == answer.optionID }) else {
                return []
            }
            return option.signals.map { template in
                ObservedSignal(
                    id: "\(answer.questionID).\(answer.optionID).\(template.dimension.rawValue)",
                    source: .questionnaire,
                    questionID: answer.questionID,
                    dimension: template.dimension,
                    direction: template.direction,
                    weight: template.weight,
                    summary: template.summary
                )
            }
        }
    }

    private static func question(
        _ id: String,
        _ prompt: String,
        _ context: String,
        _ dimension: AttentionDimension,
        _ values: [(String, String, Double, String)]
    ) -> QuestionnaireQuestion {
        multiQuestion(
            id: id,
            prompt: prompt,
            context: context,
            options: values.map { value in
                option(value.0, value.1, [signal(dimension, value.2, value.3)])
            }
        )
    }

    private static func multiQuestion(
        id: String,
        prompt: String,
        context: String,
        options: [QuestionnaireOption]
    ) -> QuestionnaireQuestion {
        QuestionnaireQuestion(id: id, prompt: prompt, context: context, options: options)
    }

    private static func option(
        _ id: String,
        _ title: String,
        _ signals: [SignalTemplate]
    ) -> QuestionnaireOption {
        QuestionnaireOption(id: id, title: title, signals: signals)
    }

    private static func signal(
        _ dimension: AttentionDimension,
        _ direction: Double,
        _ summary: String,
        weight: Double = 1
    ) -> SignalTemplate {
        SignalTemplate(dimension: dimension, direction: direction, weight: weight, summary: summary)
    }
}

