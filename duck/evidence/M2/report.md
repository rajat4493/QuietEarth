# M2 Evidence — External AI Persona Intake and Reconciliation

## Definition of done
A user can copy the supplied behavioral-analysis prompt into ChatGPT, Claude, or another assistant; paste the user-reviewed structured result; preview the normalized evidence; and see where it agrees or conflicts with questionnaire evidence. The external evidence can be removed to restore the questionnaire-only profile.

Status: **superseded at M1.6 — milestone reopened.**

> This report is an accurate record of the schema-v1 build: those tests really passed and that flow
> really worked. It is retained as history. The milestone is no longer complete, because the method it
> implemented was withdrawn at M1.6: external models must return qualitative observable conversational
> patterns with ordinal evidence strength and no numeric cognitive scoring, and the UI moves to Sunlit
> QuietEarth. See `duck/m1_6_inference_and_visual_reset.md`. Re-verification is tracked in
> `duck/03_evidence_verification_ledger.md`.

## Delivered
- “Ask your AI” onboarding route and “Use your AI for another view” profile route.
- ChatGPT, Claude, and Other provider provenance selection.
- Copyable schema-versioned behavioral-analysis prompt.
- Local JSON editor and explicit paste action.
- Strict schema decoding and semantic validation before preview.
- Rejection for malformed JSON, unsupported version, missing/duplicate/unknown dimensions, out-of-range values, missing/oversized text, oversized payload, and enumerated diagnostic inference language.
- Normalized preview showing exactly what will be stored.
- User approval boundary plus optional approved note.
- Provider-aware external observations converted into the shared `ObservedSignal` pipeline.
- Independent questionnaire/external scores before confidence-weighted reconciliation.
- “How the two views compare” screen with source-specific summaries, per-dimension agreement/disagreement, current interpretation, and alternatives.
- Explicit capacity/gating interpretation for weak self-reported persistence plus high observed persistence and high switching.
- Local SwiftData storage of normalized external evidence.
- Removal flow that deletes the external record and deterministically rebuilds the questionnaire-only profile.
- Backward decoding for M1 questionnaire signals.

## Schema and reconciliation
The full accepted schema, provenance model, thresholds, safety checks, privacy rules, counter-evidence weighting, and capacity/gating case are recorded in `duck/m2_external_ai_schema.md`.

During visual QA, a realistic counter-evidence fixture showed that half-weight opposing evidence could flatten a declared 91% persistence observation toward the midpoint. Counter-evidence was changed to quarter weight: it remains visible and reduces confidence without erasing the primary behavioral observation.

## Build and automated verification
Environment:
- Xcode 26.6 (build 17F113)
- Swift 6.3.3 toolchain, Swift 6 language mode
- iPhone 16 Pro simulator, iOS 18.1

Command:
```sh
xcodebuild -project ProjectStill.xcodeproj -scheme ProjectStill -sdk iphonesimulator -destination 'platform=iOS Simulator,id=51DA5274-448A-4988-A3FF-C4A970727791' -derivedDataPath .build/DerivedData test
```

Result: `TEST SUCCEEDED` — 21 passed, 0 failed, 0 skipped.

M2 coverage includes:
- complete valid schema plus inert unknown field;
- malformed and incomplete payload rejection;
- diagnostic inference rejection;
- strong cross-source agreement;
- partial disagreement, retained contradiction, and reduced confidence;
- capacity/gating case with generalized weak concentration retained as an alternative;
- external-evidence deletion and exact questionnaire-only dimension/interpretation restoration;
- legacy M1 signal decoding;
- malformed-input UI rejection;
- all M0/M1 regression tests.

Result bundle (local derived data, not versioned):
`.build/DerivedData/Logs/Test/Test-ProjectStill-2026.09.14_16-46-39-+0200.xcresult`

## Manual simulator evidence
- `intake.png`: provider selection, prompt, and local paste UI.
- `normalized-preview.png`: schema-validated, normalized user-approval preview.
- `reconciliation.png`: source-specific comparison headed “How the two views compare.”
- `capacity-gating-fixture.json`: deterministic realistic acceptance fixture used in the manual flow.

The fixture produced:
- questionnaire focus persistence: 14%;
- external behavioral persistence: 75%;
- high switching agreement across sources;
- current interpretation: “Capacity present, gating appears variable”;
- “Generalized weak concentration” retained as an alternative.

Removal was exercised in Simulator. The comparison route disappeared and the original questionnaire-only “Exploratory or intermittently focused” profile returned.

Visual QA also found a blank-preview presentation race caused by Boolean sheet state updating before its payload. The preview now uses item-backed sheet presentation and was recaptured successfully.

## Privacy and data flow
- No OpenAI, Anthropic, or other provider API is called.
- No account access, direct chat reading, raw history import, or upload exists.
- The source AI interaction happens entirely outside ProjectStill under user control.
- Pasted text remains transient view state until approval.
- Only the schema-decoded normalized profile, provider, approval time, and optional approved note are stored.
- Data is stored in the local SwiftData container; no networking client, analytics SDK, backend, or third-party dependency exists.
- Removing AI evidence deletes the normalized record and rebuilds from retained questionnaire answers.
- ProjectStill does not clear the system clipboard; clipboard lifecycle remains under iOS/user control.

## Known limitations
- The validator is a product safety boundary, not a comprehensive content-moderation or privacy-loss detector.
- Diagnostic-language checks are an intentionally small English list and can have false positives or false negatives.
- Provider identity is selected by the user and is not cryptographically verified.
- External confidence values are produced by the external assistant; ProjectStill bounds and discounts them but cannot calibrate their underlying validity.
- Schema version 1 requires all ten dimensions, even when an assistant has insufficient evidence; the assistant must express uncertainty through low confidence and the evidence text.
- Unknown fields are ignored by design rather than reported.
- The system paste action can trigger the standard iOS paste-permission prompt.
- Persistence migration beyond backward decoding of M1 profile payloads is not yet implemented.
- User-facing global data reset remains M7 scope.
