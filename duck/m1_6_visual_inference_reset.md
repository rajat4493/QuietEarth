# M1.6 — Visual and Inference Reset

## Why this milestone exists
M0/M1 proved the shell and deterministic questionnaire, but the first M2 implementation exposed two wrong turns: the interface felt like a beige wellness template, and external AI observations were converted into cognitive-looking numbers. M1.6 corrects both foundations before recommendation work.

The previous M2 schema v1 and its score-reconciliation rules are superseded by this document. They are not retained as a compatibility mode.

## Visual reset: Sunlit Calm
QuietEarth should feel clear, alive, humane, and distinctly iOS-native — not solemn, monastic, clinical, or generically “wellness.” The reference is the energy of Gentler Streak, translated into QuietEarth’s own identity rather than copied.

### Direction
- sunlit ivory background, not beige or parchment;
- deep spruce for readable text and primary actions;
- sea-glass and mint for freshness and spacious secondary surfaces;
- muted coral/tangerine for warmth and meaningful contrast;
- occasional sunlight yellow for optimism and focal moments;
- clean, near-white cards with light outlines instead of heavy tinted panels;
- one strong organic attention-path visual on the opening screen;
- subtle, playful motion that respects Reduce Motion;
- familiar platform navigation, with brand color and illustration in content.

### Avoid
- spa, ashram, therapy-clinic, or mystical visual codes;
- muddy beige-on-beige palettes;
- generic AI gradients, sparkles, neural networks, or chat-first UI;
- decorative color that competes with evidence or validation states;
- dense dashboards and faux measurement graphics.

## Inference reset: describe, do not score
An external AI is allowed to summarize observable conversational behavior. It is not allowed to assign numeric cognitive scores, probabilities, psychometric ratings, diagnoses, or a “mind type.”

External evidence remains qualitative throughout storage, reconciliation, and presentation. QuietEarth must not convert an observation or evidence-strength label into a hidden number. Questionnaire scoring remains a private deterministic implementation detail, but the product UI expresses questionnaire results as qualitative bands and evidence strength rather than percentages.

## Unified evidence boundary
The shared evidence boundary is a qualitative evidence record:
- source and provider provenance;
- timestamp;
- evidence category;
- statement/pattern;
- evidence strength: strong, moderate, weak, or insufficient;
- optional reason and counterpoint;
- optional user-approved note.

Questionnaire answers may produce internal weighted signals before being summarized into qualitative evidence records. External AI observations enter directly as qualitative evidence records. A future practice outcome will enter as a measured behavioral evidence record. Only explicitly measured product behavior may introduce a quantitative metric later.

## External AI schema v2
```json
{
  "schema_version": 2,
  "self_report": [
    {"statement": "...", "evidence_strength": "strong|moderate|weak|insufficient"}
  ],
  "observations": [
    {
      "pattern": "...",
      "evidence_strength": "strong|moderate|weak|insufficient",
      "reason": "...",
      "counterpoint": "..."
    }
  ],
  "differences_between_self_report_and_observation": ["..."],
  "alternative_explanations": ["..."],
  "limitations": ["..."]
}
```

Schema v1 is rejected. Numeric score/confidence fields are rejected even if schema v2 is claimed. Empty collections, missing required text, unknown evidence strengths, diagnostic language, oversized input, and malformed JSON are rejected before preview or storage.

## Reconciliation rules
Reconciliation is a comparison of claims, not arithmetic.

1. Show the questionnaire-derived working interpretation in qualitative language.
2. Show AI self-report and behavioral observations separately, with their supplied evidence strength and counterpoint.
3. Preserve the AI-returned differences and alternatives verbatim after validation.
4. If differences exist, state that the views differ and keep both explanations visible. Do not average them into a middle value.
5. External observations do not mutate questionnaire dimension scores or confidence.
6. Removing AI evidence restores the exact questionnaire-only profile and removes the comparison material.

## Working hypothesis rules
1. A hypothesis is a claim to test, never a diagnosis or settled identity.
2. Every hypothesis carries a visible basis, counterpoint, prediction, and disconfirmation condition.
3. Explicit differences between self-report and observation are contested hypotheses and sort first.
4. Questionnaire interpretations and external observations remain separate hypotheses with source labels.
5. External evidence strength remains the ordinal label supplied in schema v2; it is never converted to a hidden number.

Because free-form observations do not carry a trustworthy machine-readable dimension, M1.6 deliberately does not pretend to semantically classify them. The user sees an honest side-by-side view. Future practice results provide the stronger behavioral measurement needed to update a hypothesis.

## Scope boundary
Still excluded: provider APIs, direct account access, chat export/upload, diagnosis, meditation recommendation, Sanskrit mapping, audio, backend, analytics, and practice scoring.

## Acceptance checks
- schema v2 qualitative fixture previews and persists locally;
- schema v1 and any numeric inference payload are rejected;
- malformed, incomplete, unsafe, and unknown-strength inputs are rejected;
- disagreements, counterpoints, alternatives, and limitations remain visible;
- deleting AI evidence restores the questionnaire-only profile exactly;
- profile UI exposes no percentages or psychometric-style progress bars;
- light/dark and Reduce Motion screenshots demonstrate the Sunlit Calm system.

Status: **verified complete**. Evidence is in `duck/evidence/M1.6/report.md`.
