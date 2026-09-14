# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | IN PROGRESS — M0 reaches privacy choice; questionnaire is M1 |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | OPEN |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | OPEN |
| App can disagree with user safely | Competing interpretations section | Fixture test | OPEN |
| No diagnostic language appears | Static copy scan + test fixtures | Automated string rules + manual review | OPEN |
| Recommendation explains itself | “Why this practice” card | UI test | OPEN |
| Session can be completed offline after plan is generated | Local audio/text/timer | Airplane-mode test | OPEN |
| Feedback changes later recommendation when thresholds met | Deterministic rule engine | Unit tests | OPEN |
| Delete/reset actually removes local profile/history | Storage test | Integration test | OPEN |
| Raw import does not silently upload source history | Network inspection | Manual verification | OPEN |
| Sanskrit references show provenance and caveat | Reference cards | Content review | OPEN |

## Milestone status
- **M0 complete:** app shell, design tokens, opening/explanation/privacy navigation, unit test, UI tests, and light/dark simulator evidence are recorded in `duck/evidence/M0/report.md`.
- No end-to-end product claim above is marked verified yet; M0 establishes the tested boundary required to implement those flows.

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
