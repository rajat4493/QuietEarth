# M1 Questionnaire and Scoring Model

## Scope
M1 converts a local questionnaire into an explainable provisional attention profile. It does not use an LLM, import conversation history, diagnose a condition, or recommend meditation.

## Domain pipeline
`QuestionAnswer → ObservedSignal → ProfileDimension → ProfileInterpretation`

- **QuestionAnswer:** the option the user selected, stored with the stable question and option identifiers.
- **ObservedSignal:** one explicit scoring contribution produced by that option. It records the affected dimension, direction, weight, question identifier, and a plain-language evidence statement.
- **ProfileDimension:** a normalized score, confidence, supporting and counter evidence, and any contradiction found across signals.
- **ProfileInterpretation:** a provisional plain-language summary derived from dimension thresholds. It is not an identity or diagnosis and exposes the reasons used.

Questionnaire and future behavioral evidence can produce the same `ObservedSignal` shape while retaining their source. M1 accepts questionnaire signals only.

## Dimensions
M1 implements the nine dimensions in the PRD plus sensory orientation, requested for the questionnaire profile:

1. attentional switching — higher means attention changes targets more readily;
2. focus persistence — higher means attention tends to remain engaged once established;
3. associative branching — higher means one thought readily generates multiple related paths;
4. disengagement difficulty — higher means it is harder to leave the current topic or emotional object;
5. novelty dependence — higher means novelty is more important for maintaining engagement;
6. emotional capture — higher means emotionally charged material holds attention more strongly;
7. energy/dullness — higher always means a stronger low-energy or dullness tendency;
8. low-stimulation tolerance — higher means quiet or repetitive activity is easier to remain with;
9. metacognitive noticing — higher means shifts or wandering are noticed sooner;
10. sensory orientation — higher means concrete bodily/sensory cues are more available than verbal/conceptual cues.

The energy/dullness direction resolves the ambiguity recorded in the initial implementation plan: `0` means alert/energized tendency and `1` means dull/low-energy tendency.

## Questionnaire shape
- 12 core questions for everyone.
- Up to three conditional follow-ups, producing 12–15 total questions.
- A switching follow-up appears after a high-switching core answer.
- A dullness follow-up appears after a high-dullness core answer.
- A sustained-focus follow-up appears after a high-persistence core answer.
- Each screen asks one non-clinical, situational question.
- Stable identifiers allow answers and progress to survive copy changes and app restarts.

## Scoring
Each option emits one or more signals with:
- direction from `-1...1`, mapped to profile score `0...1`;
- weight from `0...1`;
- a specific evidence statement.

For a dimension, the score is the weighted mean of mapped signals. A dimension with no evidence remains at neutral `0.5` with zero confidence.

Confidence combines:
- **coverage:** available signal weight relative to the expected questionnaire evidence for the dimension;
- **agreement:** reduced by weighted dispersion;
- **contradiction penalty:** applied when the same dimension contains meaningful signals in both directions (`> 0.35` and `< -0.35`).

Contradictory answers remain visible as evidence. They are never silently removed. Overall confidence is the mean dimension confidence and never increases merely because an interpretation threshold was crossed.

## Provisional interpretation rules
Rules are evaluated deterministically and expose their reasons:
- insufficient evidence when overall confidence is below `0.45`;
- exploratory / intermittently focused when switching or branching is high;
- low-energy / dull when dullness is high and confidence is adequate;
- naturally sustained / one-pointed when persistence is high and switching is low;
- otherwise mixed / context-dependent.

The UI presents these as current interpretations, not fixed types.

## Fixed verification personas
- **Scattered/exploratory:** switching and branching must be high; persistence must not be high.
- **Low-energy/dull:** energy/dullness must be high with adequate confidence.
- **Highly sustained/one-pointed:** persistence must be high and switching low.

Expected ranges are encoded in unit tests. A contradiction fixture must demonstrate lower confidence and visible contradiction text compared with a consistent fixture.

