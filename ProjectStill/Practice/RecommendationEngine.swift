import Foundation

struct PracticeRecommendation: Codable, Hashable {
    let template: PracticeTemplate
    let anchor: PracticeAnchor
    let minutes: Int
    /// Why this practice, in evidence statements. Never a score.
    let reasons: [String]
    /// The claim this practice is set up to test, when there is one.
    let hypothesisID: String?
    let hypothesisStatement: String?

    var seconds: Int { minutes * 60 }
}

/// Deterministic rules, in a fixed precedence. Dimension scores are internal
/// routing values from the questionnaire; the user-facing rationale is always
/// the evidence statements behind them.
struct RecommendationEngine {
    func recommend(
        profile: AttentionProfile,
        hypotheses: [WorkingHypothesis] = [],
        adjustment: PracticeAdjustment? = nil
    ) -> PracticeRecommendation {
        let base = baseRecommendation(profile: profile, hypotheses: hypotheses)
        guard let adjustment else { return base }
        return apply(adjustment, to: base, profile: profile)
    }

    private func baseRecommendation(
        profile: AttentionProfile,
        hypotheses: [WorkingHypothesis]
    ) -> PracticeRecommendation {
        func score(_ dimension: AttentionDimension) -> Double {
            profile.assessment(for: dimension).score
        }
        func evidence(_ dimension: AttentionDimension) -> [String] {
            Array(profile.assessment(for: dimension).evidence.map(\.summary).prefix(2))
        }

        let templateID: PracticeTemplateID
        var reasons: [String]

        if profile.evidenceStrength == .insufficient || profile.overallConfidence < 0.45 {
            templateID = .baselineSettling
            reasons = ["There is not yet enough consistent evidence to suggest a specific practice, so this one is deliberately neutral."]
        } else if score(.energyDullness) > 0.70 {
            templateID = .energizeThenAttend
            reasons = ["You described quiet conditions reducing your alertness."] + evidence(.energyDullness)
        } else if score(.emotionalCapture) > 0.70 {
            templateID = .emotionalClearing
            reasons = ["You described emotionally charged material holding your attention."] + evidence(.emotionalCapture)
        } else if score(.attentionalSwitching) > 0.60 && score(.lowStimulationTolerance) < 0.40 {
            templateID = .settleThenFocus
            reasons = ["You described attention moving often, and quiet activity being uncomfortable to stay with."]
                + evidence(.lowStimulationTolerance)
        } else if score(.attentionalSwitching) > 0.70 {
            templateID = .returnTraining
            reasons = ["You described attention changing targets often without an outside interruption."]
                + evidence(.attentionalSwitching)
        } else if score(.focusPersistence) > 0.75 && score(.attentionalSwitching) < 0.40 {
            templateID = .sustainedFlow
            reasons = ["You described attention staying with one thing once it settles."] + evidence(.focusPersistence)
        } else {
            templateID = .returnTraining
            reasons = ["No single pattern dominates yet, so we start with the practice that suits the widest range: noticing and returning."]
        }

        let template = PracticeTemplate.template(templateID)
        let anchor = self.anchor(for: template, profile: profile)
        reasons.append("Anchor: \(anchor.title.lowercased()) — \(anchorReason(anchor, profile: profile))")

        let hypothesis = hypotheses.first
        if let hypothesis {
            reasons.append("This week tests: \(hypothesis.statement)")
        }

        return PracticeRecommendation(
            template: template,
            anchor: anchor,
            minutes: template.defaultMinutes,
            reasons: reasons,
            hypothesisID: hypothesis?.id,
            hypothesisStatement: hypothesis?.statement
        )
    }

    /// Sensory orientation chooses between a felt anchor and a verbal one.
    func anchor(for template: PracticeTemplate, profile: AttentionProfile) -> PracticeAnchor {
        let sensory = profile.assessment(for: .sensoryOrientation)
        let prefersSensory = sensory.confidence < 0.45 || sensory.score >= 0.5
        return template.preferredAnchors.first { $0.isSensory == prefersSensory }
            ?? template.preferredAnchors[0]
    }

    private func anchorReason(_ anchor: PracticeAnchor, profile: AttentionProfile) -> String {
        let sensory = profile.assessment(for: .sensoryOrientation)
        if sensory.confidence < 0.45 {
            return "a straightforward starting point while we learn what works for you"
        }
        return anchor.isSensory
            ? "you described bodily and sensory cues being the more available way back"
            : "you described a phrase or plan being the more available way back"
    }

    /// Applies a day-seven adjustment without re-deriving the whole profile.
    private func apply(
        _ adjustment: PracticeAdjustment,
        to base: PracticeRecommendation,
        profile: AttentionProfile
    ) -> PracticeRecommendation {
        switch adjustment {
        case .keep:
            return base
        case .shorten:
            let minutes = base.template.clampedMinutes(base.minutes - 2)
            return PracticeRecommendation(
                template: base.template,
                anchor: base.anchor,
                minutes: minutes,
                reasons: base.reasons + ["Shortened after last week: sessions were often cut short."],
                hypothesisID: base.hypothesisID,
                hypothesisStatement: base.hypothesisStatement
            )
        case .lengthen:
            let minutes = base.template.clampedMinutes(base.minutes + 2)
            return PracticeRecommendation(
                template: base.template,
                anchor: base.anchor,
                minutes: minutes,
                reasons: base.reasons + ["Lengthened after last week: returning became easier as the week went on."],
                hypothesisID: base.hypothesisID,
                hypothesisStatement: base.hypothesisStatement
            )
        case .changeAnchor:
            let alternative = base.template.preferredAnchors.first { $0 != base.anchor } ?? base.anchor
            return PracticeRecommendation(
                template: base.template,
                anchor: alternative,
                minutes: base.minutes,
                reasons: base.reasons.filter { !$0.hasPrefix("Anchor:") }
                    + ["Anchor changed to \(alternative.title.lowercased()) after last week: returning stayed hard with the previous one."],
                hypothesisID: base.hypothesisID,
                hypothesisStatement: base.hypothesisStatement
            )
        case .changePractice(let templateID):
            let template = PracticeTemplate.template(templateID)
            let anchor = self.anchor(for: template, profile: profile)
            return PracticeRecommendation(
                template: template,
                anchor: anchor,
                minutes: template.defaultMinutes,
                reasons: ["Changed after last week — what you reported did not match what this hypothesis predicted.",
                          "Anchor: \(anchor.title.lowercased())."],
                hypothesisID: base.hypothesisID,
                hypothesisStatement: base.hypothesisStatement
            )
        }
    }
}

enum PracticeAdjustment: Codable, Hashable {
    case keep
    case shorten
    case lengthen
    case changeAnchor
    case changePractice(PracticeTemplateID)
}
