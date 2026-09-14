# M1.6 Evidence — Visual and Inference Reset

## Definition of done
A user can combine a deterministic questionnaire profile with user-approved, qualitative external observations, inspect disagreements as falsifiable working hypotheses, remove that external evidence, and keep all data on-device. No external observation becomes a cognitive score.

Status: **verified complete**.

## Delivered
- Sunlit Calm light/dark visual system and Reduce Motion-aware opening illustration.
- External AI schema v2 with ordinal evidence strength and strict local validation.
- Explicit rejection of schema v1, numeric fields, score-shaped prose, malformed data, and diagnostic vocabulary.
- Source-preserving qualitative evidence; external evidence never enters questionnaire scoring.
- Working hypotheses with basis, counterpoint, prediction, and disconfirmation.
- Contested self-report/observation differences sorted before source-specific hypotheses.
- Local persistence, approval boundary, and exact external-evidence deletion/reversion.
- No provider API, account access, upload, recommendation, diagnosis, audio, analytics, or backend.

## Automated verification
Environment: Xcode 26.6, Swift 6.3.3, iPhone 16 Pro simulator on iOS 18.1.

- Build: `BUILD SUCCEEDED`.
- Unit suites: 20 tests passed, 0 failed.
- UI suites: 6 tests passed, 0 failed.
- Unit result: `/Users/rajatpandey/Library/Developer/Xcode/DerivedData/ProjectStill-cdiyvpxoajclysfkxnitgkfnpaim/Logs/Test/Test-ProjectStill-2026.09.14_21-49-49-+0200.xcresult`
- UI result: `/Users/rajatpandey/Library/Developer/Xcode/DerivedData/ProjectStill-cdiyvpxoajclysfkxnitgkfnpaim/Logs/Test/Test-ProjectStill-2026.09.14_21-50-43-+0200.xcresult`

Regression coverage includes qualitative parsing, numeric rejection, unsafe content, persistence and deletion, questionnaire resume/relaunch, malformed-import UI rejection, disagreement ordering, unchanged questionnaire dimensions, falsifiable hypothesis fields, and absence of percentage UI.

## Simulator evidence
- `opening-light.png`
- `opening-dark.png`
- `opening-reduce-motion.png`
- `profile-hypotheses.png`

The deterministic seeded profile demonstrates the original product-defining contradiction: weak self-reported focus alongside context-specific long-form persistence. It remains a contested hypothesis rather than becoming “medium focus.”

## Privacy and assumptions
Only the normalized profile approved by the user is persisted in local SwiftData. Pasted text is transient before approval. Provider identity is user-selected and is not verified. The external assistant's ordinal evidence strength is displayed as supplied, not treated as calibrated measurement.

## Known limitations
- Free-form external observations are not semantically mapped to questionnaire dimensions.
- The English diagnostic-language filter is a bounded safety check, not comprehensive moderation.
- Reduce Motion evidence confirms the static rendered state; automated timing inspection is not yet included.
- Global user-facing data reset remains later scope.
- Practice selection and learning from practice outcomes remain M4 and later work.

## Human Summary
QuietEarth now treats profiles as testable ideas rather than verdicts. It can show what the user reported, what their chosen AI observed, where those views differ, and what future evidence could strengthen or weaken each claim—without inventing numerical certainty. The implementation builds, its regression suite is green, and its current visual and behavioral evidence is recorded here.
