import Foundation
import Testing
@testable import ProjectStill

struct AdaptationEngineTests {
    private let engine = AdaptationEngine()

    private func experiment(
        outcomes: [PracticeOutcome],
        startedDaysAgo: Int = 6
    ) -> Experiment {
        Experiment(
            id: "experiment.test",
            startedAt: Calendar.current.date(byAdding: .day, value: -startedDaysAgo, to: .now) ?? .now,
            templateID: .returnTraining,
            anchor: .breath,
            minutes: 5,
            hypothesisID: "hypothesis.test",
            hypothesisStatement: "Your attention may branch before it settles.",
            prediction: "Returning should get easier across the week.",
            disconfirmation: "Few notices with hard returns would point to dullness instead.",
            outcomes: outcomes,
            review: nil
        )
    }

    private func outcome(
        day: Int,
        notice: NoticeRate = .many,
        ease: ReturnEase = .mixed,
        after: AfterwardState = .same,
        completedShare: Double = 1
    ) -> PracticeOutcome {
        let planned = 300
        return PracticeOutcome(
            id: "outcome.\(day)",
            templateID: .returnTraining,
            anchor: .breath,
            plannedSeconds: planned,
            completedSeconds: Int(Double(planned) * completedShare),
            noticeRate: notice,
            returnEase: ease,
            afterward: after,
            note: nil,
            recordedAt: Calendar.current.date(byAdding: .day, value: day, to: .now.addingTimeInterval(-6 * 86_400)) ?? .now
        )
    }

    @Test("Fewer than four completed sessions cannot change a hypothesis")
    func minimumSessions() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0), outcome(day: 1), outcome(day: 2)
        ]))
        #expect(review.outcome == .insufficientEvidence)
        #expect(review.predictionHeld == nil)
        #expect(review.adjustment == .keep)
    }

    @Test("Sessions cut short shorten the practice before anything else changes")
    func shortenWhenAbandoned() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0), outcome(day: 1), outcome(day: 2), outcome(day: 3),
            outcome(day: 4, completedShare: 0.2), outcome(day: 5, completedShare: 0.2),
            outcome(day: 6, completedShare: 0.1)
        ]))
        #expect(review.outcome == .shorten)
        #expect(review.adjustment == .shorten)
    }

    @Test("Few notices and no settling change the hypothesis toward dullness")
    func changeHypothesis() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0, notice: .few, ease: .mixed, after: .same),
            outcome(day: 1, notice: .few, ease: .mixed, after: .same),
            outcome(day: 2, notice: .few, ease: .hard, after: .moreScattered),
            outcome(day: 3, notice: .few, ease: .mixed, after: .same)
        ]))
        #expect(review.outcome == .changeHypothesis)
        #expect(review.predictionHeld == false)
        #expect(review.adjustment == .changePractice(.energizeThenAttend))
    }

    @Test("Persistently hard returns change the anchor before the hypothesis")
    func changeAnchor() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0, notice: .many, ease: .hard, after: .same),
            outcome(day: 1, notice: .many, ease: .hard, after: .same),
            outcome(day: 2, notice: .many, ease: .hard, after: .moreSettled),
            outcome(day: 3, notice: .many, ease: .hard, after: .same)
        ]))
        #expect(review.outcome == .changeAnchor)
        #expect(review.adjustment == .changeAnchor)
    }

    @Test("Returning getting easier confirms the prediction and lengthens")
    func lengthenWhenImproving() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0, ease: .hard, after: .same),
            outcome(day: 1, ease: .mixed, after: .moreSettled),
            outcome(day: 2, ease: .easy, after: .moreSettled),
            outcome(day: 3, ease: .easy, after: .moreSettled)
        ]))
        #expect(review.outcome == .lengthen)
        #expect(review.predictionHeld == true)
        #expect(review.adjustment == .lengthen)
    }

    @Test("A steady week is retained rather than adjusted for its own sake")
    func retain() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0, ease: .mixed, after: .same),
            outcome(day: 1, ease: .mixed, after: .same),
            outcome(day: 2, ease: .mixed, after: .same),
            outcome(day: 3, ease: .mixed, after: .same)
        ]))
        #expect(review.outcome == .retain)
        #expect(review.adjustment == .keep)
    }

    @Test("Observed lines are counts of reported sessions, never trait numbers")
    func observedIsCountsOnly() {
        let review = engine.review(for: experiment(outcomes: [
            outcome(day: 0), outcome(day: 1), outcome(day: 2), outcome(day: 3)
        ]))
        #expect(!review.observed.isEmpty)
        #expect(!review.observed.contains { $0.contains("%") })
    }

    @Test("Day index is bounded to the seven-day window")
    func dayIndexBounds() {
        #expect(experiment(outcomes: [], startedDaysAgo: 0).dayIndex() == 1)
        #expect(experiment(outcomes: [], startedDaysAgo: 6).dayIndex() == 7)
        #expect(experiment(outcomes: [], startedDaysAgo: 40).dayIndex() == 7)
    }

    @Test("An experiment is ready for review only at day seven and only once")
    func readiness() {
        #expect(!experiment(outcomes: [], startedDaysAgo: 3).isReadyForReview())
        #expect(experiment(outcomes: [], startedDaysAgo: 6).isReadyForReview())

        var reviewed = experiment(outcomes: [], startedDaysAgo: 6)
        reviewed.review = engine.review(for: reviewed)
        #expect(!reviewed.isReadyForReview())
    }
}
