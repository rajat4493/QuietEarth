import Foundation

struct ProfileEngine {
    func makeProfile(
        from answers: [QuestionAnswer],
        additionalSignals: [ObservedSignal] = [],
        externalPayload: ExternalAIProfilePayload? = nil,
        now: Date = .now
    ) -> AttentionProfile {
        let signals = QuestionnaireBank.signals(for: answers) + additionalSignals
        let dimensions = AttentionDimension.allCases.map { dimension in
            assess(dimension, signals: signals.filter { $0.dimension == dimension })
        }
        let overallConfidence = dimensions.map(\.confidence).reduce(0, +) / Double(dimensions.count)
        let comparisons = makeComparisons(from: signals)
        let interpretation = interpret(
            dimensions: dimensions,
            comparisons: comparisons,
            overallConfidence: overallConfidence
        )
        var alternatives = externalPayload?.alternativeInterpretations.map {
            "\($0.label) — \($0.reason)"
        } ?? []
        if interpretation.title == "Capacity present, gating appears variable",
           !alternatives.contains(where: { $0.localizedCaseInsensitiveContains("generalized weak concentration") }) {
            alternatives.insert(
                "Generalized weak concentration — This remains possible, but it does not explain the observed periods of strong persistence.",
                at: 0
            )
        }
        return AttentionProfile(
            dimensions: dimensions,
            interpretation: interpretation,
            overallConfidence: overallConfidence,
            updatedAt: now,
            sourceComparisons: comparisons.isEmpty ? nil : comparisons,
            alternativeInterpretations: alternatives.isEmpty ? nil : alternatives,
            externalSelfReportSummary: externalPayload?.selfReportSummary,
            externalBehavioralSummary: externalPayload?.behavioralSummary
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
        comparisons: [SourceComparison],
        overallConfidence: Double
    ) -> ProfileInterpretation {
        func value(_ dimension: AttentionDimension) -> Double {
            dimensions.first { $0.dimension == dimension }?.score ?? 0.5
        }

        let switching = value(.attentionalSwitching)
        let branching = value(.associativeBranching)
        let persistence = value(.focusPersistence)
        let dullness = value(.energyDullness)

        let persistenceComparison = comparisons.first { $0.dimension == .focusPersistence }
        let switchingComparison = comparisons.first { $0.dimension == .attentionalSwitching }
        if let questionnairePersistence = persistenceComparison?.questionnaireScore,
           let externalPersistence = persistenceComparison?.externalAIScore,
           questionnairePersistence < 0.4,
           externalPersistence > 0.65,
           max(switchingComparison?.questionnaireScore ?? 0, switchingComparison?.externalAIScore ?? 0) > 0.65 {
            return ProfileInterpretation(
                title: "Capacity present, gating appears variable",
                summary: "Sustained attention appears available once engagement is established, while choosing or maintaining the target may vary by context.",
                reasons: [
                    "Your questionnaire reports weaker persistence.",
                    "Behavioral evidence reports strong persistence when engaged.",
                    "At least one source also reports high attention switching."
                ]
            )
        }

        if overallConfidence < 0.45 {
            return ProfileInterpretation(
                title: "Not enough evidence yet",
                summary: "Your answers do not yet support a confident overall pattern. The dimensions below are more useful than a single description.",
                reasons: ["Overall confidence is below the threshold for a broader interpretation."]
            )
        }
        if dullness > 0.68 {
            return ProfileInterpretation(
                title: "Low-energy or dull at times",
                summary: "Quiet conditions may reduce alertness. This is a current-state hypothesis, not a diagnosis or permanent trait.",
                reasons: ["Energy / dullness scored above 68%."]
            )
        }
        if persistence > 0.7 && switching < 0.4 {
            return ProfileInterpretation(
                title: "Naturally sustained or one-pointed",
                summary: "Once attention settles, it may remain with one object for a substantial stretch. Context can still change this.",
                reasons: ["Focus persistence is high.", "Attention switching is comparatively low."]
            )
        }
        if switching > 0.62 || branching > 0.68 {
            return ProfileInterpretation(
                title: "Exploratory or intermittently focused",
                summary: "Attention may move readily or open several related paths. This can support exploration while making one-object continuity less consistent.",
                reasons: [
                    switching > 0.62 ? "Attention switching is elevated." : "Attention switching is not the main signal.",
                    branching > 0.68 ? "Associative branching is elevated." : "Associative branching is not the main signal."
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

    private func makeComparisons(from signals: [ObservedSignal]) -> [SourceComparison] {
        guard signals.contains(where: { $0.source.isExternalAI }) else { return [] }
        return AttentionDimension.allCases.map { dimension in
            let dimensionSignals = signals.filter { $0.dimension == dimension }
            let questionnaire = dimensionSignals.filter { $0.source == .questionnaire }
            let external = dimensionSignals.filter { $0.source.isExternalAI }
            let questionnaireScore = sourceScore(questionnaire)
            let externalScore = sourceScore(external)
            let relationship: EvidenceRelationship
            if let questionnaireScore, let externalScore {
                relationship = abs(questionnaireScore - externalScore) <= 0.18 ? .agreement : .disagreement
            } else {
                relationship = .singleSource
            }
            return SourceComparison(
                dimension: dimension,
                relationship: relationship,
                questionnaireScore: questionnaireScore,
                externalAIScore: externalScore,
                questionnaireEvidence: questionnaire.map(\.summary),
                externalAIEvidence: external.map(\.summary)
            )
        }
    }

    private func sourceScore(_ signals: [ObservedSignal]) -> Double? {
        let totalWeight = signals.reduce(0) { $0 + $1.weight * $1.confidence }
        guard totalWeight > 0 else { return nil }
        let direction = signals.reduce(0) {
            $0 + $1.direction * $1.weight * $1.confidence
        } / totalWeight
        return clamp((direction + 1) / 2)
    }
}
