# TheDuck — Scope Control

## MVP must include
- Native iPhone app in SwiftUI.
- 12–18 question adaptive intake questionnaire.
- Optional “Ask your AI” route: user copies a provided prompt into ChatGPT/Claude, reviews the structured result, then pastes it into the app.
- Optional raw chat export import stub/experimental path behind a clear privacy warning. For MVP, parsing may support ChatGPT `conversations.json` and plain-text/JSON exports where feasible. If support is incomplete, fail clearly rather than pretending coverage.
- Profile synthesis that separates:
  1. self-report,
  2. observed/AI-derived evidence,
  3. competing interpretations,
  4. confidence.
- 4–6 attention-state hypotheses sufficient for the first meditation recommendation.
- 7-day experiment plan.
- Short guided sessions, 4–10 minutes.
- 30-second post-session feedback.
- Day-7 reassessment and hypothesis update.
- Local-first storage for personal profile and session history.
- Clear data deletion/reset.
- Source/citation cards for any classical Sanskrit teaching used in the app.

## Explicitly out of scope for MVP
- Therapy.
- ADHD/anxiety/depression diagnosis.
- Medical claims.
- Social/community features.
- Large meditation library.
- Sleep stories.
- Live human teachers.
- Wearables.
- Apple Watch.
- Subscriptions/paywall.
- Universal AI-to-AI context protocol (separate Product B).
- Real-time direct read access to a user's full ChatGPT/Claude history.
- “Ancient type quiz” or fixed Sanskrit personality labels.

## Kill scope creep
If a feature does not improve one of these: profile quality, recommendation quality, practice completion, feedback quality, trust/privacy — defer it.
