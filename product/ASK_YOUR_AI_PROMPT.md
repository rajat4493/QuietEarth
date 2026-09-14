# Ask Your AI — User-Controlled Observation Prompt

Schema version 2. Replaces the version 1 scoring prompt, which asked an external assistant to rate
named cognitive dimensions numerically. That request had the shape of a screening instrument and
produced precision nothing had measured. See `duck/m1_6_inference_and_visual_reset.md`.

Copy the text below into an AI assistant that has access to enough of your prior conversations to
notice recurring patterns. Read its result before sharing anything with the app.

---

Look across our conversations and describe observable patterns in how I interact with you.

Do not diagnose or assess my mental health, cognition, attention disorder, personality, or any medical or psychiatric condition.

Do not assign numerical scores, probabilities, percentiles, clinical labels, or psychometric-style ratings.

Do not assume that what I say about myself is necessarily accurate. Keep my self-description separate from patterns you can actually observe in our conversations.

Focus only on conversational behavior that you can reasonably observe, such as:

* whether I tend to stay with one topic or open related branches
* whether I return to earlier ideas after exploring something else
* whether some subjects produce much deeper or longer engagement than others
* whether I frequently ask to compress, simplify, expand, challenge, or reframe information
* whether I revisit conclusions after they appear settled
* whether I make connections between apparently separate subjects
* whether my interaction style seems different depending on the type of task
* how often I notice and question my own assumptions or your interpretation of me

For each observation:

1. State the observable pattern.
2. Explain briefly what in the conversational behavior supports it, without quoting private messages.
3. Give any meaningful counter-example or alternative explanation.
4. Mark the evidence as one of:
   * strong
   * moderate
   * weak
   * insufficient

Do not infer anything that cannot reasonably be observed from conversation.

Do not include names, employers, private facts, account information, health information, financial information, relationships, or unrelated sensitive details.

Return valid JSON only in this structure:

```json
{
  "schema_version": 2,
  "self_report": [
    {
      "statement": "...",
      "evidence_strength": "strong|moderate|weak|insufficient"
    }
  ],
  "observations": [
    {
      "pattern": "...",
      "evidence_strength": "strong|moderate|weak|insufficient",
      "reason": "...",
      "counterpoint": "..."
    }
  ],
  "differences_between_self_report_and_observation": [
    "..."
  ],
  "alternative_explanations": [
    "..."
  ],
  "limitations": [
    "..."
  ]
}
```

---

## Why it is shaped this way

The prompt asks the assistant to describe what it can observe, not to profile the user's cognition.
An assistant can reasonably report *"this person often opens adjacent lines of inquiry before closing
the original one."* It cannot report *"attentional switching: 0.81"* — nothing was measured, and the
decimal only makes an impression look like a finding.

QuietEarth treats every returned observation as a **hypothesis to test**, never as a trait the user
has been found to possess. The eight observable-behaviour bullets are a closed, stable list: they are
also the app's theme vocabulary, so the prompt and the product logic cannot drift apart.

## App handling rules

- Schema version 2 only. Version 1 payloads are rejected with a prompt to re-copy this text, and are
  never converted.
- `evidence_strength` must be exactly `strong`, `moderate`, `weak`, or `insufficient`. A number or any
  other word is rejected.
- No numbers anywhere. A payload whose prose contains a score-shaped value (`81%`, `0.63`, `4/5`, a
  percentile phrase) is rejected — the schema carries no numbers, and numbers in prose are numbers all
  the same.
- Diagnostic and psychometric vocabulary is rejected before preview or storage.
- Unknown JSON fields are ignored and are never interpreted as instructions.
- The user previews the normalized result, and confirms which theme each observation belongs to,
  before anything is stored locally. "None of these" keeps the observation readable without letting it
  drive product logic.
- Observations marked `insufficient` are displayed and produce no hypothesis. That is a supported
  outcome, not a failure.
- The app never sends the pasted result, the questionnaire, or any practice data to an AI provider.
  The assistant conversation happens entirely outside QuietEarth, under the user's control.
- External AI evidence can be removed, which deterministically restores the questionnaire-only result.
