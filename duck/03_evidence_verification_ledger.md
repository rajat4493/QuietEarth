# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | VERIFIED M1 — full questionnaire and persisted profile UI test |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | VERIFIED M2 — copy/paste/preview/approve flow exercised |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | VERIFIED M2 — provider-aware source comparison and signal provenance |
| App can disagree with user safely | Competing interpretations section | Fixture test | VERIFIED M2 — disagreement remains visible and reduces confidence |
| No diagnostic language appears | Static copy scan + test fixtures | Automated string rules + manual review | VERIFIED M2 scope — unsafe inference fixture rejected; boundary copy retained |
| Recommendation explains itself | “Why this practice” card | UI test | OPEN |
| Session can be completed offline after plan is generated | Local audio/text/timer | Airplane-mode test | OPEN |
| Feedback changes later recommendation when thresholds met | Deterministic rule engine | Unit tests | OPEN |
| Delete/reset actually removes local profile/history | Storage test | Integration test | OPEN |
| Raw import does not silently upload source history | Network inspection | Manual verification | OPEN |
| Sanskrit references show provenance and caveat | Reference cards | Content review | OPEN |

## Milestone status
- **M0 complete:** app shell, design tokens, opening/explanation/privacy navigation, unit test, UI tests, and light/dark simulator evidence are recorded in `duck/evidence/M0/report.md`.
- **M1 complete:** adaptive questionnaire, explainable deterministic profile, contradictions/confidence, revision, resume, and local persistence are recorded in `duck/evidence/M1/report.md`.
- **M2 complete:** external AI schema intake, validation, normalized preview, provenance-aware reconciliation, alternatives, and reversible deletion are recorded in `duck/evidence/M2/report.md`.

## M1-specific verification
| Claim | Verification | Status |
|---|---|---|
| Questionnaire remains within 12–18 question scope | Unit test proves 12 core / 15 maximum | VERIFIED |
| Every score contribution is traceable to a question | Signal provenance fixtures + disclosure UI | VERIFIED |
| Contradictory answers lower confidence and remain visible | Comparative unit test + simulator evidence | VERIFIED |
| Fixed scattered, dull, and sustained personas remain stable | Expected-range unit tests | VERIFIED |
| Interrupted progress survives relaunch | UI test | VERIFIED |
| Completed profile survives relaunch | UI test | VERIFIED |
| Revised answers recalculate the profile | Persistence/domain integration test + revision UI | VERIFIED |
| M1 uses only on-device questionnaire evidence | Source/dependency inspection | VERIFIED |

## M2-specific verification
| Claim | Verification | Status |
|---|---|---|
| External result is normalized before storage | Parser tests + preview simulator evidence | VERIFIED |
| Malformed, incomplete, unsafe, and out-of-schema values fail closed | Deterministic parser fixtures + UI test | VERIFIED |
| Questionnaire and AI agreement is explicit | Agreement fixture | VERIFIED |
| Cross-source disagreement is preserved rather than flattened | Disagreement fixture + reconciliation screenshot | VERIFIED |
| Capacity versus gating case produces a richer interpretation | Dedicated fixture + manual simulator flow | VERIFIED |
| Removing AI evidence restores questionnaire-only result | Persistence integration test + manual simulator flow | VERIFIED |
| M1 stored evidence remains readable | Legacy decoding test | VERIFIED |
| M2 performs no provider API, upload, or account access | Source/dependency inspection | VERIFIED |

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
