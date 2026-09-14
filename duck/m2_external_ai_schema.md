# M2 External AI Schema, Privacy, and Reconciliation

## Scope boundary
M2 accepts a user-reviewed behavioral profile created in ChatGPT, Claude, or another assistant. The app never contacts an AI provider, signs into an account, reads chat history, or uploads text. Raw chat export, meditation recommendations, Sanskrit mapping, audio, analytics, cloud storage, and diagnosis remain out of scope.

## Provenance-aware evidence
Every new `ObservedSignal` carries:
- source: questionnaire, external AI with provider, or future practice outcome;
- confidence from `0...1`;
- timestamp;
- evidence category: self-report, behavioral observation, or future practice outcome;
- stable source/question identifier;
- short evidence summary;
- optional user-approved note.

Legacy M1 questionnaire evidence is decoded with questionnaire provenance, full confidence, answer timestamp where available, and self-report category.

## Accepted external JSON
The copied prompt asks for exactly these top-level fields:

```json
{
  "schema_version": 1,
  "self_report_summary": "...",
  "behavioral_summary": "...",
  "dimensions": [
    {
      "name": "attentional_switching",
      "score": 0.0,
      "confidence": 0.0,
      "evidence_summary": "...",
      "counter_evidence": "..."
    }
  ],
  "key_disagreements": ["..."],
  "alternative_interpretations": [
    {"label": "...", "confidence": 0.0, "reason": "..."}
  ],
  "overall_confidence": 0.0,
  "limitations": ["..."]
}
```

All ten M1 dimensions are required exactly once:
- `attentional_switching`
- `focus_persistence`
- `associative_branching`
- `disengagement_difficulty`
- `novelty_dependence`
- `emotional_capture`
- `energy_dullness`
- `low_stimulation_tolerance`
- `metacognitive_noticing`
- `sensory_orientation`

Unknown fields are ignored and never interpreted as instructions. Missing/duplicate/unknown dimensions, unsupported schema versions, out-of-range numbers, empty required text, oversized content, invalid JSON, and diagnostic/unsafe inference language are rejected before preview or storage.

## Data minimization
- The paste buffer is held in view state only.
- The user sees a normalized preview before approving it.
- On approval the app stores the decoded, normalized profile locally; it does not retain unrelated text outside the schema.
- Removing AI evidence deletes the normalized external record and deterministically rebuilds the questionnaire-only profile.

## Signal conversion
Each external dimension produces:
- one behavioral-observation signal with direction `(score × 2) - 1`;
- weight `1`;
- confidence equal to `dimension.confidence × overall_confidence`;
- evidence summary from the validated dimension;
- counter-evidence as an opposing signal when present, at quarter weight and the same bounded confidence. This lowers confidence and remains inspectable without flattening a strong primary observation into a misleading midpoint.

The provider selected by the user is provenance metadata, not a quality score.

## Reconciliation
Questionnaire and external AI scores are calculated independently before combination.
- difference ≤ `0.18`: agreement;
- difference > `0.18`: disagreement;
- evidence from only one source: single-source.

The combined dimension uses confidence-weighted signals. Cross-source disagreement remains visible, contributes an explicit contradiction, and reduces confidence through dispersion and the contradiction penalty. It is never represented only as an averaged middle score.

The comparison screen is titled **How the two views compare** and groups:
- You reported
- Your AI behavior profile suggests
- Our current interpretation
- Alternative interpretations

## Capacity/gating case
If questionnaire evidence reports weak persistence while external behavioral evidence shows strong persistence, and switching is also high, the interpretation becomes **Capacity present, gating appears variable**. It explains that sustained attention appears available when engagement is established while selection/continuity may vary. **Generalized weak concentration** remains visible as an alternative instead of replacing the conflicting evidence.

## Deterministic acceptance fixtures
1. strong cross-source agreement;
2. partial disagreement with explicit lower confidence;
3. malformed, unsafe, or incomplete external JSON rejected;
4. deletion rebuilds a profile exactly equal to questionnaire-only evidence;
5. “cannot focus”/high behavioral persistence plus high switching produces the capacity/gating interpretation without flattening.
