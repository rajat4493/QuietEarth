import Foundation

/// A seven-day test of one working hypothesis. Not a streak: missing a day
/// costs nothing, and the plan never pressures.
struct Experiment: Codable, Hashable {
    let id: String
    let startedAt: Date
    let templateID: PracticeTemplateID
    let anchor: PracticeAnchor
    let minutes: Int
    let hypothesisID: String?
    let hypothesisStatement: String?
    let prediction: String
    let disconfirmation: String
    var outcomes: [PracticeOutcome]
    var review: DaySevenReview?

    var completedSessions: [PracticeOutcome] { outcomes.filter(\.isComplete) }

    func dayIndex(now: Date = .now, calendar: Calendar = .current) -> Int {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: startedAt), to: calendar.startOfDay(for: now)).day ?? 0
        return min(7, max(1, days + 1))
    }

    func isReadyForReview(now: Date = .now, calendar: Calendar = .current) -> Bool {
        review == nil && dayIndex(now: now, calendar: calendar) >= 7
    }

    func practisedToday(now: Date = .now, calendar: Calendar = .current) -> Bool {
        outcomes.contains { calendar.isDate($0.recordedAt, inSameDayAs: now) }
    }
}

enum DaySevenOutcome: String, Codable, Hashable {
    case retain
    case shorten
    case lengthen
    case changeAnchor
    case changeHypothesis
    case insufficientEvidence

    var title: String {
        switch self {
        case .retain: "Keep going as is"
        case .shorten: "Make it shorter"
        case .lengthen: "Make it longer"
        case .changeAnchor: "Change the anchor"
        case .changeHypothesis: "Change what we're testing"
        case .insufficientEvidence: "Not enough sessions yet"
        }
    }
}

struct DaySevenReview: Codable, Hashable {
    let outcome: DaySevenOutcome
    let summary: String
    let reasons: [String]
    /// nil when there were too few sessions to say either way.
    let predictionHeld: Bool?
    let observed: [String]
    let decidedAt: Date
    let adjustment: PracticeAdjustment
}

/// Deterministic day-seven rules. Requires at least four completed sessions
/// before any core hypothesis change, per `product/MEDITATION_ENGINE.md`.
struct AdaptationEngine {
    static let minimumSessionsForHypothesisChange = 4

    func review(for experiment: Experiment, now: Date = .now) -> DaySevenReview {
        let completed = experiment.completedSessions
        let observed = describe(experiment: experiment)

        guard completed.count >= Self.minimumSessionsForHypothesisChange else {
            return DaySevenReview(
                outcome: .insufficientEvidence,
                summary: "There were \(completed.count) completed sessions this week. We need at least \(Self.minimumSessionsForHypothesisChange) before changing anything based on practice.",
                reasons: ["Changing a hypothesis on fewer sessions than this would be reading noise."],
                predictionHeld: nil,
                observed: observed,
                decidedAt: now,
                adjustment: .keep
            )
        }

        let abandonedShare = Double(experiment.outcomes.count - completed.count) / Double(max(1, experiment.outcomes.count))
        let hardReturns = completed.filter { $0.returnEase == .hard }.count
        let fewNotices = completed.filter { $0.noticeRate == .few }.count
        let settledAfter = completed.filter { $0.afterward == .moreSettled }.count
        let scatteredAfter = completed.filter { $0.afterward == .moreScattered }.count
        let easingTrend = returnEaseImproved(completed)

        if abandonedShare >= 0.4 {
            return DaySevenReview(
                outcome: .shorten,
                summary: "Sessions were often cut short, so the length is the first thing to change — not the practice.",
                reasons: ["\(experiment.outcomes.count - completed.count) of \(experiment.outcomes.count) sessions ended early."],
                predictionHeld: nil,
                observed: observed,
                decidedAt: now,
                adjustment: .shorten
            )
        }

        // Few notices plus no settling points at dullness rather than branching:
        // the hypothesis is wrong in a specific, nameable way.
        if fewNotices > completed.count / 2 && settledAfter == 0 {
            return DaySevenReview(
                outcome: .changeHypothesis,
                summary: "You rarely noticed wandering and rarely felt more settled. That points to low alertness in quiet rather than to busy attention.",
                reasons: [
                    "Few notices in \(fewNotices) of \(completed.count) completed sessions.",
                    "No session was reported as leaving you more settled.",
                    "This is the condition we said would show the current hypothesis was wrong."
                ],
                predictionHeld: false,
                observed: observed,
                decidedAt: now,
                adjustment: .changePractice(.energizeThenAttend)
            )
        }

        if hardReturns > completed.count / 2 && !easingTrend {
            return DaySevenReview(
                outcome: .changeAnchor,
                summary: "Returning stayed hard all week and did not get easier. Before changing the hypothesis, it is worth changing what attention returns to.",
                reasons: [
                    "Returning was reported as hard in \(hardReturns) of \(completed.count) completed sessions.",
                    "Later sessions were not easier than earlier ones."
                ],
                predictionHeld: false,
                observed: observed,
                decidedAt: now,
                adjustment: .changeAnchor
            )
        }

        if easingTrend && settledAfter >= scatteredAfter {
            return DaySevenReview(
                outcome: .lengthen,
                summary: "Returning got easier across the week, which is what this hypothesis predicted. A slightly longer session is the next test.",
                reasons: [
                    "Later sessions were reported as easier to return in than earlier ones.",
                    "Sessions left you more settled at least as often as more scattered."
                ],
                predictionHeld: true,
                observed: observed,
                decidedAt: now,
                adjustment: .lengthen
            )
        }

        return DaySevenReview(
            outcome: .retain,
            summary: "The week was broadly consistent with what we expected. Nothing here justifies a change yet.",
            reasons: [
                "\(completed.count) completed sessions.",
                "No condition we set for changing the practice was met."
            ],
            predictionHeld: true,
            observed: observed,
            decidedAt: now,
            adjustment: .keep
        )
    }

    /// True when the later half of the week was easier to return in than the first.
    func returnEaseImproved(_ outcomes: [PracticeOutcome]) -> Bool {
        guard outcomes.count >= 4 else { return false }
        let ordered = outcomes.sorted { $0.recordedAt < $1.recordedAt }
        let half = ordered.count / 2
        let first = ordered.prefix(half).map { Double($0.returnEase.rank) }
        let second = ordered.suffix(ordered.count - half).map { Double($0.returnEase.rank) }
        guard !first.isEmpty, !second.isEmpty else { return false }
        let firstMean = first.reduce(0, +) / Double(first.count)
        let secondMean = second.reduce(0, +) / Double(second.count)
        return secondMean > firstMean
    }

    /// Counts of things the user actually reported. The only numbers in the product.
    func describe(experiment: Experiment) -> [String] {
        let completed = experiment.completedSessions
        guard !completed.isEmpty else { return ["No sessions were completed this week."] }
        func count(_ predicate: (PracticeOutcome) -> Bool) -> Int { completed.filter(predicate).count }
        return [
            "\(completed.count) of \(experiment.outcomes.count) sessions completed.",
            "Noticed wandering often in \(count { $0.noticeRate == .many }) sessions, rarely in \(count { $0.noticeRate == .few }).",
            "Returning felt easy in \(count { $0.returnEase == .easy }) sessions and hard in \(count { $0.returnEase == .hard }).",
            "Afterwards you felt more settled in \(count { $0.afterward == .moreSettled }) sessions and more scattered in \(count { $0.afterward == .moreScattered })."
        ]
    }
}
