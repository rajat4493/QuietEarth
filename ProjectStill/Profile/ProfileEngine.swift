import Foundation

/// Deterministic questionnaire scoring. External AI text never reaches this
/// engine: it produces observations and hypotheses, not scores.
struct ProfileEngine {
    func makeProfile(
        from answers: [QuestionAnswer],
        additionalSignals: [ObservedSignal] = [],
        observations: [ExternalObservation] = [],
        payload: ExternalAIPayload? = nil,
        now: Date = .now
    ) -> AttentionProfile {
        let signals = QuestionnaireBank.signals(for: answers) + additionalSignals
        let dimensions = AttentionDimension.allCases.map { dimension in
            assess(dimension, signals: signals.filter { $0.dimension == dimension })
        }
        let overallConfidence = dimensions.map(\.confidence).reduce(0, +) / Double(dimensions.count)
        let hypotheses = HypothesisEngine().hypotheses(dimensions: dimensions, observations: observations)
        let comparisons = makeComparisons(dimensions: dimensions, observations: observations)
        let interpretation = interpret(
            dimensions: dimensions,
            hypotheses: hypotheses,
            overallConfidence: overallConfidence
        )

        var alternatives = payload?.alternativeExplanations ?? []
        if interpretation.title == Self.capacityGatingTitle,
           !alternatives.contains(where: { $0.localizedCaseInsensitiveContains("generalized weak concentration") }) {
            alternatives.insert(
                "Generalized weak concentration — This remains possible, but it does not explain the observed periods of strong engagement.",
                at: 0
            )
        }

        return AttentionProfile(
            dimensions: dimensions,
            interpretation: interpretation,
            overallConfidence: overallConfidence,
            updatedAt: now,
            observations: observations,
            hypotheses: hypotheses,
            sourceComparisons: comparisons.isEmpty ? nil : comparisons,
            alternativeInterpretations: alternatives.isEmpty ? nil : alternatives,
            externalSelfReportStatements: payload?.selfReport.map(\.statement) ?? [],
            externalDifferences: payload?.differences ?? [],
            externalLimitations: payload?.limitations ?? []
        )
    }

    static let capacityGatingTitle = "Capacity present, gating appears variable"

    private func assess(
        _ dimension: AttentionDimension,
        signals: [ObservedSignal]
    ) -> DimensionAssessment {
        guard !signals.isEmpty else {
            return DimensionAssessment(
                dimension: dimension,
                score: 0.5,
                confidence: 0,
                evidence: [],
                contradictions: []
            )
        }

        let totalWeight = signals.reduce(0) { $0 + $1.weight * $1.confidence }
        guard totalWeight > 0 else {
            return DimensionAssessment(
                dimension: dimension,
                score: 0.5,
                confidence: 0,
                evidence: signals,
                contradictions: []
            )
        }
        let meanDirection = signals.reduce(0) {
            $0 + $1.direction * $1.weight * $1.confidence
        } / totalWeight
        let score = clamp((meanDirection + 1) / 2)
        let variance = signals.reduce(0) {
            $0 + pow($1.direction - meanDirection, 2) * $1.weight * $1.confidence
        } / totalWeight
        let agreement = clamp(1 - sqrt(variance) * 0.85)
        let coverage = min(1, totalWeight / 2)
        let hasPositive = signals.contains { $0.direction > 0.35 }
        let hasNegative = signals.contains { $0.direction < -0.35 }
        let contradiction = hasPositive && hasNegative
        let contradictionPenalty = contradiction ? 0.65 : 1
        let confidence = clamp((0.2 + 0.8 * coverage * agreement) * contradictionPenalty)
        let contradictions = contradiction
            ? ["Evidence points in different directions here. Context may change this pattern, so confidence is lower."]
            : []

        return DimensionAssessment(
            dimension: dimension,
            score: score,
            confidence: confidence,
            evidence: signals,
            contradictions: contradictions
        )
    }

    private func interpret(
        dimensions: [DimensionAssessment],
        hypotheses: [WorkingHypothesis],
        overallConfidence: Double
    ) -> ProfileInterpretation {
        func value(_ dimension: AttentionDimension) -> Double {
            dimensions.first { $0.dimension == dimension }?.score ?? 0.5
        }

        let switching = value(.attentionalSwitching)
        let branching = value(.associativeBranching)
        let persistence = value(.focusPersistence)
        let dullness = value(.energyDullness)

        // The capacity/gating case, re-expressed qualitatively: the questionnaire
        // reports weak persistence while the observations describe long sustained
        // engagement. It is a contested hypothesis now, not a gap between two scores.
        let contestedDepth = hypotheses.first {
            $0.theme == .topicDepth && $0.supportState == .contested
        }
        if contestedDepth != nil, persistence < 0.45, max(switching, branching) > 0.6 {
            return ProfileInterpretation(
                title: Self.capacityGatingTitle,
                summary: "Sustained attention appears available once engagement is established, while choosing or holding the target may vary by context.",
                reasons: [
                    "Your questionnaire answers describe weaker persistence.",
                    "The observations describe long, sustained engagement on some subjects.",
                    "Attention switching is also elevated, so selection may matter more than capacity."
                ]
            )
        }

        if overallConfidence < 0.45 {
            return ProfileInterpretation(
                title: "Not enough evidence yet",
                summary: "Your answers do not yet support a confident overall pattern. The dimensions below are more useful than a single description.",
                reasons: ["There is not yet enough consistent evidence for a broader interpretation."]
            )
        }
        if dullness > 0.68 {
            return ProfileInterpretation(
                title: "Low-energy or dull at times",
                summary: "Quiet conditions may reduce alertness. This is a current-state hypothesis, not a diagnosis or permanent trait.",
                reasons: ["Your answers lean strongly toward low energy in quiet conditions."]
            )
        }
        if persistence > 0.7 && switching < 0.4 {
            return ProfileInterpretation(
                title: "Naturally sustained or one-pointed",
                summary: "Once attention settles, it may remain with one object for a substantial stretch. Context can still change this.",
                reasons: ["Your answers lean strongly toward staying with one thing.", "They also lean away from frequent switching."]
            )
        }
        if switching > 0.62 || branching > 0.68 {
            return ProfileInterpretation(
                title: "Exploratory or intermittently focused",
                summary: "Attention may move readily or open several related paths. This can support exploration while making one-object continuity less consistent.",
                reasons: [
                    switching > 0.62 ? "Your answers lean toward frequent switching." : "Switching is not the main signal.",
                    branching > 0.68 ? "Your answers lean toward branching into related ideas." : "Branching is not the main signal."
                ]
            )
        }
        return ProfileInterpretation(
            title: "Mixed and context-dependent",
            summary: "No single pattern dominates your current answers. The individual dimensions show where context may matter.",
            reasons: ["No provisional-pattern threshold clearly outweighs the alternatives."]
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    /// Statement-level comparison. Nothing numeric crosses between sources.
    private func makeComparisons(
        dimensions: [DimensionAssessment],
        observations: [ExternalObservation]
    ) -> [SourceComparison] {
        let filed = observations.filter { $0.theme != nil }
        guard !filed.isEmpty else { return [] }
        let engine = HypothesisEngine()

        return AttentionTheme.allCases.compactMap { theme -> SourceComparison? in
            let themeObservations = filed.filter { $0.theme == theme }
            let lean = engine.lean(for: theme, in: dimensions)
            let questionnaireEvidence = lean == .noClearLean
                ? []
                : dimensions.first { $0.dimension == theme.relatedDimension }?
                    .evidence
                    .filter { $0.source == .questionnaire }
                    .map(\.summary) ?? []
            guard !themeObservations.isEmpty || !questionnaireEvidence.isEmpty else { return nil }

            let relationship: EvidenceRelationship
            if themeObservations.contains(where: { $0.strength.supportsHypothesis }), lean != .noClearLean {
                relationship = lean == .clearlyPresent ? .agreement : .disagreement
            } else {
                relationship = .singleSource
            }

            return SourceComparison(
                theme: theme,
                relationship: relationship,
                questionnaireEvidence: questionnaireEvidence,
                externalAIEvidence: themeObservations.map(\.pattern)
            )
        }
    }
}
