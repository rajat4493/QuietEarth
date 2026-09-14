# M1.6 — Inference Reset and Visual Reset

Inserted between M1 and M2. M2 had already been built against the superseded schema, so M1.6 is both a
specification change and the rework of that milestone. **This document is implemented**, not pending:
the schema-v2 parser, the filing step, the hypothesis engine and the Sunlit QuietEarth re-skin are in
the app. What is not yet verified is the build itself — see the exit criteria.

Two changes, taken together:

1. **Inference reset** — external models describe observable conversational behaviour. They do not
   measure the user's mind. QuietEarth turns descriptions into hypotheses, and practice into evidence.
2. **Visual reset** — from muted earthy wellness to **Sunlit QuietEarth**: bright, optimistic, spacious,
   tactile, playful, still introspective.

---

# Part 1 — Inference reset

## The flaw we are correcting

The M2 prompt asked an external assistant to rate ten named cognitive dimensions on `0...1` with a
confidence decimal each. Even with "do not diagnose" attached, the *shape* of that request was a
cognitive screening battery: named constructs, numeric severity, confidence weighting, ten-item
coverage requirement.

Two problems, both real:

- **It looks like screening.** A battery of attention constructs with numeric severity is the form of a
  psychometric instrument, regardless of the disclaimer wrapped around it. A frontier model declining
  to produce it was correct, and it was correct before any user hit the same wall.
- **It fabricates precision.** `focus_persistence = 0.63` has no measurement behind it. Nothing was
  timed, counted, or trialled. The number is a linguistic impression rendered to two decimal places,
  and the rendering is what makes it look like a finding. Downstream, that false precision was being
  multiplied by another invented decimal (`overall_confidence`) and compared against questionnaire
  scores on a `0.18` threshold — arithmetic performed on numbers that never carried information.

We are not softening the copy around those numbers. We are removing the numbers.

## The corrected chain

```
self-report  →  external observation  →  contradiction  →  hypothesis  →  practice experiment  →  evidence
```

The meditation session is the measurement mechanism. It is the only stage in this product that
observes behaviour directly, under known conditions, repeatedly. Everything before it is description.

| Tier | Source | Nature | May carry a number? |
|---|---|---|---|
| 1 | In-app questionnaire | Self-report | Internal deterministic scoring only. Never displayed as a measurement. |
| 2 | External AI observation | Qualitative description of conversational behaviour | **Never.** Ordinal evidence strength only. |
| 2b | AI-relayed self-description | What the user has said about themselves elsewhere | **Never.** Context only; scores nothing. |
| 3 | Practice outcomes | Behaviour the app actually observed | Yes — counts of things genuinely counted. |

## What external models are now asked for

The full prompt text lives in `product/ASK_YOUR_AI_PROMPT.md` and is the single source of truth for
what the user copies. Its substance:

- describe **observable conversational behaviour**, nothing more;
- keep the user's self-description separate from observed patterns, and do not assume the
  self-description is accurate;
- no diagnosis, no mental-health/cognitive/personality assessment;
- **no numeric scores, probabilities, percentiles, clinical labels, or psychometric-style ratings**;
- for each observation: the pattern, what supports it, a counter-example or alternative explanation,
  and an ordinal evidence strength of `strong | moderate | weak | insufficient`;
- no names, employers, private facts, account/health/financial information, relationships, or other
  sensitive detail;
- valid JSON only, `schema_version: 2`.

The prompt's bullet list of observable behaviours is deliberately closed and stable. It doubles as the
app's **theme vocabulary** (below), so the prompt and the product logic cannot drift apart.

## Accepted external JSON — schema version 2

```json
{
  "schema_version": 2,
  "self_report": [
    { "statement": "...", "evidence_strength": "strong|moderate|weak|insufficient" }
  ],
  "observations": [
    {
      "pattern": "...",
      "evidence_strength": "strong|moderate|weak|insufficient",
      "reason": "...",
      "counterpoint": "..."
    }
  ],
  "differences_between_self_report_and_observation": ["..."],
  "alternative_explanations": ["..."],
  "limitations": ["..."]
}
```

### Parser rules

Accept only after every rule passes. Fail closed, with a message that tells the user what to do next.

- `schema_version` must equal `2`. Version `1` is rejected with "This prompt has been replaced — copy
  the current prompt and run it again." Version 1 is never converted.
- `observations`: 1–12 entries. `self_report`: 0–12 entries. Each remaining array: 0–12 entries.
- `evidence_strength` must be exactly one of the four lowercase tokens. Anything else — including a
  number, a percentage, or `"high"` — is rejected.
- `pattern`, `reason`, and every array string: non-empty after trimming, ≤ 600 characters.
  `counterpoint` may be empty; an empty value is stored as "No counter-example offered."
- Whole payload ≤ 40 KB UTF-8.
- **No-numbers rule:** reject the payload if any free-text field matches a score-shaped pattern —
  `\b\d{1,3}\s?%`, `\b0\.\d+\b`, `\b\d(?:\.\d+)?\s*/\s*(?:5|7|10|100)\b`, or a percentile phrase.
  The schema carries no numbers; numbers smuggled into prose are numbers all the same.
- Retain the M2 diagnostic-language rejection list (`adhd`, `diagnosed with`, `clinical`, disorder
  names, …) and extend it with psychometric vocabulary: `percentile`, `score of`, `rating of`,
  `assessment indicates`, `test results`, `screening`.
- Unknown JSON fields are ignored and are never interpreted as instructions.
- Rejection reasons are shown to the user; the paste is never partially accepted.

Every one of these is a fixture case. See the acceptance fixtures at the end of Part 1.

## From observation to hypothesis

External free text must never reach product logic unmediated. It is filed by the user, not classified
by a hidden model.

### 1. Themes (closed vocabulary)

The eight themes are exactly the prompt's observable-behaviour bullets:

| Theme | Observable behaviour |
|---|---|
| `branching` | opens related branches rather than staying with one topic |
| `returning` | comes back to earlier ideas after exploring elsewhere |
| `topicDepth` | some subjects produce much deeper or longer engagement than others |
| `reframing` | frequently asks to compress, simplify, expand, challenge, or reframe |
| `revisiting` | reopens conclusions after they appear settled |
| `linking` | connects apparently separate subjects |
| `taskDependence` | interaction style differs by type of task |
| `selfQuestioning` | notices and questions own assumptions, or the assistant's reading of them |

### 2. Filing step (user-controlled)

In the preview, each observation is shown verbatim next to its suggested theme. The suggestion comes
from a small, **visible** keyword list — the user can see why a theme was proposed — and nothing is
filed until the user confirms or reassigns it. "None of these" is always available and drops the
observation from product logic while keeping it readable in the profile.

We rejected silent app-side classification. A hidden classifier assigning themes on the user's behalf
would re-introduce exactly the thing we are removing: an unmeasured judgement presented as a result.

### 3. Support state

Each theme resolves to one state. `Q` is the questionnaire lean (internal, deterministic:
clear / slight / none / opposite). `O` is the filed observation's evidence strength.

| State | Condition | Drives practice? |
|---|---|---|
| **Contested** | `Q` clear, `O ≥ moderate`, opposite directions | Yes — first priority |
| **Converging** | `Q` clear, `O ≥ moderate`, same direction | Yes |
| **Single-source (observed)** | `O ≥ moderate`, `Q` none | Yes |
| **Single-source (self-report)** | `Q` clear, no filed observation | Yes |
| **Not yet supported** | only `weak` / `insufficient` evidence | No — shown under "What we can't tell yet" |

Test order is Contested → Converging → Single-source (observed) → Single-source (self-report). Test
the claim most likely to be wrong first. This is what makes "the app can disagree with the user" a
behaviour rather than a slogan.

`insufficient` observations are displayed and never produce a hypothesis. That is a supported outcome,
not a failure state.

### 4. Hypothesis record

```swift
struct WorkingHypothesis: Codable, Hashable, Identifiable {
    let id: String
    let theme: AttentionTheme
    let statement: String          // plain language, hedged, falsifiable
    let supportState: SupportState // the five states above
    let strength: EvidenceStrength // ordinal, never numeric
    let selfReportBasis: [String]  // questionnaire evidence statements
    let observedBasis: [String]    // filed external observation text
    let tension: String?           // stated plainly when Contested
    let prediction: String
    let disconfirmation: String
}
```

A hypothesis deliberately carries **no assigned practice**. Choosing a practice is a recommendation,
and recommendations remain out of scope until M4; the prediction and disconfirmation are written in
the reflection vocabulary so that M4 can attach a practice without reopening this model.

`statement` is always hedged and always about attention behaviour, never about the person:
"Your attention may branch before it settles" — not "you are an exploratory type", not "you have
difficulty sustaining attention".

### 5. Predictions — how a hypothesis becomes falsifiable

Predictions are expressed in the reflection vocabulary the app already collects: notice rate
(few / some / many), return ease (hard / mixed / easy), afterward (more scattered / same / more
settled), and completion. A hypothesis with no prediction is not a hypothesis and must not ship.

Implemented in `HypothesisEngine`. The practice column is the M4 target, recorded here for
continuity — the app does not yet assign it.

| Hypothesis | Practice (M4) | Predicts | Disconfirmed if |
|---|---|---|---|
| Attention may branch before it settles | Return Training | many notices early; return ease improves faster than notice count falls; settledness not worse | ≥4 sessions with few notices and hard returns — points to dullness, not branching |
| Sustained capacity may be present while selection varies | Sustained Flow | long sessions completed; notice count falls across the week; easy returns once engaged | ≥4 sessions with early abandonment or many notices throughout |
| Arousal may need settling before attention holds | Settle Then Focus | settledness improves; return ease improves after the exhale phase | settledness flat or worse across ≥4 sessions |
| Low stimulation may produce dullness rather than calm | Energize Then Attend | few notices with "more settled" absent; eyes-open grounding improves notice rate | notice rate high and return ease easy — that is branching, not dullness |
| Emotionally charged material may hold attention longer | Emotional Clearing | return ease improves after the labelling phase | no change in return ease across ≥4 sessions |

The Day-7 rule from `product/MEDITATION_ENGINE.md` holds: at least four completed sessions before a
core hypothesis changes, and the change is always explained to the user.

## Numbers policy

Binding across the whole product.

**Permitted.** Counts of things actually counted: sessions completed, day `x` of 7, minutes,
"you reported noticing wandering in 4 of 5 sessions", dates.

**Forbidden in the UI.** Any number attached to a trait, disposition, or capacity — score, percentage,
probability, percentile, confidence decimal, star rating, gauge fill, or progress bar whose fullness
stands for an attention property. This holds for AI-derived and questionnaire-derived values alike.

**Internal only.** The questionnaire's deterministic `0...1` dimension scores from
`duck/m1_scoring_model.md` remain, because deterministic routing to practice templates needs a stable
ordering. They are product mechanics. They are never rendered, never exported, never spoken in copy,
and never described to the user as a measurement. Where the user asks *why* a practice was chosen, the
answer is the evidence statements in words: "you said quiet activity is hard to stay with, and the
observations describe long engagement on a few subjects."

**Confidence.** Expressed in words on a four-step ordinal scale (`strong / moderate / weak /
insufficient`), presented as text or a four-step indicator. Never a percentage, never a decimal.
"Overall confidence: 0.62" is removed everywhere it appears.

## What M2 must lose in rework

`duck/m2_external_ai_schema.md` is superseded. Specifically, the following are deleted rather than
adjusted:

- `ExternalAIDimension.score` and `.confidence`; the ten-dimension completeness requirement for
  external payloads; `overall_confidence` and its multiplication into signal confidence.
- `ExternalEvidenceConverter`'s conversion of external dimensions into numeric `ObservedSignal`
  directions, and the quarter-weight opposing counter-evidence signal.
- Numeric cross-source reconciliation: the `0.18` agreement threshold, per-dimension
  `externalAIScore`, and any UI showing "questionnaire 14% / external 75%".
- `alternative_interpretations[].confidence`.

What survives, re-expressed qualitatively:

- Provenance on every piece of evidence: source, provider, timestamp, category, stable identifier,
  evidence statement, optional user-approved note. `ObservedSignal.confidence` becomes an ordinal
  `EvidenceStrength` for external evidence.
- Independent treatment of the two views before any combination, and the **How the two views compare**
  screen. It now compares *statements*, not scores: what you reported, what was observed, where they
  differ, what we are testing first.
- The capacity/gating case, which becomes a better fit as a hypothesis than it ever was as arithmetic:
  questionnaire reports weak persistence, observations describe long sustained engagement on certain
  subjects → **"Capacity present, gating appears variable"**, tested by Sustained Flow, with
  "generalized weak concentration" retained as the rival explanation and a stated disconfirmation.
- Reversible deletion of external evidence rebuilding the questionnaire-only profile.
- The user-approval boundary before anything is stored, and no provider API, account access, upload,
  or raw-history read.

### Stored v1 data

Any locally stored schema-v1 external record is **deleted** on first launch after rework, and the
profile is rebuilt from retained questionnaire answers. The user is told that AI evidence needs to be
added again with the new prompt. Old scores are never converted into synthetic observations — that
would manufacture exactly the evidence we are removing.

## Acceptance fixtures (deterministic)

1. Valid v2 payload with an inert unknown field → accepted, previewed, filed, hypotheses generated.
2. `schema_version: 1` → rejected with the re-copy-the-prompt message; nothing stored.
3. `evidence_strength: 0.8` and `evidence_strength: "high"` → both rejected.
4. Observation prose containing `81%` / `0.63` / `4/5` / "top decile" → rejected by the no-numbers rule.
5. Diagnostic or psychometric vocabulary in any field → rejected.
6. All observations `insufficient` → accepted, displayed, zero hypotheses, profile falls back to
   questionnaire-only practice routing, "What we can't tell yet" is populated.
7. Contested case: questionnaire says persistence is weak, observation describes long sustained
   engagement at `strong` → "Capacity present, gating appears variable", Contested, tested first,
   rival explanation retained, disconfirmation stated.
8. Converging case: both sources point the same way → Converging, no invented disagreement.
9. Filing: user reassigns a suggested theme → hypotheses regenerate deterministically; user selects
   "None of these" → observation stays visible, drives nothing.
10. Deletion: removing external evidence reproduces the questionnaire-only profile exactly.
11. Legacy: a stored v1 record is discarded, not migrated, and the rebuild is exact.
12. **Copy scan:** no screen renders a trait-attached number. Automated string/UI rule over all
    user-facing text, run in CI alongside the existing diagnostic-language scan.

---

# Part 2 — Visual reset: Sunlit QuietEarth

## The flaw we are correcting

"Warm earthy calm" was executed as beige on beige. The result reads as a wellness brochure: low
contrast, low energy, brown-dominant, visually tired. Calm was confused with muted, and muted became
sleepy.

Calm products can be bright. Gentler Streak is the quality reference — softer UI, clearer cards,
visible hero information, light visual treatment, liveliness without noise. It is a **bar**, not a
source: no copying of its illustrations, shapes, icons, colour values, layouts, or copy.

**Sunlit QuietEarth = Gentler Streak energy + QuietEarth introspection.**
Not spa. Not ashram. Not AI app. Not mental-health clinic.

## Palette

Light — the default and the one that must feel alive.

| Token | Hex | Use |
|---|---|---|
| `sunlitIvory` | `#FDF7EC` | canvas |
| `daylight` | `#FFFFFF` | cards, sheets |
| `deepSpruce` | `#12332B` | primary text, primary action fill |
| `spruceMuted` | `#41594E` | secondary text |
| `seaGlass` | `#3FAE8C` | primary fresh green: illustration, active states, large fills |
| `mintWash` | `#DCF1E8` | tinted surfaces, selected chips |
| `tangerine` | `#EE7A52` | energy accent: highlights, one CTA per screen at most |
| `coralWash` | `#FDE6DB` | tinted surfaces |
| `lemonSun` | `#F2C14E` | sunlight highlight, used sparingly |
| `lemonWash` | `#FBF0CE` | tinted surfaces |
| `hairline` | `#E8DFCE` | 1pt separators |

Dark — night, not gloom. Keep the accents bright; do not desaturate the product into a cave.

| Token | Hex |
|---|---|
| `sunlitIvory` → canvas | `#101B18` |
| `daylight` → card | `#182722` |
| `deepSpruce` → ink | `#F2EFE6` |
| `spruceMuted` | `#B9C9C0` |
| `seaGlass` | `#6FD3B4` |
| `tangerine` | `#FF9670` |
| `lemonSun` | `#F7D67A` |
| `hairline` | `#2A3A33` |

Rules:
- Body and heading text is `deepSpruce` on `sunlitIvory`/`daylight`. No text-on-beige murk.
- Tangerine and lemon are accents, never backgrounds for small text. Small text on an accent fill is
  `deepSpruce`, never white.
- One accent leads per screen. Two accents in one composition is the ceiling.
- Brown is gone. No `#B7795E` clay, no `#D39A45` saffron, no beige-on-beige surfaces.
- Every pairing that ships is contrast-tested: ≥ 4.5:1 body, ≥ 3:1 large text and meaningful glyphs,
  in both schemes and at all Dynamic Type sizes.

## Layout and surfaces

- **One hero visual per screen**, upper area, confident scale. Every screen has a single clear subject.
- Cards: `daylight` fill on `sunlitIvory` canvas, 24pt radius, one soft warm elevation
  (`rgba(60, 40, 20, 0.06)`, y-offset 8, blur 24). This is the one deliberate reversal of the old
  "very little shadow" rule — a white card on a tinted canvas needs separation to read as tactile.
- More white space than the current build, not less. Generous side margins, tall section rhythm,
  fewer elements per screen.
- Hero information is **visible, not buried**: today's practice, current hypothesis, and day `x/7`
  read at a glance without expansion.
- 44pt minimum targets. Rounded corners 18–24pt. No pill-everything.
- Still one primary decision per screen.

## Typography

- SF Pro for all functional text; New York for short reflective headings only.
- Hero headings go larger and airier than the current build: 34–40pt display, generous leading.
- Type carries hierarchy before containers do. Fewer boxes, more scale contrast.

## Illustration and motif

QuietEarth's identity remains the **attention path** — but sunlit and flowing, not thin grey contour
lines on beige. Organic ribbons with warm gradient washes in sea glass, mint, coral, and lemon,
hand-drawn in feel, never mechanical.

The motif now carries the methodology:

- **Onboarding** — one wide sunlit ribbon drifting across the screen.
- **Profile** — two ribbons, self-report and observation, touching where they agree and separating
  visibly where they differ. The disagreement is drawn, not only written.
- **Practice** — loops gathering toward a single anchor point.
- **Completion / Day 7** — one continuous warm path under a sunrise wash.

A gradient wash is a *warm sunlight* wash. It is not a violet/blue AI gradient, and the distinction is
enforced by the palette: accents come only from the tokens above.

## Motion

- More playful than the old 200–500ms. Arrivals and selections use light springs, 180–320ms.
- The attention path animates on profile reveal and on session completion — a drift, not a bounce.
- Haptics remain subtle and tied to real transitions.
- No streaks, badges, confetti, or gamified celebration.
- Reduce Motion replaces every animated path with its resolved static state. Nothing becomes
  unreachable or unreadable.

## Still forbidden

Generic AI: electric violet/blue gradients, glowing neural networks, glassmorphism, sparkles, chat
bubbles as primary UI, "AI magic" iconography.
Meditation cliché: stock yogis, default lotus logo, mountain-lake hero photography, chakras,
incense/pebbles.
**New:** beige-on-beige, brown-dominant surfaces, low-contrast "spa" palettes, gloom, and any
trait-attached gauge, score ring, meter, or progress bar (see the numbers policy — this is a visual
rule as much as a copy rule).

## Tone

Unchanged in substance, brighter in delivery.
Prefer: "Here's what we think so far." · "We found evidence both for and against this." ·
"Let's test that."
Avoid: "Your true mind type is…" · "AI detected your cognitive style." · "Your focus score is…"

## Rework surface

M0/M1 screens are re-skinned under this system before M2 rework ships: opening, how-it-works, privacy
choice, questionnaire, profile, answer review, evidence comparison, plus `QuietTheme`,
`ContourField` (becomes the sunlit path), and `PrimaryActionButtonStyle`.

Accessibility claims verified in M0/M1 must be **re-verified** after the re-skin, not assumed to
carry: contrast in both schemes, Dynamic Type through the largest accessibility sizes, VoiceOver
labels and order, 44pt targets, and Reduce Motion.

---

## Implemented surface

| File | Change |
|---|---|
| `ExternalAI/ExternalAIPrompt.swift` | schema-v2 observation prompt |
| `ExternalAI/ExternalAIProfile.swift` | v2 payload, parser, no-numbers rule, theme suggestion |
| `Profile/AttentionEvidence.swift` | `EvidenceStrength`, `AttentionTheme`, `ExternalObservation`, `SupportState`, `WorkingHypothesis` |
| `Profile/HypothesisEngine.swift` | lean, support state, hypotheses with predictions |
| `Profile/ProfileEngine.swift` | external numeric path removed; statement-level comparison |
| `Profile/AttentionProfile.swift` | observations/hypotheses; `overallStrength`; legacy decode |
| `Persistence/QuestionnaireRecords.swift` | v2 storage, re-filing, superseded-record discard |
| `Features/ExternalAI/*` | v2 intake, observation filing step |
| `Features/Profile/*` | number-free profile, hypothesis cards, statement comparison |
| `DesignSystem/*` | Sunlit QuietEarth tokens, sunlit attention path, button styles |

## M1.6 exit criteria

Documentation and implementation are both in place. Outstanding before the milestone can be called
complete:

- [ ] `xcodebuild … test` succeeds on an iPhone simulator. **Not yet run** — this work was done in a
      Linux container with no Swift toolchain, so nothing here has been compiled.
- [ ] Simulator evidence recaptured for `duck/evidence/M1.6/`: opening, profile with hypothesis cards,
      the observation filing step, and the comparison screen, in light and dark.
- [ ] Accessibility re-verified after the re-skin: contrast in both schemes, Dynamic Type through the
      largest accessibility sizes, VoiceOver labels and order, 44pt targets, Reduce Motion.
- [ ] Ledger rows moved from OPEN to VERIFIED once the above pass.

Until the build runs, treat every claim in this document as specified and written, not verified.
