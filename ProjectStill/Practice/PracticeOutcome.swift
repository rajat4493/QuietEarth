import Foundation

/// One tappable reflection answer.
protocol ReflectionOption: Identifiable, Hashable, CaseIterable {
    var title: String { get }
}

/// The three fast reflection inputs. Ordinal by design: the app records what the
/// user reported, and never converts it into a trait score.
enum NoticeRate: String, Codable, ReflectionOption {
    case few, some, many
    var id: String { rawValue }
    var title: String {
        switch self {
        case .few: "Few"
        case .some: "Some"
        case .many: "Many"
        }
    }
}

enum ReturnEase: String, Codable, ReflectionOption {
    case hard, mixed, easy
    var id: String { rawValue }
    var title: String {
        switch self {
        case .hard: "Hard"
        case .mixed: "Mixed"
        case .easy: "Easy"
        }
    }
    var rank: Int {
        switch self {
        case .hard: 0
        case .mixed: 1
        case .easy: 2
        }
    }
}

enum AfterwardState: String, Codable, ReflectionOption {
    case moreScattered, same, moreSettled
    var id: String { rawValue }
    var title: String {
        switch self {
        case .moreScattered: "More scattered"
        case .same: "Same"
        case .moreSettled: "More settled"
        }
    }
    var rank: Int {
        switch self {
        case .moreScattered: 0
        case .same: 1
        case .moreSettled: 2
        }
    }
}

struct PracticeOutcome: Codable, Hashable, Identifiable {
    let id: String
    let templateID: PracticeTemplateID
    let anchor: PracticeAnchor
    let plannedSeconds: Int
    let completedSeconds: Int
    let noticeRate: NoticeRate
    let returnEase: ReturnEase
    let afterward: AfterwardState
    let note: String?
    let recordedAt: Date

    /// A session counts as completed when the user reached the closing step.
    var isComplete: Bool {
        plannedSeconds > 0 && completedSeconds >= Int(Double(plannedSeconds) * 0.9)
    }
}
