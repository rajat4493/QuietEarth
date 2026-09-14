# UX Flow

## 1. Opening
Headline: `Meditation should fit the mind doing it.`
Subtext: `We start by understanding how your attention moves — not by assuming everyone needs the same practice.`
CTA: `Understand my mind`
Secondary: `How this works`

## 2. Privacy choice
Title: `How much do you want to share?`
Cards:
- `Questionnaire only` — Nothing imported.
- `Ask your AI` — Recommended. Your chats stay in ChatGPT/Claude; you bring back only the profile you approve.
- `Import an export` — Experimental. Analyze selected history on-device where possible.

## 3. Questionnaire
One question per screen. Large type. No progress anxiety; show a subtle “~4 min remaining”.
Mix forced-choice and small scales. Avoid clinical language.

## 4. Ask-your-AI path
- provider picker: ChatGPT / Claude / Other
- `Copy observation prompt`
- explanation of what the prompt asks and forbids — including that it asks for descriptions of
  observable conversational behaviour, not scores, ratings, or any assessment of the user
- `Paste result`
- local schema validation (v2; numbers and diagnostic/psychometric language are rejected)
- preview exactly what will be used
- **filing step:** each observation is shown verbatim beside a suggested theme with the visible reason
  for the suggestion. The user confirms, reassigns, or chooses `None of these`. Nothing enters product
  logic unconfirmed.
- observations marked `insufficient` are shown and explicitly drive nothing

## 5. Profile reveal
Not a dramatic horoscope reveal. No scores, gauges, rings, or percentages anywhere on this screen.
Hero visual: two attention ribbons, self-report and observation, touching where they agree and
separating where they differ.

Title: `What we think so far`
Sections:
- `You described yourself as…`
- `What was observed in your conversations…`
- `Where those disagree` — stated plainly, and tested first
- `Other explanations we considered`
- `What we can't tell yet` — weak and insufficient evidence lives here, by design
- `How sure we are` — words on a four-step scale, never a number

Each hypothesis card shows: the hedged statement, what supports it, what would disconfirm it, and
which practice tests it.

CTA: `This feels accurate` / `Something is off`

## 6. Traditional parallel
Optional expandable card:
`A useful parallel from classical Yoga`
Explain source, Sanskrit term, translation ambiguity, and why it is only a parallel.

## 7. 7-day experiment
`We’re not declaring a type. We’re testing a hypothesis.`
Show:
- current hypothesis, in plain hedged language
- today’s 5–8 minute practice
- why it was chosen — in evidence statements, never in numbers
- what we expect to see if the hypothesis holds
- what would tell us it is wrong

## 8. Session
Ultra-minimal.
- short instruction
- timer/ring
- subtle haptic at transitions
- no feed, streak pressure, badges, or distracting controls

## 9. Reflection
Three fast inputs:
- How often did you notice wandering? Few / Some / Many
- How easy was returning? Hard / Mixed / Easy
- Afterward: More scattered / Same / More settled
Optional note.

## 10. Home after onboarding
Three zones only:
- `Today` practice card
- `What we’re learning` profile delta
- `Your experiment` day x/7

## 11. Day 7
`What survived the experiment?`
Show the initial hypothesis, its stated prediction, and what the week's sessions actually showed —
counts of things genuinely counted, never trait scores.
Explain any change to hypothesis or recommendation, including "the evidence did not settle this."
Hero visual: one continuous warm path under a sunrise wash.

## Visual direction
Every screen follows Sunlit QuietEarth (`product/DESIGN_SYSTEM.md`): one hero visual, white cards on a
sunlit ivory canvas, generous space, large airy headings, one leading accent, and playful light-spring
motion. Hero information — today's practice, current hypothesis, day `x/7` — is visible at a glance
rather than buried behind expansion.
