# TheDuck — Ambiguity / Challenge Pass

## Challenge 1: Is this just a personality quiz plus meditation?
Risk: very high.
Mitigation: every profile claim must show evidence, confidence, and at least one alternative interpretation. The 7-day practice is treated as an experiment whose result can overturn the initial model.

## Challenge 2: Are ancient Sanskrit categories being overclaimed?
Risk: high.
Mitigation: use “traditional parallel” language. Never say “you are kshipta/vikshipta.” Say “this resembles a pattern described in the classical Yoga commentarial tradition.” Include text provenance.

## Challenge 3: Does importing chats create a privacy nightmare?
Risk: critical.
Mitigation: make “Ask your AI” the recommended route. Raw export import is optional and clearly separated. Minimize what leaves device. Never upload raw history by default.

## Challenge 4: Can chat style validly reveal attention style?
Risk: medium-high.
Mitigation: treat inferred behavior as one signal, not truth. Require counter-evidence. Allow “insufficient evidence.” Test recommendations against outcomes.

## Challenge 5: Could users mistake this for mental-health diagnosis?
Risk: critical.
Mitigation: no psychiatric labels, no disease probabilities, no “you have X.” Include visible boundary copy during profiling.

## Challenge 6: Is a meditation app credible without lots of content?
Risk: low for MVP.
Mitigation: differentiation is diagnosis-of-fit + adaptive experiment, not content volume.

## Challenge 7: Does personalization become fake personalization?
Risk: medium.
Mitigation: every practice recommendation must expose “Why this was chosen” and map to one or more profile signals.

## Challenge 8: Does asking an AI to score attention dimensions constitute cognitive screening?
Risk: critical. **Raised at M1.6, after a frontier model declined the M2 prompt.**
The v1 prompt asked for ten named attention constructs, each rated `0...1` with a confidence decimal
and full-coverage required. That is the *form* of a screening battery, and "do not diagnose ADHD"
attached to it does not change the form. The model was right, and it was right before a user or a
reviewer hit the same wall.
Mitigation: external models are now asked only to describe observable conversational behaviour, with
ordinal evidence strength and no numbers of any kind. The product converts descriptions into
hypotheses. `product/ASK_YOUR_AI_PROMPT.md` (schema v2), `duck/m1_6_inference_and_visual_reset.md`.

## Challenge 9: Is the product fabricating precision?
Risk: critical. **Raised at M1.6.**
`focus_persistence = 0.63` had nothing behind it — nothing timed, counted, or trialled — and the app
then multiplied it by a second invented decimal and compared it against a questionnaire score on a
`0.18` threshold. Arithmetic on numbers that never carried information looks like measurement, which
is precisely why it is dangerous.
Mitigation: a binding numbers policy. Numbers appear only for things actually counted. Confidence and
evidence strength are ordinal words. Questionnaire scores survive as internal routing mechanics and
are never rendered or described as measurement. A copy scan enforces this in CI.

## Challenge 10: Does "calm" have to mean visually tired?
Risk: medium, and it had already materialised.
The earthy palette shipped as beige on beige and read as a wellness brochure. Calm had been confused
with muted.
Mitigation: Sunlit QuietEarth — bright, spacious, tactile, playful, high-contrast, one hero visual per
screen — with introspection carried by content and the attention-path motif rather than by low
saturation. Gentler Streak is the quality bar, not an asset source. Accessibility claims from M0/M1
are re-verified after the re-skin rather than assumed to carry.
