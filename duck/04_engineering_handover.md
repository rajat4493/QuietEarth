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
Presentation is replaceable through `QuietTheme.swift` (semantic colors, typography, spacing, card geometry, asset reference). Appearance settings use local keys `appearance.mode` and `appearance.landscape`. Profile review stores a separate user note under `profile.userPerspective`; do not feed it into scoring or silently overwrite original evidence. Global reset must clear these keys. Visual design is not user-approved.

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

## Delivery milestones
M0 Shell + design tokens + navigation
M1 Questionnaire + local profile model
M2 Ask-Your-AI copy/paste route + parser
M3 Profile review + disagreement/alternatives
M4 Recommendation engine + 3 practice templates
M5 Guided session + reflection
M6 7-day adaptation + day-7 reassessment
M7 Privacy/reset + optional experimental export import
M8 polish + TestFlight-ready internal MVP

Every milestone updates `/duck`.
