import Foundation

enum HypothesisSupport: String, Codable, Hashable {
    case contested
    case questionnaire
    case externalObservation

    var title: String {
        switch self {
        case .contested: "Views differ"
        case .questionnaire: "Questionnaire"
        case .externalObservation: "Conversation observation"
        }
    }

    var sortOrder: Int {
        switch self {
        case .contested: 0
        case .questionnaire: 1
        case .externalObservation: 2
        }
    }
}

struct WorkingHypothesis: Hashable, Identifiable {
    let id: String
    let statement: String
    let support: HypothesisSupport
    let evidenceStrength: EvidenceStrength
    let basis: [String]
    let counterpoint: String?
    let prediction: String
    let disconfirmation: String
}

/// Creates falsifiable, qualitative claims without classifying imported prose
/// into questionnaire dimensions or converting external evidence into numbers.
struct HypothesisEngine {
    func hypotheses(for profile: AttentionProfile) -> [WorkingHypothesis] {
        var result: [WorkingHypothesis] = []

        if let external = profile.externalEvidence {
            result += external.differences.enumerated().map { index, difference in
                WorkingHypothesis(
                    id: "difference.\(index)",
                    statement: difference,
                    support: .contested,
                    evidenceStrength: .moderate,
                    basis: ["The imported review explicitly identified this difference."],
                    counterpoint: external.alternativeExplanations.first,
                    prediction: "A repeated practice should reveal which description better predicts what happens outside conversation.",
                    disconfirmation: "If practice outcomes vary mainly with context, neither broad description should be retained as a general pattern."
                )
            }
        }

        result.append(
            WorkingHypothesis(
                id: "questionnaire.current",
                statement: profile.interpretation.summary,
                support: .questionnaire,
                evidenceStrength: profile.evidenceStrength,
                basis: profile.interpretation.reasons,
                counterpoint: profile.dimensions.flatMap(\.contradictions).first,
                prediction: prediction(for: profile.interpretation.title),
                disconfirmation: disconfirmation(for: profile.interpretation.title)
            )
        )

        if let external = profile.externalEvidence {
            result += external.observations.map { observation in
                WorkingHypothesis(
                    id: "observation.\(observation.id)",
                    statement: observation.statement,
                    support: .externalObservation,
                    evidenceStrength: observation.strength,
                    basis: [observation.reason].compactMap { $0 },
                    counterpoint: observation.counterpoint,
                    prediction: "If this pattern extends beyond conversation, it should recur across several practice sessions or everyday tasks.",
                    disconfirmation: "Repeated outcomes that do not show this pattern would keep it conversation-specific rather than general."
                )
            }
        }

        return result.sorted {
            ($0.support.sortOrder, $0.id) < ($1.support.sortOrder, $1.id)
        }
    }

    private func prediction(for title: String) -> String {
        switch title {
        case "Exploratory or intermittently focused":
            "A simple practice may show frequent branching alongside an ability to return without losing the thread."
        case "Naturally sustained or one-pointed":
            "Once an anchor is established, attention may stay with it for a substantial stretch."
        case "Low-energy or dull at times":
            "In quiet practice, reduced alertness may appear before frequent distraction does."
        default:
            "Different settings may produce meaningfully different attention patterns."
        }
    }

    private func disconfirmation(for title: String) -> String {
        switch title {
        case "Exploratory or intermittently focused":
            "Several sessions with little branching would weaken this working hypothesis."
        case "Naturally sustained or one-pointed":
            "Several sessions with frequent loss of the anchor would weaken this working hypothesis."
        case "Low-energy or dull at times":
            "Consistently bright alertness in quiet sessions would weaken this working hypothesis."
        default:
            "A stable pattern repeated across contexts would weaken the context-dependent interpretation."
        }
    }
}
