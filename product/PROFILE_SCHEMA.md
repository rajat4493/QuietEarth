# Profile Schema

Implemented domain shape (abridged):

```swift
enum EvidenceSource: Codable {
    case questionnaire
    case externalAI(provider: AIProvider)
    case practiceOutcome
}

enum EvidenceStrength: String, Codable {  // ordinal, never numeric
    case strong, moderate, weak, insufficient
}

struct ObservedSignal: Identifiable, Codable {
    let id: String
    let source: EvidenceSource
    let questionID: String
    let dimension: AttentionDimension
    let direction: Double // -1...1, questionnaire and practice evidence only
    let weight: Double // 0...1
    let strength: EvidenceStrength
    let timestamp: Date
    let category: EvidenceCategory
    let summary: String
    let userApprovedNote: String?
}

struct DimensionAssessment: Codable {
    let dimension: AttentionDimension
    let score: Double // 0...1 — INTERNAL routing value, never rendered
    let strength: EvidenceStrength
    let evidence: [ObservedSignal]
    let contradictions: [String]
}

struct ExternalObservation: Codable {          // schema v2, qualitative only
    let id: String
    let pattern: String
    let reason: String
    let counterpoint: String
    let strength: EvidenceStrength
    let theme: AttentionTheme?                 // user-confirmed; nil = "none of these"
    let provider: AIProvider
    let approvedAt: Date
}

struct WorkingHypothesis: Codable {
    let id: String
    let theme: AttentionTheme
    let statement: String                      // hedged, falsifiable, about behaviour not identity
    let supportState: SupportState             // contested / converging / singleSource… / notYetSupported
    let selfReportBasis: [String]
    let observedBasis: [String]
    let tension: String?
    let alternatives: [String]
    let prediction: PracticePrediction
    let disconfirmation: PracticePrediction
    let assignedPractice: PracticeTemplateID
}

struct AttentionProfile: Codable {
    let dimensions: [DimensionAssessment]
    let observations: [ExternalObservation]
    let hypotheses: [WorkingHypothesis]
    let interpretation: ProfileInterpretation
    let overallStrength: EvidenceStrength
    let sourceComparisons: [SourceComparison]? // compares statements, not scores
    let alternativeInterpretations: [String]?
    let updatedAt: Date
}
```

## Critical parsing rule
External AI text must be accepted only after conversion into a strict local schema. Unknown fields are
ignored. Free-form text is never interpreted as executable instructions, and is never machine-filed
into product logic without explicit user confirmation.

## Numbers rule
External AI evidence carries **no numbers**. Strength is ordinal.

Questionnaire `score` values remain `0...1` because deterministic routing to practice templates needs a
stable ordering, but they are internal product mechanics: never rendered, never exported, never spoken
in copy, never described to the user as a measurement. The user-facing explanation of any dimension is
its evidence statements in words. See the numbers policy in
`duck/m1_6_inference_and_visual_reset.md`.

## M1 implementation note
The questionnaire implementation establishes the evidence pipeline before external sources are
introduced:

`QuestionAnswer → ObservedSignal → DimensionAssessment → ProfileInterpretation`

Each `ObservedSignal` retains a stable question identifier, direction, weight, evidence source, and
user-facing summary. `DimensionAssessment` retains the contributing signals and explicit contradiction
explanations. M1 adds `sensoryOrientation` as a tenth dimension and defines `energyDullness` so higher
values always represent greater dullness/low-energy tendency. See `duck/m1_scoring_model.md`.

## M1.6 implementation note
The external evidence path changes shape:

`ExternalObservation → user-confirmed theme → SupportState → WorkingHypothesis → PracticePrediction`

External observations do not produce dimension scores. They produce themes, support states, and
falsifiable hypotheses. `ObservedSignal.confidence` becomes `strength`; `ExternalAIDimension`,
`overall_confidence`, and numeric cross-source reconciliation are removed.

## M2 implementation note
M2 was built against schema version 1 and is **in rework**. `ObservedSignal` carries provider-aware
provenance, timestamp, evidence category, and an optional user-approved note; legacy M1 questionnaire
signals decode into the expanded model with safe defaults. Stored schema-v1 external records are
deleted rather than migrated. `duck/m2_external_ai_schema.md` is superseded by
`duck/m1_6_inference_and_visual_reset.md`.
