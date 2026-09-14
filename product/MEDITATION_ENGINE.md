# Meditation Recommendation Engine

## Principle
For MVP use a transparent deterministic rules engine, not an opaque LLM recommendation.

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

If profile confidence < .45:
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
