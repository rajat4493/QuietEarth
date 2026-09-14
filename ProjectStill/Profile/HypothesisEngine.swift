import Foundation

/// Turns questionnaire evidence plus user-filed observations into working
/// hypotheses. Deterministic, and it never produces or consumes an AI-derived
/// number.
struct HypothesisEngine {
    enum Lean {
        case clearlyPresent
        case clearlyAbsent
        case noClearLean
    }

    func hypotheses(
        dimensions: [DimensionAssessment],
        observations: [ExternalObservation]
    ) -> [WorkingHypothesis] {
        let filed = observations.filter { $0.theme != nil }
        let themes = Set(filed.compactMap(\.theme))
            .union(AttentionTheme.allCases.filter { lean(for: $0, in: dimensions) == .clearlyPresent })

        return themes
            .compactMap { theme -> WorkingHypothesis? in
                let themeObservations = filed.filter { $0.theme == theme }
                let best = themeObservations.map(\.strength).max() ?? .insufficient
                let questionnaireLean = lean(for: theme, in: dimensions)
                let state = supportState(lean: questionnaireLean, observed: best, hasObservation: !themeObservations.isEmpty)
                guard state != .notYetSupported || !themeObservations.isEmpty else { return nil }

                let assessment = dimensions.first { $0.dimension == theme.relatedDimension }
                return WorkingHypothesis(
                    id: "hypothesis.\(theme.rawValue)",
                    theme: theme,
                    statement: Self.statement(for: theme),
                    supportState: state,
                    strength: combinedStrength(state: state, observed: best, assessment: assessment),
                    selfReportBasis: assessment?.evidence.filter { $0.source == .questionnaire }.map(\.summary) ?? [],
                    observedBasis: themeObservations.map(\.pattern),
                    tension: state == .contested ? Self.tension(for: theme) : nil,
                    prediction: Self.prediction(for: theme),
                    disconfirmation: Self.disconfirmation(for: theme)
                )
            }
            .sorted {
                ($0.supportState.testOrder, $0.theme.rawValue) < ($1.supportState.testOrder, $1.theme.rawValue)
            }
    }

    func lean(for theme: AttentionTheme, in dimensions: [DimensionAssessment]) -> Lean {
        guard let assessment = dimensions.first(where: { $0.dimension == theme.relatedDimension }),
              assessment.confidence >= 0.45 else {
            return .noClearLean
        }
        if assessment.score >= 0.62 { return .clearlyPresent }
        if assessment.score <= 0.38 { return .clearlyAbsent }
        return .noClearLean
    }

    private func supportState(lean: Lean, observed: EvidenceStrength, hasObservation: Bool) -> SupportState {
        guard hasObservation, observed.supportsHypothesis else {
            if hasObservation { return .notYetSupported }
            return lean == .clearlyPresent ? .singleSourceSelfReport : .notYetSupported
        }
        switch lean {
        case .clearlyPresent: return .converging
        case .clearlyAbsent: return .contested
        case .noClearLean: return .singleSourceObserved
        }
    }

    private func combinedStrength(
        state: SupportState,
        observed: EvidenceStrength,
        assessment: DimensionAssessment?
    ) -> EvidenceStrength {
        let selfReport = assessment.map { EvidenceStrength.fromInternalConfidence($0.confidence) } ?? .insufficient
        switch state {
        case .converging:
            return max(observed, selfReport)
        case .contested:
            // Disagreement is information, but it is not certainty.
            return min(observed, .moderate)
        case .singleSourceObserved:
            return observed
        case .singleSourceSelfReport:
            return min(selfReport, .moderate)
        case .notYetSupported:
            return observed == .insufficient ? .insufficient : .weak
        }
    }

    static func statement(for theme: AttentionTheme) -> String {
        switch theme {
        case .branching:
            "Your attention may branch before it settles, rather than being simply unstable."
        case .returning:
            "You may notice a drift and return to it, rather than losing the thread entirely."
        case .topicDepth:
            "Sustained attention may be available once engagement is established, while choosing the target varies."
        case .reframing:
            "Your attention may hold better when material is re-shaped rather than repeated."
        case .revisiting:
            "Leaving a settled question may be harder than arriving at one."
        case .linking:
            "Your attention may move by association rather than by sequence."
        case .taskDependence:
            "Your attention may depend more on the kind of task than on a general capacity."
        case .selfQuestioning:
            "You may notice your own attention shifting sooner than most instructions assume."
        }
    }

    static func tension(for theme: AttentionTheme) -> String {
        switch theme {
        case .topicDepth:
            "You reported weaker persistence, while the observations describe long sustained engagement. Both are kept; the practice decides."
        default:
            "Your questionnaire answers and the observations point in different directions here. Both are kept; the practice decides."
        }
    }

    static func prediction(for theme: AttentionTheme) -> String {
        switch theme {
        case .branching:
            "Expect many notices early, with returning getting easier faster than the notice count falls."
        case .returning:
            "Expect noticing to be reported as frequent, and returning as more easy than hard."
        case .topicDepth:
            "Expect longer sessions to be completed, with the notice count falling across the week."
        case .reframing:
            "Expect a changing anchor to be reported as easier to stay with than a repeated one."
        case .revisiting:
            "Expect returning to be reported as hard even when noticing is frequent."
        case .linking:
            "Expect many notices with easy returns, rather than a sense of blankness."
        case .taskDependence:
            "Expect session reports to vary by practice type more than they vary day to day."
        case .selfQuestioning:
            "Expect noticing to be reported as frequent from the first session rather than developing."
        }
    }

    static func disconfirmation(for theme: AttentionTheme) -> String {
        switch theme {
        case .branching:
            "Four or more sessions with few notices and hard returns would point to dullness, not branching."
        case .returning:
            "Four or more sessions where returning is consistently hard would disconfirm this."
        case .topicDepth:
            "Four or more sessions ended early, or many notices throughout, would disconfirm this."
        case .reframing:
            "No difference between a changing and a repeated anchor would disconfirm this."
        case .revisiting:
            "Returning reported as easy across four or more sessions would disconfirm this."
        case .linking:
            "Few notices with a reported sense of blankness would point to dullness instead."
        case .taskDependence:
            "Session reports that vary no more by type than by day would disconfirm this."
        case .selfQuestioning:
            "Noticing reported as rare in early sessions would disconfirm this."
        }
    }
}
