# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | VERIFIED M1 — full questionnaire and persisted profile UI test |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | OPEN |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | IN PROGRESS M1 — questionnaire observations are separated; external evidence begins M2 |
| App can disagree with user safely | Competing interpretations section | Fixture test | IN PROGRESS M1 — contradictions remain visible and reduce confidence |
| No diagnostic language appears | Static copy scan + test fixtures | Automated string rules + manual review | VERIFIED M1 scope — only explicit non-diagnosis boundary copy appears |
| Recommendation explains itself | “Why this practice” card | UI test | OPEN |
| Session can be completed offline after plan is generated | Local audio/text/timer | Airplane-mode test | OPEN |
| Feedback changes later recommendation when thresholds met | Deterministic rule engine | Unit tests | OPEN |
| Delete/reset actually removes local profile/history | Storage test | Integration test | OPEN |
| Raw import does not silently upload source history | Network inspection | Manual verification | OPEN |
| Sanskrit references show provenance and caveat | Reference cards | Content review | OPEN |

## Milestone status
- **M0 complete:** app shell, design tokens, opening/explanation/privacy navigation, unit test, UI tests, and light/dark simulator evidence are recorded in `duck/evidence/M0/report.md`.
- **M1 complete:** adaptive questionnaire, explainable deterministic profile, contradictions/confidence, revision, resume, and local persistence are recorded in `duck/evidence/M1/report.md`.

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

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
