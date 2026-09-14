import Foundation

struct ProfileEngine {
    func makeProfile(
        from answers: [QuestionAnswer],
        externalEvidence: ExternalEvidenceBundle? = nil,
        now: Date = .now
    ) -> AttentionProfile {
        let signals = QuestionnaireBank.signals(for: answers)
        let dimensions = AttentionDimension.allCases.map { dimension in
            assess(dimension, signals: signals.filter { $0.dimension == dimension })
        }
        let overallConfidence = dimensions.map(\.confidence).reduce(0, +) / Double(dimensions.count)
        return AttentionProfile(
            dimensions: dimensions,
            interpretation: interpret(dimensions: dimensions, overallConfidence: overallConfidence),
            overallConfidence: overallConfidence,
            updatedAt: now,
            externalEvidence: externalEvidence
        )
    }

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
            ? ["Your answers point in different directions here. Context may change this pattern, so the evidence is less settled."]
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
        overallConfidence: Double
    ) -> ProfileInterpretation {
        func value(_ dimension: AttentionDimension) -> Double {
            dimensions.first { $0.dimension == dimension }?.score ?? 0.5
        }

        let switching = value(.attentionalSwitching)
        let branching = value(.associativeBranching)
        let persistence = value(.focusPersistence)
        let dullness = value(.energyDullness)

        if overallConfidence < 0.45 {
            return ProfileInterpretation(
                title: "Not enough evidence yet",
                summary: "Your answers do not yet support a settled overall pattern. The observations below are more useful than a single description.",
                reasons: ["The questionnaire evidence is still limited or internally mixed."]
            )
        }
        if dullness > 0.68 {
            return ProfileInterpretation(
                title: "Low-energy or dull at times",
                summary: "Quiet conditions may reduce alertness. This is a current-state hypothesis, not a diagnosis or permanent trait.",
                reasons: ["Your energy and alertness answers lean toward dullness in quiet conditions."]
            )
        }
        if persistence > 0.7 && switching < 0.4 {
            return ProfileInterpretation(
                title: "Naturally sustained or one-pointed",
                summary: "Once attention settles, it may remain with one object for a substantial stretch. Context can still change this.",
                reasons: ["Your answers suggest sustained focus.", "They also suggest less frequent attention switching."]
            )
        }
        if switching > 0.62 || branching > 0.68 {
            return ProfileInterpretation(
                title: "Exploratory or intermittently focused",
                summary: "Attention may move readily or open several related paths. This can support exploration while making one-object continuity less consistent.",
                reasons: [
                    switching > 0.62 ? "Your answers suggest ready attention switching." : "Switching is not the main observation.",
                    branching > 0.68 ? "Your answers suggest associative branching." : "Associative branching is not the main observation."
                ]
            )
        }
        return ProfileInterpretation(
            title: "Mixed and context-dependent",
            summary: "No single pattern dominates your current answers. The individual observations show where context may matter.",
            reasons: ["No provisional pattern clearly outweighs the alternatives."]
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}
