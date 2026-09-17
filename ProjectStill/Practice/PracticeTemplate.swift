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

/// One line of guidance, placed at a fraction of its step's length so the
/// pacing scales with any session length.
struct PracticeCue: Codable, Hashable, Identifiable {
    let id: String
    let text: String
    /// 0...1 through the step. A cue stays on screen until the next one.
    let fraction: Double

    func offset(in seconds: Int) -> Int {
        min(seconds - 1, max(0, Int(fraction * Double(seconds))))
    }
}

/// One phase of a session. Text and timing only — no audio in the MVP.
/// Guidance arrives as spaced cues with silence between them, rather than a
/// paragraph held on screen for four minutes.
struct PracticeStep: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let seconds: Int
    let cues: [PracticeCue]

    /// The cue in force at this point in the step.
    func cue(atElapsed elapsed: Int) -> PracticeCue? {
        cues.last { $0.offset(in: seconds) <= elapsed } ?? cues.first
    }
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

        func step(_ key: String, _ title: String, _ seconds: Int, _ cues: [(Double, String)]) -> PracticeStep {
            PracticeStep(
                id: "\(id.rawValue).\(key)",
                title: title,
                seconds: seconds,
                cues: cues.enumerated().map { index, cue in
                    PracticeCue(id: "\(id.rawValue).\(key).\(index)", text: cue.1, fraction: cue.0)
                }
            )
        }

        switch id {
        case .returnTraining:
            let settle = max(30, total / 10)
            return [
                step("arrive", "Arrive", settle, [
                    (0.0, "Sit upright but not stiff. Let the shoulders drop."),
                    (0.5, "Close the eyes, or let them rest unfocused on one spot on the floor.")
                ]),
                step("anchor", "Return", total - settle - 25, [
                    (0.0, anchor.instruction),
                    (0.08, "Your attention will leave. That isn't a mistake — it's the part we're training."),
                    (0.2, "When you notice it has gone, that noticing is the moment. Come back without commenting on it."),
                    (0.34, "A light touch is enough. You don't have to grip the anchor."),
                    (0.48, "If you've been away a long time, that's fine. Begin again from here."),
                    (0.62, "No need to judge how it's going. Notice, return."),
                    (0.76, "Each return counts. You aren't trying to stay — you're practising coming back."),
                    (0.9, "Still here or far away, it makes no difference. Return once more.")
                ]),
                step("close", "Close", 25, [
                    (0.0, "Let the anchor go."),
                    (0.4, "Notice how attention is now, without deciding whether it was a good session.")
                ])
            ]

        case .settleThenFocus:
            let settle = total * 2 / 5
            return [
                step("exhale", "Settle", settle, [
                    (0.0, "Let the breath out a little more slowly than usual. Don't push it — just let the out-breath be unhurried."),
                    (0.14, "At the end of the out-breath there's a small natural pause. Let it be there. Don't hold it."),
                    (0.32, "The in-breath looks after itself. You only have to let the exhale lengthen."),
                    (0.52, "If this starts to feel like effort, drop it and breathe normally for a while."),
                    (0.74, "Nothing to make happen here. The body settles on its own timing.")
                ]),
                step("anchor", "Focus", total - settle - 25, [
                    (0.0, "Now let the breath go back to whatever it wants to do."),
                    (0.12, anchor.instruction),
                    (0.3, "See whether attention rests more easily than it would have a few minutes ago."),
                    (0.52, "When it moves, come back. Nothing has gone wrong."),
                    (0.78, "Stay with it a little longer than feels necessary.")
                ]),
                step("close", "Close", 25, [
                    (0.0, "Let the anchor go."),
                    (0.4, "Notice the state of the body, separately from the state of attention.")
                ])
            ]

        case .energizeThenAttend:
            let rouse = max(45, total / 3)
            return [
                step("posture", "Wake up", rouse, [
                    (0.0, "Sit tall. Lift gently through the top of the head and let the spine lengthen."),
                    (0.16, "Keep the eyes open. Let the gaze rest a little above the horizon, soft rather than staring."),
                    (0.36, "Take one fuller breath in, and let it out easily. Just one."),
                    (0.58, "Feel the feet on the floor and the weight of the body on the seat."),
                    (0.8, "Brightness first. Stillness can come after.")
                ]),
                step("anchor", "Attend", total - rouse - 25, [
                    (0.0, "Keep the eyes open and the posture tall."),
                    (0.1, anchor.instruction),
                    (0.3, "If alertness starts to drop, sit taller and lift the gaze rather than trying harder."),
                    (0.55, "Dullness is not a failure of will. Change the conditions, not the effort."),
                    (0.8, "Stay awake with it as long as it's comfortable.")
                ]),
                step("close", "Close", 25, [
                    (0.0, "Let the anchor go."),
                    (0.35, "Are you more awake than when you started? Either answer is useful.")
                ])
            ]

        case .emotionalClearing:
            let label = total * 2 / 5
            return [
                step("label", "Name it", label, [
                    (0.0, "Notice what's actually present right now — not the story about it, the feeling itself."),
                    (0.18, "Name it once, plainly. “Worry.” “Irritation.” “Nothing much.” Then stop."),
                    (0.38, "You don't have to change it, justify it, or work out where it came from. Naming is enough."),
                    (0.58, "If it's strong, you can add: this is hard right now. That counts as friendliness toward yourself."),
                    (0.8, "Let it be there without arguing with it.")
                ]),
                step("anchor", "Rest", total - label - 25, [
                    (0.0, "Now let attention move to something steadier. The feeling can stay where it is."),
                    (0.1, anchor.instruction),
                    (0.3, "If it pulls attention back, name it once more and return. That's the whole practice."),
                    (0.55, "You aren't getting rid of anything. You're finding out whether attention can rest alongside it."),
                    (0.8, "Keep it simple. Notice, name if needed, return.")
                ]),
                step("close", "Close", 25, [
                    (0.0, "Let the anchor go."),
                    (0.35, "Has the pull loosened at all? If not, that's information, not failure.")
                ])
            ]

        case .sustainedFlow:
            let settle = max(45, total / 8)
            return [
                step("arrive", "Arrive", settle, [
                    (0.0, "Settle the posture. Let the breath find its own rhythm."),
                    (0.55, "There's no hurry into this one.")
                ]),
                step("anchor", "Stay", total - settle - 35, [
                    (0.0, anchor.instruction),
                    (0.1, "Let it hold your attention for longer than feels usual. There's nowhere else to be."),
                    (0.3, "Fewer reminders from here. The quiet is part of it."),
                    (0.55, "If attention has stayed, let it keep staying."),
                    (0.8, "If it left, return without making anything of it.")
                ]),
                step("close", "Close", 35, [
                    (0.0, "Begin to let the anchor go — slowly rather than all at once."),
                    (0.5, "Notice what's left of the steadiness as the practice ends.")
                ])
            ]

        case .baselineSettling:
            let settle = max(30, total / 6)
            return [
                step("arrive", "Arrive", settle, [
                    (0.0, "Sit comfortably. There's nothing to achieve here."),
                    (0.5, "We're still working out what suits you, so this one is deliberately plain.")
                ]),
                step("anchor", "Rest", total - settle - 25, [
                    (0.0, anchor.instruction),
                    (0.15, "When attention moves, bring it back. That's all."),
                    (0.45, "However this goes, it tells us something useful."),
                    (0.75, "Stay with it until the end if you can.")
                ]),
                step("close", "Close", 25, [
                    (0.0, "Let the anchor go."),
                    (0.4, "Notice how attention is now.")
                ])
            ]
        }
    }
}
