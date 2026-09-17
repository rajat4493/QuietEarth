# TheDuck — Evidence & Verification Ledger

## Current correction
Visual design is **UNAPPROVED**; prior completion claims describe implementation checks, not user acceptance. M3 now includes a local user-perspective note and persistent appearance controls. See `duck/m3_profile_review.md` for storage, limitations, and verification.

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | VERIFIED M1 — full questionnaire and persisted profile UI test |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | VERIFIED M2 — copy/paste/preview/approve flow exercised |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | VERIFIED M1.6 — source-specific qualitative evidence and provenance |
| App can disagree with user safely | Working hypotheses + comparison | Fixture/UI test | VERIFIED M1.6 — disagreement is promoted first and never averaged into a score |
| No diagnostic language appears | Static copy scan + test fixtures | Automated string rules + manual review | VERIFIED M2 scope — unsafe inference fixture rejected; boundary copy retained |
| Recommendation explains itself | “Why this practice” card | UI test | WRITTEN M4 — deterministic rules with evidence-statement rationale; not yet run |
| Session can be completed offline after plan is generated | Local text/timer/haptics | Airplane-mode test | WRITTEN M5 — no network path exists in the target; airplane-mode check outstanding |
| Feedback changes later recommendation when thresholds met | Deterministic rule engine | Unit tests | WRITTEN M6 — four-session floor and six day-seven branches covered; not yet run |
| Delete/reset actually removes local profile/history | Storage test | Integration test | WRITTEN M7 — clears every store plus the three UserDefaults keys; not yet run |
| Raw import does not silently upload source history | Network inspection | Manual verification | OUT OF SCOPE — experimental import deliberately not built; see `duck/m4_m7_core_loop.md` |
| Sanskrit references show provenance and caveat | Reference cards | Content review | WRITTEN — `ClassicalReference` carries citation, transliteration, our own gloss, one-of-several context, modern parallel and caveat; a public-domain edition is named for checking. No modern translation is reproduced. Not yet run or reviewed by a Sanskritist. |

## Milestone status
- **M0 complete:** app shell, design tokens, opening/explanation/privacy navigation, unit test, UI tests, and light/dark simulator evidence are recorded in `duck/evidence/M0/report.md`.
- **M1 complete:** adaptive questionnaire, explainable deterministic profile, contradictions/confidence, revision, resume, and local persistence are recorded in `duck/evidence/M1/report.md`.
- **M4–M7 written, NOT VERIFIED:** the recommendation engine, session, reflection, seven-day experiment, day-seven adaptation, home screen, and global reset are implemented and specified in `duck/m4_m7_core_loop.md`. No build or test run exists — the work was done in a Linux container with no Swift toolchain. Incomplete until the suite runs green and simulator evidence is captured.
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

## M4–M7-specific verification
| Claim | Verification | Status |
|---|---|---|
| Practice choice is deterministic and ordered | Rule-by-rule unit tests incl. precedence | WRITTEN |
| The rationale contains no trait-attached number | Assertion over rationale strings | WRITTEN |
| Session steps always sum to the chosen length | Exhaustive template × length × anchor test | WRITTEN |
| Ending early is recorded rather than discarded | Persistence test on a partial session | WRITTEN |
| A hypothesis cannot change on fewer than four sessions | Day-seven floor test | WRITTEN |
| Each day-seven branch is reachable and distinct | Six fixture tests | WRITTEN |
| "Not enough to say" is a supported verdict | `predictionHeld == nil` path | WRITTEN |
| Global reset clears SwiftData and UserDefaults alike | Reset test over all stores and keys | WRITTEN |
| No percentage appears anywhere in the loop | UI sweep over on-screen text | WRITTEN |
| The loop runs end to end in the simulator | UI test: start → session → reflect → day seven | WRITTEN — not yet run |
| Offline claim holds in airplane mode | Manual device check | OPEN |
| Accessibility on the new screens | Dynamic Type, VoiceOver, 44pt, Reduce Motion | OPEN |
