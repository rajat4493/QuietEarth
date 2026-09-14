# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | VERIFIED M1 — full questionnaire and persisted profile UI test |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | VERIFIED M2 — copy/paste/preview/approve flow exercised |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | VERIFIED M1.6 — source-specific qualitative evidence and provenance |
| App can disagree with user safely | Working hypotheses + comparison | Fixture/UI test | VERIFIED M1.6 — disagreement is promoted first and never averaged into a score |
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
- **M2 superseded by M1.6:** intake and deletion remain, while numeric external scoring/reconciliation was removed. The verified qualitative model is recorded in `duck/evidence/M1.6/report.md`.

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

## M1.6-specific verification
| Claim | Verification | Status |
|---|---|---|
| Schema v2 qualitative result is normalized before storage | Parser tests + preview flow | VERIFIED |
| Schema v1, numeric, malformed, incomplete, unsafe, and unknown-strength values fail closed | Deterministic parser fixtures + UI test | VERIFIED |
| Cross-source disagreement remains explicit | Hypothesis fixture + seeded UI test | VERIFIED |
| External evidence never mutates questionnaire dimensions | Hypothesis unit test | VERIFIED |
| Hypotheses expose basis, counterpoint, prediction, and disconfirmation | Unit tests + profile UI | VERIFIED |
| Removing AI evidence restores questionnaire-only result | Persistence integration test | VERIFIED |
| Profile UI contains no percentages | Seeded UI regression | VERIFIED |
| Build, 20 unit tests, and 6 UI tests pass | Xcode build/test runs | VERIFIED |
| Light, dark, and Reduce Motion visual evidence exists | Simulator screenshots | VERIFIED |
| No provider API, upload, account access, recommendation, or diagnosis exists | Source/dependency inspection | VERIFIED |

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
