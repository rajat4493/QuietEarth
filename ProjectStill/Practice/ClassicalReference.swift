import Foundation

/// Provenance for the "Where this comes from" layer.
///
/// The Sanskrit and the sutra numbering are ancient and unencumbered. English
/// translations are modern authored works and are not reproduced here: every
/// `gloss` below is our own plain-English rendering, labelled as such, with a
/// public-domain edition named so a reader can check us against a scholarly
/// source.
struct ClassicalReference: Codable, Hashable, Identifiable {
    let id: String
    /// e.g. "Yoga Sūtra 1.34"
    let citation: String
    let transliteration: String
    /// Our paraphrase. Never presented as a translation.
    let gloss: String
    /// Why this is one option among several — the anti-dogma note.
    let context: String
    let modernParallel: String
    let caveat: String
    let publicDomainSource: String

    static let defaultCaveat = "This is an interpretive parallel, not a medical claim and not evidence that this practice suits you. That is what the week is for."
    static let defaultSource = "Compare Charles Johnston's 1912 translation, or Ganganatha Jha's of 1907 — both in the public domain."
}

extension ClassicalReference {
    static func reference(for template: PracticeTemplateID) -> ClassicalReference? {
        switch template {
        case .returnTraining:
            ClassicalReference(
                id: "ys.1.35",
                citation: "Yoga Sūtra 1.35",
                transliteration: "viṣayavatī vā pravṛttir utpannā manasaḥ sthiti-nibandhanī",
                gloss: "Or steadiness comes when attention settles on something the senses can actually meet.",
                context: "Patañjali offers this as one of several alternatives. Each is introduced with vā — “or”. The list ends at 1.39 with “or by meditating on whatever suits you.”",
                modernParallel: "Contemporary research calls this focused attention: hold one object, notice when attention leaves, bring it back. The noticing and returning is the trained part, not the staying.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        case .settleThenFocus:
            ClassicalReference(
                id: "ys.1.34",
                citation: "Yoga Sūtra 1.34",
                transliteration: "pracchardana-vidhāraṇābhyāṃ vā prāṇasya",
                gloss: "Or the mind quietens through an unhurried out-breath and the small pause that follows it.",
                context: "One option among several. 1.31 notes that a scattered mind often comes with an unsettled body and uneven breathing — so the body is addressed first here, not the attention.",
                modernParallel: "Slow exhalation is the part of the breath associated with settling the body's arousal. Asking an unsettled system to concentrate tends to fail for reasons that have nothing to do with attention.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        case .energizeThenAttend:
            ClassicalReference(
                id: "ys.1.36",
                citation: "Yoga Sūtra 1.36 (with 1.30)",
                transliteration: "viśokā vā jyotiṣmatī · styāna, ālasya",
                gloss: "Or by attending to what is bright and untroubled. 1.30 names heaviness of mind (styāna) and bodily inertia (ālasya) among the things that get in the way.",
                context: "The tradition treats dullness as a distinct obstacle from distraction, needing a different answer. Sitting still and quiet is the wrong medicine for a mind that is already sinking.",
                modernParallel: "Low alertness and busy attention look similar from outside — both feel like “I can't meditate” — but they respond to opposite conditions. Posture and open eyes raise arousal before stillness is asked for.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        case .emotionalClearing:
            ClassicalReference(
                id: "ys.1.33",
                citation: "Yoga Sūtra 1.33",
                transliteration: "maitrī-karuṇā-muditā-upekṣāṇāṃ … bhāvanātaś citta-prasādanam",
                gloss: "Or the mind clears by cultivating friendliness, compassion, gladness and even-mindedness — including toward yourself.",
                context: "1.31 lists daurmanasya, low or despondent mood, among what accompanies a scattered mind. This remedy addresses the mood rather than fighting the distraction it causes.",
                modernParallel: "Compassion and loving-kindness practices are treated as their own family in current research, distinct from concentration practice. Naming a feeling plainly is a well-described way of loosening its grip.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        case .sustainedFlow:
            ClassicalReference(
                id: "ys.3.1",
                citation: "Yoga Sūtra 3.1–3.2",
                transliteration: "deśa-bandhaś cittasya dhāraṇā · tatra pratyaya-ekatānatā dhyānam",
                gloss: "Holding attention in one place is dhāraṇā. When that holding becomes unbroken, it is called dhyāna.",
                context: "The tradition distinguishes these carefully. This practice works at the first of them. Nothing here is a claim about the later stages, and the distinction matters more than the words.",
                modernParallel: "Longer uninterrupted focus on one object, for attention that already tends to stay once it settles.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        case .baselineSettling:
            ClassicalReference(
                id: "ys.1.39",
                citation: "Yoga Sūtra 1.39",
                transliteration: "yathābhimata-dhyānād vā",
                gloss: "Or simply by attending to whatever suits you.",
                context: "The last line of Patañjali's list of alternatives, and the reason this app exists. Having given several methods, he declines to insist on any of them.",
                modernParallel: "When there isn't enough evidence to suggest something specific, a neutral practice and more evidence beats a confident guess.",
                caveat: defaultCaveat,
                publicDomainSource: defaultSource
            )
        }
    }

    /// Shown once, on the provenance layer, so the framing is never left implicit.
    static let frameNote = "QuietEarth's structure comes from this part of the text. Sūtras 1.30–1.39 name what gets in the way, offer several different remedies rather than one, and end by saying to use whatever suits the practitioner. Sanskrit terms describe conditions that come and go — they are never labels for a person."
}
