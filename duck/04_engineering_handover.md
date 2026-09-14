# TheDuck — Engineering Handover

## Platform
- iOS 18+
- Swift 6
- SwiftUI
- SwiftData for local persistence
- AVFoundation only if recorded audio is included; otherwise MVP can use timed text guidance + haptics/system speech where appropriate
- FileImporter for user-selected exports
- No analytics SDK in first internal build

## Architecture
Feature modules:
- Onboarding
- Questionnaire
- EvidenceImport
- ProfileSynthesis
- ProfileReview
- PracticePlan
- MeditationSession
- Reflection
- Progress
- SettingsPrivacy

Services:
- ProfileEngine
- RecommendationEngine
- ImportParser
- LocalStore
- ClassicalReferenceStore

The profile/recommendation engine should be deterministic and testable. LLM output may populate structured evidence but must not directly control the UI or execute arbitrary actions.

LLM output is qualitative only: observable conversational patterns with ordinal evidence strength. It
never supplies a numeric score, and it is never machine-filed into product logic without explicit user
confirmation. `HypothesisEngine` sits alongside `ProfileEngine` (and the future `RecommendationEngine`): it turns
user-filed observations plus questionnaire evidence into working hypotheses carrying a prediction and
a disconfirmation condition. It assigns no practice — that is M4. See
`duck/m1_6_inference_and_visual_reset.md`.

## Delivery milestones
M0 Shell + design tokens + navigation
M1 Questionnaire + local profile model
M1.6 Inference reset (schema v2, observations → hypotheses, no AI-derived numbers) + visual reset (Sunlit QuietEarth) — implemented, pending build verification
M2 Ask-Your-AI copy/paste route + v2 parser + observation filing + hypothesis generation (reworked into M1.6; first build used the withdrawn schema v1)
M3 Profile review + disagreement/alternatives
M4 Recommendation engine + 3 practice templates
M5 Guided session + reflection
M6 7-day adaptation + day-7 reassessment
M7 Privacy/reset + optional experimental export import
M8 polish + TestFlight-ready internal MVP

Every milestone updates `/duck`.
