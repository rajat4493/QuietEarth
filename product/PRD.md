# PRD — Adaptive Meditation MVP

## Working product name
Use a placeholder in code: `ProjectStill`. Do not invent a final brand in MVP.

## Problem
Meditation products often personalize around goals such as stress, sleep, or focus. They rarely begin by testing how a person's attention actually behaves or by challenging the person's own explanation of it.

## Core value proposition
An evidence-backed meditation starting point that adapts to how the user's attention appears to work now.

## Primary user
A meditation-curious adult who has tried or considered meditation but is unsure whether generic instruction fits them.

## Core loop
1. Intake
2. Evidence
3. Profile hypothesis
4. User review
5. Practice assignment
6. Session
7. Reflection
8. Adaptation

## Evidence inputs
A. Questionnaire only — self-report, scored deterministically on-device.
B. Recommended: Ask-your-AI **structured observation set** — qualitative descriptions of observable
   conversational behaviour with ordinal evidence strength. No numeric scoring of the user's mind.
   See `product/ASK_YOUR_AI_PROMPT.md` (schema v2).
C. Experimental: user-selected exported chat file.
D. **Practice outcomes** — the only stage that observes behaviour directly, under known conditions,
   repeatedly. The meditation is the measurement mechanism.

## Profile dimensions for MVP
Use dimensions, not fixed types:
- attentional switching
- persistence once engaged
- associative branching
- disengagement ease
- novelty dependence
- emotional capture
- energy/dullness tendency
- tolerance for low-stimulation practice
- metacognitive noticing

Each dimension stores:
- an internal routing score 0–1 (questionnaire and practice evidence only — never rendered, never
  presented to the user as a measurement)
- ordinal evidence strength: strong / moderate / weak / insufficient
- evidence source(s) with provenance
- contradictory evidence

External AI evidence does not score dimensions. It produces observations, themes, and hypotheses.
See `duck/m1_6_inference_and_visual_reset.md` for the numbers policy binding the whole product.

## Observation → hypothesis
The chain the product runs on:

`self-report → external observation → contradiction → hypothesis → practice experiment → evidence`

A returned observation such as *"often opens adjacent lines of inquiry before closing the original
one"* becomes a working hypothesis — *"your attention may branch before it settles"* — carrying a
stated prediction about the next seven days of practice and a stated condition that would disconfirm
it. A hypothesis without a prediction does not ship.

Support states, in test-first order: **contested** (sources disagree), **converging**,
**single-source (observed)**, **single-source (self-report)**, **not yet supported**. Test the claim
most likely to be wrong first.

## Provisional practice hypotheses
H1 Scattered / high-switching
H2 Intermittently focused
H3 Dull / low-energy
H4 Emotionally captured
H5 Naturally sustained / one-pointed
H6 Capacity present, gating appears variable
H7 Insufficient evidence

Do not show H1–H6 as identity labels. Show plain-English descriptions, hedged, about attention
behaviour rather than about the person. H7 is a supported outcome, not a failure state.

## Initial practice templates
1. Return Training
   - 5–7 min
   - single anchor
   - user counts noticing/returning, not “empty mind”

2. Settle Then Focus
   - 6–8 min
   - easy exhale regulation, then anchor

3. Energize Then Attend
   - 4–6 min
   - posture/eyes-open grounding, then brief focus

4. Emotional Clearing
   - 6–8 min
   - short affect-label/maitri-inspired reflection, then anchor

5. Sustained Flow
   - 8–10 min
   - longer uninterrupted object focus

## Day-7 decision
The app compares predicted vs reported outcomes and either:
- retain practice,
- shorten/lengthen,
- change anchor,
- change hypothesis,
- declare insufficient evidence.
