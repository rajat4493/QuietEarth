# Meditation Recommendation Engine

## Principle
For MVP use a transparent deterministic rules engine, not an opaque LLM recommendation.

The threshold values below are **internal routing mechanics** over questionnaire and practice
evidence. They are never rendered, and the user-facing "why this practice" explanation is always in
evidence statements, not numbers. External AI evidence contributes no scores to these rules; it
contributes observations, themes, and hypotheses. See `duck/m1_6_inference_and_visual_reset.md`.

## Example mapping
If switching > .70 and energy > .40:
- Return Training

If switching > .60 and bodily agitation/self-reported arousal is high:
- Settle Then Focus

If energy/dullness > .70:
- Energize Then Attend

If emotional capture > .70:
- Emotional Clearing

If persistence > .75 and switching < .40:
- Sustained Flow

If overall evidence strength is weak or insufficient:
- short neutral baseline session + collect more evidence

## Adaptation
After each session compute:
- notice rate (ordinal)
- return ease
- post-session settledness
- completion

Do not optimize only for “feeling calm.” A practice may be useful while initially revealing more wandering.

## Day-7 rules
Require at least 4 completed sessions before changing a core hypothesis based on practice outcomes.
Show change rationale to user.

Each hypothesis ships with a stated prediction and a stated disconfirmation condition, both expressed
in the reflection vocabulary (notice rate, return ease, afterward, completion). Day 7 compares the
prediction against what the week actually showed, and "the evidence did not settle this" is a valid
outcome. Hypothesis templates and their predictions are tabulated in
`duck/m1_6_inference_and_visual_reset.md`.
