# M4–M7 — Closing the core loop

Completes `Understand → Hypothesize → Practice → Verify → Adapt`. Before this, the app could
understand and hypothesise but never practise, so no hypothesis could ever be tested. The whole
methodology rested on a stage that did not exist.

**Status: implemented, not verified.** Written in a Linux container with no Swift toolchain — nothing
here has been compiled and no simulator evidence exists. Per TheDuck these milestones are incomplete
until the suite runs green on a Mac and evidence is captured.

## M4 — Recommendation

`RecommendationEngine` is deterministic and ordered. Precedence matters more than the individual
thresholds, because two rules can be true at once:

| Order | Condition | Practice | Why first |
|---|---|---|---|
| 1 | evidence insufficient (`overallConfidence < 0.45`) | Baseline Settling | Never guess a specific practice from thin evidence |
| 2 | energy/dullness > 0.70 | Energize Then Attend | Dullness makes every other practice fail for the wrong reason |
| 3 | emotional capture > 0.70 | Emotional Clearing | Feeling will keep reclaiming an anchor until it is named |
| 4 | switching > 0.60 and low-stimulation tolerance < 0.40 | Settle Then Focus | An unsettled body should not be asked to steady attention |
| 5 | switching > 0.70 | Return Training | Noticing and returning is the skill being trained |
| 6 | persistence > 0.75 and switching < 0.40 | Sustained Flow | Capacity is already there; give it room |
| — | otherwise | Return Training | The practice that suits the widest range |

`product/MEDITATION_ENGINE.md` specified "switching > .70 and energy > .40 → Return Training". Energy
was ambiguous once `energyDullness` was defined as higher-means-duller, so dullness is handled first
on its own and Return Training no longer tests it. The resolution is recorded here rather than left
in the code.

**The anchor is chosen separately** from sensory orientation: a felt anchor (breath, contact, sound)
when sensory cues are the more available way back, a verbal one (counting, phrase) otherwise. When
sensory orientation has no confident evidence, the felt anchor is the default. This gives day seven
something specific to change that is not the whole practice.

**Rationale is words.** `PracticeRecommendation.reasons` carries the evidence statements behind the
routing decision. The dimension scores that drove it are never shown — the numbers policy from
`duck/m1_6_inference_and_visual_reset.md` applies here unchanged, and a test asserts that no reason
string contains a percentage or a decimal.

## M5 — Session and reflection

`PracticeSessionView` is text and haptics only: no audio, no network, no streak, no badges. Each
template expands into timed steps whose seconds always sum exactly to the chosen length (asserted for
every template, length and anchor). A soft haptic marks each step transition; a success haptic marks
completion. The idle timer is disabled while practising and restored on exit. Reduce Motion removes
the ring's animation without removing the ring.

Ending early is offered without friction and recorded as it happened — `PracticeOutcome` keeps
planned and completed seconds, and a session counts as complete only past 90% of its planned length.
Sessions cut short are evidence, not failures to hide.

`ReflectionView` is the three inputs from `product/UX_FLOW.md` — notice rate, return ease, afterward —
plus an optional note. All three are required before saving, because a partial reflection would
silently bias the week. Every value is ordinal and stays ordinal.

## M6 — Seven-day experiment and adaptation

`Experiment` holds the practice, the hypothesis under test, its prediction, its disconfirmation
condition, and the outcomes. Day index is bounded to 1–7. Missing a day costs nothing and the UI says
so; there is no streak.

`AdaptationEngine` decides at day seven, deterministically, in this order:

1. **Fewer than 4 completed sessions → insufficient evidence.** The threshold from
   `product/MEDITATION_ENGINE.md`. Nothing changes. Reading a hypothesis off three sessions is
   reading noise.
2. **≥40% of sessions cut short → shorten.** The length is wrong before anything else is.
3. **Mostly few notices and never more settled → change hypothesis** to Energize Then Attend. This is
   the disconfirmation condition stated up front for the branching hypothesis: few notices with no
   settling points at low alertness, not busy attention.
4. **Mostly hard returns and no easing across the week → change anchor.** Change what attention
   returns to before concluding the hypothesis is wrong.
5. **Returning got easier and sessions left you settled at least as often as scattered → lengthen.**
   The prediction held.
6. **Otherwise → retain.**

`predictionHeld` is `true`, `false`, or `nil` for "not enough to say" — a supported outcome, not a
failure. The day-seven screen shows the initial belief, the observed week, the verdict and the
change, and says plainly that it is a record of what the user reported rather than a measurement.

Counts of completed sessions and reported answers are the only numbers in the product. They are
things actually counted, which is exactly what the numbers policy permits.

## M7 — Reset

`PracticePersistence.resetAllLocalData` clears every SwiftData store (questionnaire, profile,
external evidence, experiments) **and** the keys held outside SwiftData that `duck/m3_profile_review.md`
flagged as outstanding: `profile.userPerspective`, `appearance.mode`, `appearance.landscape`. Reached
from Settings, behind a confirmation that states it cannot be undone. A test asserts every store and
every key is empty afterwards.

Experimental raw-export import is **not** included. It is optional in `duck/01_scope_control.md` and
adding a half-working parser would be worse than not offering it.

## Home

Three zones, per `product/UX_FLOW.md`: Today's practice with "Why this practice" one tap away, what
we're learning (the hypothesis with its prediction and disconfirmation), and the experiment's day
`x/7`. A running experiment keeps the practice it started with; a day-seven adjustment applies to the
next one, so the ground does not move mid-week.

## Verification

Written and not yet run:

- `RecommendationEngineTests` — each routing rule, precedence, anchor selection, step arithmetic for
  every template/length/anchor, adjustment bounds, and the no-numbers rule on rationale text.
- `AdaptationEngineTests` — each day-seven branch, the four-session floor, day-index bounds, review
  idempotence, and that observed lines carry no percentages.
- `PracticePersistenceTests` — outcomes persist, experiments archive rather than vanish, partial
  sessions are kept as incomplete, reviews attach to their experiment, global reset clears everything.
- `PracticeLoopUITests` — start an experiment from the profile, run and end a session, complete a
  reflection, day-seven review and continue, global reset, and a sweep asserting no on-screen
  percentage anywhere in the loop.

Outstanding before these milestones can be called complete:

- [ ] `xcodebuild … test` green on a simulator.
- [ ] Simulator evidence under `duck/evidence/M4-M7/`: today, session, reflection, day seven, settings.
- [ ] Airplane-mode check for the offline claim in the ledger.
- [ ] Accessibility pass on the new screens: Dynamic Type, VoiceOver order, 44pt targets, Reduce Motion.
- [ ] Sanskrit reference cards (`product/CONTENT_AND_SAFETY.md`) — still unbuilt, still an open ledger row.
