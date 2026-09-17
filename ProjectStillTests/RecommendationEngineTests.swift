import Foundation
import Testing
@testable import ProjectStill

struct RecommendationEngineTests {
    private let engine = RecommendationEngine()

    /// A completed 12-question intake with no strong lean, so each test changes
    /// only the answers it is actually about. A partial questionnaire would fall
    /// below the confidence floor and route everything to the baseline practice.
    private static let neutralAnswers: [String: String] = [
        "switching": "sometimes",
        "persistence": "short",
        "branching": "few",
        "disengagement": "mostly_easy",
        "novelty": "mostly_steady",
        "emotion": "brief",
        "dullness": "stable",
        "low_stimulation": "okay",
        "noticing": "after",
        "sensory": "plan",
        "deadline": "same",
        "quiet_sit": "settled"
    ]

    private func profile(_ overrides: [(String, String)] = []) -> AttentionProfile {
        var answers = Self.neutralAnswers
        for (question, option) in overrides {
            answers[question] = option
        }
        return ProfileEngine().makeProfile(
            from: answers.map { QuestionAnswer(questionID: $0.key, optionID: $0.value, answeredAt: .distantPast) }
        )
    }

    private func emptyProfile() -> AttentionProfile {
        ProfileEngine().makeProfile(from: [])
    }

    @Test("High switching routes to Return Training and says why in words")
    func returnTraining() {
        let result = engine.recommend(profile: profile([
            ("switching", "very_often"),
            ("branching", "many"),
            ("deadline", "fragments")
        ]))

        #expect(result.template.id == .returnTraining)
        #expect(!result.reasons.isEmpty)
        // The rationale is evidence statements, never a score.
        #expect(!result.reasons.contains { $0.contains("%") || $0.contains("0.") })
    }

    @Test("Dullness takes precedence over switching")
    func dullnessFirst() {
        let result = engine.recommend(profile: profile([
            ("dullness", "sleepy"),
            ("quiet_sit", "sleepy"),
            ("switching", "very_often")
        ]))
        #expect(result.template.id == .energizeThenAttend)
    }

    @Test("Emotional capture routes to Emotional Clearing")
    func emotionalClearing() {
        let result = engine.recommend(profile: profile([
            ("emotion", "dominates")
        ]))
        #expect(result.template.id == .emotionalClearing)
    }

    @Test("Restless plus switching settles the body first")
    func settleThenFocus() {
        let result = engine.recommend(profile: profile([
            ("switching", "often"),
            ("low_stimulation", "uncomfortable"),
            ("quiet_sit", "restless")
        ]))
        #expect(result.template.id == .settleThenFocus)
    }

    @Test("Sustained attention routes to Sustained Flow")
    func sustainedFlow() {
        let result = engine.recommend(profile: profile([
            ("persistence", "very_long"),
            ("switching", "rarely"),
            ("deadline", "locks")
        ]))
        #expect(result.template.id == .sustainedFlow)
    }

    @Test("Insufficient evidence gives a neutral baseline rather than a guess")
    func insufficientEvidence() {
        let result = engine.recommend(profile: emptyProfile())
        #expect(result.template.id == .baselineSettling)
        #expect(result.reasons.first?.contains("not yet enough") == true)
    }

    @Test("Sensory orientation chooses the anchor")
    func anchorSelection() {
        let sensory = engine.recommend(profile: profile([("sensory", "senses")]))
        let conceptual = engine.recommend(profile: profile([("sensory", "words")]))
        #expect(sensory.anchor.isSensory)
        #expect(!conceptual.anchor.isSensory)
    }

    @Test("Every template produces steps that sum to the chosen length")
    func stepsAddUp() {
        for template in PracticeTemplate.all {
            for minutes in [template.shortestMinutes, template.defaultMinutes, template.longestMinutes] {
                for anchor in PracticeAnchor.allCases {
                    let steps = template.steps(minutes: minutes, anchor: anchor)
                    #expect(steps.allSatisfy { $0.seconds > 0 })
                    #expect(steps.reduce(0) { $0 + $1.seconds } == minutes * 60)
                }
            }
        }
    }

    @Test("Guidance arrives as ordered cues inside every step")
    func cuesAreWellFormed() {
        for template in PracticeTemplate.all {
            for minutes in [template.shortestMinutes, template.longestMinutes] {
                for anchor in PracticeAnchor.allCases {
                    for step in template.steps(minutes: minutes, anchor: anchor) {
                        #expect(!step.cues.isEmpty)
                        #expect(step.cues.allSatisfy { (0...1).contains($0.fraction) })
                        #expect(step.cues.allSatisfy { !$0.text.isEmpty })
                        // Offsets stay inside the step and never run backwards.
                        let offsets = step.cues.map { $0.offset(in: step.seconds) }
                        #expect(offsets == offsets.sorted())
                        #expect(offsets.allSatisfy { $0 >= 0 && $0 < step.seconds })
                        // A cue is always in force, including at the first second.
                        #expect(step.cue(atElapsed: 0) != nil)
                        #expect(step.cue(atElapsed: step.seconds - 1) != nil)
                    }
                }
            }
        }
    }

    @Test("Every practice carries a classical reference with its own gloss")
    func referencesArePresent() {
        for template in PracticeTemplate.all {
            let reference = ClassicalReference.reference(for: template.id)
            #expect(reference != nil)
            #expect(reference?.gloss.isEmpty == false)
            #expect(reference?.caveat.isEmpty == false)
            // The gloss is ours; a public-domain edition is named for checking.
            #expect(reference?.publicDomainSource.isEmpty == false)
        }
    }

    @Test("Adjustments change length or anchor within the template's bounds")
    func adjustments() {
        let base = profile([("switching", "very_often"), ("branching", "many")])
        let start = engine.recommend(profile: base)
        let longer = engine.recommend(profile: base, adjustment: .lengthen)
        let shorter = engine.recommend(profile: base, adjustment: .shorten)
        let reanchored = engine.recommend(profile: base, adjustment: .changeAnchor)

        #expect(longer.minutes >= start.minutes)
        #expect(longer.minutes <= start.template.longestMinutes)
        #expect(shorter.minutes <= start.minutes)
        #expect(shorter.minutes >= start.template.shortestMinutes)
        #expect(reanchored.anchor != start.anchor)
    }
}
