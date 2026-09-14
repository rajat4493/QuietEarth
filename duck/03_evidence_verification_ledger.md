# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | OPEN |
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

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
