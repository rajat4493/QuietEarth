# TheDuck — Evidence & Verification Ledger

| Claim / Requirement | Evidence expected | Verification | Status at build start |
|---|---|---|---|
| User can complete onboarding without sharing chat history | Questionnaire-only path | UI test | VERIFIED M1 — full questionnaire and persisted profile UI test |
| User can use private AI analysis instead of raw history | Copy prompt → paste structured result | End-to-end test | SUPERSEDED at M1.6 — flow verified against schema v1; re-verification required against schema v2 |
| Profile separates self-report and inferred evidence | Profile screen + schema | Snapshot/UI test | SUPERSEDED at M1.6 — separation held, but the comparison compared fabricated scores; must compare statements |
| App can disagree with user safely | Competing interpretations section | Fixture test | SUPERSEDED at M1.6 — disagreement must be expressed as a contested hypothesis tested first, not as a score gap |
| No diagnostic language appears | Static copy scan + test fixtures | Automated string rules + manual review | SUPERSEDED at M1.6 — copy was clean, but the numeric request had the *form* of cognitive screening; scan extended to psychometric vocabulary |
| The product does not measure the user's mind | Prompt text + parser fixtures | No-numbers parser rule + prompt review | WRITTEN — prompt and parser implemented; tests not yet run |
| No trait-attached number is ever displayed | Copy/UI scan over all user-facing text | Source scan for percent/gauge/score formatting | WRITTEN — scan is clean apart from the questionnaire step counter, which counts answered questions |
| Every profile claim carries a way it could be wrong | Hypothesis records with predictions and disconfirmations | Fixture test | WRITTEN — `hypothesesAreFalsifiable` covers it; not yet run |
| Brightened palette keeps contrast and accessibility compliance | Re-skinned M0/M1 screens | Contrast, Dynamic Type, VoiceOver, 44pt, Reduce Motion re-check | OPEN — requires a device or simulator |
| Recommendation explains itself | “Why this practice” card | UI test | OPEN |
| Session can be completed offline after plan is generated | Local audio/text/timer | Airplane-mode test | OPEN |
| Feedback changes later recommendation when thresholds met | Deterministic rule engine | Unit tests | OPEN |
| Delete/reset actually removes local profile/history | Storage test | Integration test | OPEN |
| Raw import does not silently upload source history | Network inspection | Manual verification | OPEN |
| Sanskrit references show provenance and caveat | Reference cards | Content review | OPEN |

## Milestone status
- **M0 complete:** app shell, design tokens, opening/explanation/privacy navigation, unit test, UI tests, and light/dark simulator evidence are recorded in `duck/evidence/M0/report.md`.
- **M1 complete:** adaptive questionnaire, explainable deterministic profile, contradictions/confidence, revision, resume, and local persistence are recorded in `duck/evidence/M1/report.md`.
- **M1.6 written, NOT VERIFIED:** the inference reset and visual reset are specified in `duck/m1_6_inference_and_visual_reset.md`, carried through the product docs, and implemented in the app (schema-v2 parser, observation filing, hypothesis engine, number-free profile UI, Sunlit QuietEarth). **No build or test run exists:** the work was done in a Linux container with no Swift toolchain, so nothing has been compiled and no simulator evidence was captured. Per TheDuck, that makes the milestone incomplete, not complete.
- **M2 REWORKED INTO M1.6, pending verification:** the first M2 build (recorded in `duck/evidence/M2/report.md`) was completed against the superseded schema-v1 scoring prompt. Its build, tests, and simulator evidence were genuine at the time and are retained as history. Its numeric AI-derived scoring is now removed in code; the rows below return to VERIFIED only once the suite runs green again.

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

## M2-specific verification (re-baselined at M1.6)
Verified against schema v1. Rows marked SUPERSEDED were true of the v1 build and must be re-verified
against schema v2; rows marked VERIFIED are independent of the schema change and carry forward.

| Claim | Verification | Status |
|---|---|---|
| External result is normalized before storage | Parser tests + preview simulator evidence | WRITTEN — v2 parser and preview implemented; not yet run |
| Malformed, incomplete, unsafe, and out-of-schema values fail closed | Deterministic parser fixtures + UI test | WRITTEN — v2 rules, no-numbers rule and psychometric vocabulary covered by fixtures; not yet run |
| Questionnaire and AI agreement is explicit | Converging-hypothesis fixture | WRITTEN — `converging`; not yet run |
| Cross-source disagreement is preserved rather than flattened | Contested-hypothesis fixture | WRITTEN — `contested`, tested first by construction; not yet run |
| Capacity versus gating case produces a richer interpretation | Dedicated fixture | WRITTEN — `capacityAndGating`, now qualitative with a stated disconfirmation; not yet run |
| Removing AI evidence restores questionnaire-only result | Persistence integration test | WRITTEN — `deletionReversion` extended to observations and hypotheses; not yet run |
| M1 stored evidence remains readable | Legacy decoding test | WRITTEN — signal and profile decode paths retained; not yet run |
| Stored schema-v1 external records are deleted, not migrated | Migration fixture | WRITTEN — `supersededRecordsDiscarded`; not yet run |
| M2 performs no provider API, upload, or account access | Source/dependency inspection | VERIFIED — no networking client exists in the target |

## M1.6-specific verification
| Claim | Verification | Status |
|---|---|---|
| The external prompt asks for no scores, ratings, or assessment | Prompt review against `product/ASK_YOUR_AI_PROMPT.md` | VERIFIED — documentation |
| No AI-derived numeric cognitive scoring survives in the specification | Full doc grep for score/confidence decimals in AI-derived evidence | VERIFIED — documentation |
| Questionnaire scoring stays internal and is not presented as measurement | Numbers policy in the M1.6 document and `product/CONTENT_AND_SAFETY.md` | VERIFIED — documentation |
| Every hypothesis carries a prediction and a disconfirmation | Hypothesis templates in the M1.6 document | VERIFIED — documentation |
| Visual direction is specified concretely enough to build | Palette tokens, layout, motif, motion, and forbidden list | VERIFIED — documentation |
| The specification is implemented | Code | WRITTEN — see the implemented-surface table in the M1.6 document |
| The implementation compiles and its tests pass | `xcodebuild … test` | OPEN — no Swift toolchain in the build environment used |
| Simulator evidence recaptured under the new visual direction | Screenshots, light and dark | OPEN — requires a simulator |

## Required evidence artifacts per milestone
- test output
- screenshots or simulator recording
- known issues
- privacy/data-flow note if data handling changes
- updated ledger status
