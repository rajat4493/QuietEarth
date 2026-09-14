# M1 Evidence — Questionnaire, Explainable Profile, Local Persistence

## Definition of done
A user completes the questionnaire, receives a provisional attention profile with visible evidence and uncertainty, closes the app, reopens it, and sees the same result preserved.

Status: **complete**.

## Delivered
- A 12-question core intake with up to three conditional follow-ups (12–15 questions total).
- One question per screen with situational, non-clinical language.
- Explicit domain pipeline: `QuestionAnswer → ObservedSignal → ProfileDimension → ProfileInterpretation`.
- Ten dimensions: the nine MVP dimensions plus sensory orientation.
- Deterministic weighted scoring with per-question evidence provenance.
- Confidence derived from evidence coverage and agreement.
- Visible contradiction detection with a confidence penalty; conflicting signals remain in the profile.
- Plain-language provisional interpretations with displayed reasons and insufficient-evidence handling.
- SwiftData persistence for answers, progress, completion, and encoded profile.
- Interrupted questionnaires resume at the saved question.
- Completed profiles appear on relaunch without recalculation or network access.
- Answer-review and revision UI; revisions deterministically regenerate the profile.
- Ask-your-AI and raw-import choices remain disabled and clearly marked for M2/M7.

## Psychological model decisions
- Added **sensory orientation** to the nine dimensions in the PRD because M1 explicitly calls for distinguishing sensory from verbal/conceptual routes back to attention.
- Resolved the ambiguous energy dimension: a higher **energy/dullness** score always means a stronger dullness or low-energy tendency.
- Questionnaire evidence is treated as observation generated from selected situational statements, not as validated diagnosis or ground truth.
- A provisional interpretation is downstream of dimensions and never changes the underlying evidence.
- Full assumptions, thresholds, and confidence rules are recorded in `duck/m1_scoring_model.md`.

## Build and automated verification
Environment:
- Xcode 26.6 (build 17F113)
- Swift 6.3.3 toolchain, Swift 6 language mode
- iPhone 16 Pro simulator, iOS 18.1

Command:
```sh
xcodebuild -project ProjectStill.xcodeproj -scheme ProjectStill -sdk iphonesimulator -destination 'platform=iOS Simulator,id=51DA5274-448A-4988-A3FF-C4A970727791' -derivedDataPath .build/DerivedData test
```

Result: `TEST SUCCEEDED` — 12 passed, 0 failed, 0 skipped.

Coverage includes:
- scattered/exploratory fixed persona and expected dimension ranges;
- low-energy/dull fixed persona and expected range/confidence;
- highly sustained/one-pointed fixed persona and expected ranges;
- contradiction visibility and confidence reduction;
- adaptive 12–15 question boundary;
- answer revision and deterministic recalculation;
- model-context persistence round trip;
- interrupted questionnaire relaunch/resume;
- completed profile relaunch/preservation;
- both original M0 navigation paths.

Result bundle (local derived data, not versioned):
`.build/DerivedData/Logs/Test/Test-ProjectStill-2026.09.14_15-10-20-+0200.xcresult`

## Visual evidence
- `questionnaire.png`: resumed questionnaire at question 2.
- `profile.png`: completed mixed/context-dependent profile with dimension scores and confidence.
- `profile-contradiction.png`: expanded switching dimension showing both conflicting observations and the lower-confidence explanation.

The flow was also exercised manually in Simulator through completion. The sample profile shows switching evidence in opposite directions, retains both statements, and reduces that dimension to 29% confidence.

## Privacy and data flow
- No LLM or API call exists in M1.
- No ChatGPT/Claude or raw-history import is implemented.
- No URL session, networking framework, analytics SDK, account, or third-party dependency is present.
- Questionnaire answers, progress, and profile payload remain in the app's local SwiftData store.
- The questionnaire and completed profile remain functional across relaunch without network access.

## Known limitations
- The questionnaire and scoring weights are transparent product hypotheses, not a psychometrically validated instrument.
- Adaptive behavior is intentionally limited to three follow-ups; it is not a general branching survey engine.
- Confidence measures internal questionnaire coverage/agreement, not scientific certainty or predictive validity.
- A revision that newly activates a follow-up exposes it as unanswered in answer review, but does not force the user back through that follow-up before showing the recalculated profile.
- Persistence schema migration and explicit storage-error UI are not yet implemented.
- User-facing delete/reset remains deferred to M7, although UI tests use an internal launch-only reset path.
- Full localization, VoiceOver traversal audit, and largest Dynamic Type screenshots remain later polish work.
- Xcode emits non-blocking LLDB version-store messages during UI-test launch; all builds and tests succeed.

