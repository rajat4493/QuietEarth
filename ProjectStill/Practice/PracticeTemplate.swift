import Foundation

/// What attention rests on during a practice. Changing the anchor is one of the
/// day-seven adjustments, so anchors are first-class rather than copy.
enum PracticeAnchor: String, Codable, Hashable, CaseIterable, Identifiable {
    case breath
    case bodyContact
    case sound
    case counting
    case phrase

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breath: "The breath"
        case .bodyContact: "Contact with the seat or feet"
        case .sound: "Sound in the room"
        case .counting: "Counting exhales"
        case .phrase: "A short repeated phrase"
        }
    }

    var instruction: String {
        switch self {
        case .breath: "Let attention rest where the breath is easiest to feel. Do not control it."
        case .bodyContact: "Let attention rest where your body meets the seat or the floor."
        case .sound: "Let attention rest on whatever sound is present, near or far."
        case .counting: "Count each exhale, one to ten, then begin again."
        case .phrase: "Repeat one short phrase at your own pace, without forcing it."
        }
    }

    /// Concrete/sensory anchors suit a sensory orientation; counting and phrase
    /// suit a more verbal or conceptual one.
    var isSensory: Bool {
        switch self {
        case .breath, .bodyContact, .sound: true
        case .counting, .phrase: false
        }
    }
}

/// One step of a session. Text and timing only — no audio in the MVP.
struct PracticeStep: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let instruction: String
    let seconds: Int
}

enum PracticeTemplateID: String, Codable, Hashable, CaseIterable, Identifiable {
    case returnTraining
    case settleThenFocus
    case energizeThenAttend
    case emotionalClearing
    case sustainedFlow
    case baselineSettling

    var id: String { rawValue }
}

struct PracticeTemplate: Codable, Hashable, Identifiable {
    let id: PracticeTemplateID
    let title: String
    let purpose: String
    /// What counts as the practice going well — never "an empty mind".
    let successMeaning: String
    let shortestMinutes: Int
    let longestMinutes: Int
    let defaultMinutes: Int
    let preferredAnchors: [PracticeAnchor]

    func steps(minutes: Int, anchor: PracticeAnchor) -> [PracticeStep] {
        PracticeTemplate.steps(for: id, minutes: minutes, anchor: anchor)
    }

    func clampedMinutes(_ minutes: Int) -> Int {
        min(longestMinutes, max(shortestMinutes, minutes))
    }
}

extension PracticeTemplate {
    static func template(_ id: PracticeTemplateID) -> PracticeTemplate {
        switch id {
        case .returnTraining:
            PracticeTemplate(
                id: .returnTraining,
                title: "Return Training",
                purpose: "Practise noticing that attention has moved, and coming back, as the skill itself.",
                successMeaning: "Success is noticing and returning often — not staying put. A busy session can be a good one.",
                shortestMinutes: 5,
                longestMinutes: 7,
                defaultMinutes: 5,
                preferredAnchors: [.breath, .bodyContact, .counting]
            )
        case .settleThenFocus:
            PracticeTemplate(
                id: .settleThenFocus,
                title: "Settle Then Focus",
                purpose: "Let the body settle first, so attention is not asked to steady an unsettled system.",
                successMeaning: "Success is the settling phase making the second half easier, not a particular feeling.",
                shortestMinutes: 6,
                longestMinutes: 8,
                defaultMinutes: 6,
                preferredAnchors: [.breath, .bodyContact]
            )
        case .energizeThenAttend:
            PracticeTemplate(
                id: .energizeThenAttend,
                title: "Energize Then Attend",
                purpose: "Raise alertness before asking for stillness, when quiet tends to bring dullness.",
                successMeaning: "Success is being more awake at the end than at the start.",
                shortestMinutes: 4,
                longestMinutes: 6,
                defaultMinutes: 4,
                preferredAnchors: [.bodyContact, .sound, .counting]
            )
        case .emotionalClearing:
            PracticeTemplate(
                id: .emotionalClearing,
                title: "Emotional Clearing",
                purpose: "Name what is present before asking attention to rest, when feeling keeps pulling it back.",
                successMeaning: "Success is the naming phase loosening the pull a little — not making the feeling go away.",
                shortestMinutes: 6,
                longestMinutes: 8,
                defaultMinutes: 6,
                preferredAnchors: [.breath, .bodyContact, .phrase]
            )
        case .sustainedFlow:
            PracticeTemplate(
                id: .sustainedFlow,
                title: "Sustained Flow",
                purpose: "Give attention a longer uninterrupted stretch with one object, when it tends to stay once settled.",
                successMeaning: "Success is a long stretch with one object. Losing it and returning is still fine.",
                shortestMinutes: 8,
                longestMinutes: 10,
                defaultMinutes: 8,
                preferredAnchors: [.breath, .sound, .phrase]
            )
        case .baselineSettling:
            PracticeTemplate(
                id: .baselineSettling,
                title: "Baseline Settling",
                purpose: "A short neutral practice while we gather enough evidence to suggest something more specific.",
                successMeaning: "Success is simply completing it. We are collecting evidence, not testing a claim yet.",
                shortestMinutes: 4,
                longestMinutes: 6,
                defaultMinutes: 5,
                preferredAnchors: [.breath, .bodyContact]
            )
        }
    }

    static var all: [PracticeTemplate] { PracticeTemplateID.allCases.map(template) }

    /// Deterministic step plan. Phase seconds always sum to the chosen minutes.
    static func steps(for id: PracticeTemplateID, minutes: Int, anchor: PracticeAnchor) -> [PracticeStep] {
        let total = max(60, minutes * 60)
        func step(_ key: String, _ title: String, _ instruction: String, _ seconds: Int) -> PracticeStep {
            PracticeStep(id: "\(id.rawValue).\(key)", title: title, instruction: instruction, seconds: seconds)
        }

        switch id {
        case .returnTraining:
            let settle = max(30, total / 10)
            return [
                step("arrive", "Arrive", "Sit so you are upright but not rigid. Let the eyes close or soften.", settle),
                step("anchor", "Return", "\(anchor.instruction) When you notice attention has moved, that noticing is the practice. Come back without comment.", total - settle - 20),
                step("close", "Close", "Let the anchor go. Notice how attention is now.", 20)
            ]
        case .settleThenFocus:
            let settle = total * 2 / 5
            return [
                step("exhale", "Settle", "Let each out-breath be a little longer than the in-breath. No forcing, no counting pressure.", settle),
                step("anchor", "Focus", anchor.instruction, total - settle - 20),
                step("close", "Close", "Let the anchor go. Notice how the body is now.", 20)
            ]
        case .energizeThenAttend:
            let rouse = max(45, total / 3)
            return [
                step("posture", "Wake up", "Sit tall, open the eyes, lift the gaze slightly. Feel the feet and the spine.", rouse),
                step("anchor", "Attend", "Keep the eyes open and soft. \(anchor.instruction)", total - rouse - 20),
                step("close", "Close", "Notice whether you are more awake than when you began.", 20)
            ]
        case .emotionalClearing:
            let label = total * 2 / 5
            return [
                step("label", "Name it", "Notice what feeling is present and name it once, plainly — “worry”, “irritation”, “nothing much”. Then let it be.", label),
                step("anchor", "Rest", anchor.instruction, total - label - 20),
                step("close", "Close", "Notice whether the pull has loosened at all. Either answer is information.", 20)
            ]
        case .sustainedFlow:
            let settle = max(45, total / 8)
            return [
                step("arrive", "Arrive", "Settle the posture. Let the breath find its own rhythm.", settle),
                step("anchor", "Stay", "\(anchor.instruction) Let it hold your attention for a longer stretch than feels usual.", total - settle - 30),
                step("close", "Close", "Let the anchor go slowly rather than all at once.", 30)
            ]
        case .baselineSettling:
            let settle = max(30, total / 6)
            return [
                step("arrive", "Arrive", "Sit comfortably. Nothing to achieve here.", settle),
                step("anchor", "Rest", anchor.instruction, total - settle - 20),
                step("close", "Close", "Notice how attention is now.", 20)
            ]
        }
    }
}
