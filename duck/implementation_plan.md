# TheDuck — Implementation Plan

## Human intent
ProjectStill should help a meditation-curious adult form a provisional, evidence-backed understanding of how their attention behaves, try a short practice selected for the current pattern, and revise that understanding from outcomes. The product must preserve uncertainty, distinguish self-report from observed evidence, surface disagreement and alternatives, and never present an attention pattern as a diagnosis or permanent identity.

## Architecture
- Native iPhone application targeting iOS 18+, implemented with Swift 6 and SwiftUI.
- Feature-oriented source layout matching the handover: onboarding, questionnaire, evidence import, profile synthesis/review, practice planning, meditation session, reflection, progress, and privacy settings.
- Shared design system containing semantic colors, typography, spacing, shapes, and motion behavior.
- SwiftData for local profile and session persistence when persistence enters scope.
- Deterministic, testable `ProfileEngine` and `RecommendationEngine`; imported or pasted AI output is untrusted input decoded into a strict local schema.
- No backend, account, analytics SDK, or implicit network path in the MVP.

## Milestone plan
1. **M0 — Shell, design tokens, navigation:** establish the Xcode project, accessible visual foundation, opening screen, explanatory route, privacy-choice route, and placeholder boundaries for later features.
2. **M1 — Questionnaire and local profile:** implement the 12–18 question intake, local domain models, deterministic questionnaire scoring, persistence, and tests.
3. **M1.6 — Inference reset and visual reset:** replace the external-AI schema so external models return qualitative observable conversational patterns with ordinal evidence strength only; remove numeric cognitive/attention scores from AI-derived evidence; keep questionnaire scoring internal for deterministic routing without presenting it as psychometric measurement; and move the UI direction from muted earthy wellness to Sunlit QuietEarth. Specified and implemented in `duck/m1_6_inference_and_visual_reset.md`; not yet compiled or verified.
4. **M2 — Ask-your-AI route (reworked into M1.6):** the approved prompt, paste flow, strict schema-v2 decoding, validation preview, user-confirmed observation filing, hypothesis generation, and malformed-input fixtures. The first M2 build was completed against the superseded schema-v1 scoring prompt; its numeric scoring is now removed. The milestone returns to complete when the suite runs green and simulator evidence is recaptured.
5. **M3 — Profile review:** separate self-report, evidence, disagreement, alternatives, and confidence; allow correction without erasing contradictory evidence.
6. **M4 — Recommendation engine:** implement deterministic rules and the first three practice templates with user-visible rationales.
7. **M5 — Session and reflection:** deliver an offline guided timer, accessible haptics/transitions, and the sub-30-second reflection flow.
8. **M6 — Seven-day adaptation:** store outcomes, enforce minimum evidence thresholds, reassess on day seven, and explain changes.
9. **M7 — Privacy/reset and experimental import:** verify deletion, add guarded import support, and fail clearly for unsupported exports.
10. **M8 — Polish and internal release:** complete accessibility, device, privacy, regression, and TestFlight-readiness checks.

Each milestone stops for review and includes build/test output, simulator evidence, known issues, privacy/data-flow notes, and ledger updates.

## Ambiguities to resolve before affected milestones
- The exact adaptive questionnaire questions, branching behavior, and score weights are not yet specified.
- `AttentionDimension`, `PracticeHypothesis`, and `AlternativeHypothesis` need complete domain definitions.
- The direction of the combined energy/dullness dimension is ambiguous in the current recommendation examples. (Resolved in M1: higher always means duller.)
- Per-session outcome weighting and the day-seven hypothesis-change calculation need deterministic definitions.
- Import limits, supported export variants, schema versioning, migration behavior, and user-facing validation errors need definition.
- Approved Sanskrit entries need exact source editions/translations, provenance text, and licensing review.
- Static support copy and placement require product/policy review before free-text inputs ship.

## Challenge findings
- The largest product risk is presenting quiz inference as truth. Every later profile view must retain confidence, counter-evidence, alternatives, and an insufficient-evidence state.
- **(M1.6) Asking a frontier model to rate named attention constructs numerically produced the form of a cognitive screening instrument, and produced precision nothing had measured.** The correction is structural, not cosmetic: external models describe observable conversational behaviour, the app turns descriptions into falsifiable hypotheses, and practice outcomes are the only measurement. Numeric cognitive scoring is removed from AI-derived evidence entirely.
- **(M1.6) A calm palette executed as beige on beige reads as tired, not serene.** Brightness, contrast, space, and one confident hero visual per screen carry calm better than muted colour does.
- Chat-derived behavior is a weak contextual signal, so raw import remains experimental and the user-controlled Ask-your-AI path remains preferred.
- Personalization is only credible when each recommendation exposes its input signals and later outcomes can overturn it.
- Classical Yoga concepts must remain optional interpretive parallels, never labels or medical evidence.
- A calm visual style must not reduce readability, touch target size, contrast, Dynamic Type support, or Reduce Motion behavior.

## Scope exclusions
No therapy or diagnosis, medical claims, accounts, analytics, subscriptions, social/community features, large content library, sleep stories, live teachers, wearables, Apple Watch app, external backend, direct chat-history access, universal AI context protocol, or fixed Sanskrit personality typing.

## Verification plan
- Build the app and test targets with `xcodebuild` against an available iPhone simulator.
- Add unit tests alongside each deterministic model/parser/engine.
- Add focused UI tests for critical paths: questionnaire-only onboarding, Ask-your-AI paste/preview, disagreement display, recommendation rationale, offline session, reflection/adaptation, and reset.
- Exercise milestone flows in Simulator and capture screenshots or recordings.
- Run accessibility checks for Dynamic Type, VoiceOver labels/order, contrast, 44pt targets, dark mode, and Reduce Motion.
- Use fixtures for contradictory, insufficient, malformed, boundary, and unsupported-import evidence.
- Run an automated copy scan over all user-facing text for trait-attached numbers, alongside the existing diagnostic-language scan.
- Verify local-first and offline claims with network inspection before marking them complete.
- Update `duck/03_evidence_verification_ledger.md`, the human summary, known issues, and privacy/data-flow notes at every milestone.

