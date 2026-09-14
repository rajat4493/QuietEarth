# External AI Intake — Schema v2

> Schema v1 and numeric reconciliation are superseded by the M1.6 reset. This file records the only accepted external contract.

## Scope boundary
QuietEarth accepts a user-reviewed qualitative conversation summary created in ChatGPT, Claude, or another assistant. The app never contacts a provider, signs into an account, reads chat history, uploads text, diagnoses a condition, or recommends a meditation in this flow.

## Accepted JSON
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

Schema v1, unknown top-level fields, numeric inference fields/values, unsupported evidence labels, missing required evidence, oversized input, empty required text, and diagnostic language are rejected before preview or storage.

## Privacy and provenance
- The paste buffer exists only in view state until approval.
- The preview shows the normalized qualitative material exactly as it will be retained.
- Each stored evidence record carries provider/source, timestamp, category, strength label, statement, optional reason/counterpoint, and optional user-approved note.
- Evidence strength is never converted to a numeric weight.
- Removing the external record rebuilds the exact questionnaire-only profile.

## Reconciliation
The comparison is side by side, never mathematical:
- questionnaire-derived working interpretation;
- external self-report found in conversation;
- external behavioral observations and counterpoints;
- explicit differences supplied by the review;
- alternative explanations;
- limitations.

External evidence does not alter questionnaire dimension scores or confidence. If `differences_between_self_report_and_observation` is non-empty, the UI says the views differ and preserves both. If it is empty, the UI says the views add context without claiming measured agreement.

Free-form observations are not secretly classified into attention dimensions. Practice outcomes will later provide the stronger behavioral measurements needed to revise a hypothesis.

## Deterministic acceptance fixtures
1. valid qualitative schema v2 with an empty differences list;
2. explicit self-report/observation contradiction preserved as language;
3. schema v1 or numeric rating rejected;
4. malformed, incomplete, diagnostic, and unknown-strength output rejected;
5. deletion restores questionnaire-only dimensions and interpretation exactly.
