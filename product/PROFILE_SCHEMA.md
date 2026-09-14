# Profile Schema

Implemented domain shape (abridged):

```swift
enum EvidenceSource: Codable {
    case questionnaire
    case externalAI(provider: AIProvider)
    case practiceOutcome
}

struct ObservedSignal: Identifiable, Codable {
    let id: String
    let source: EvidenceSource
    let questionID: String
    let dimension: AttentionDimension
    let direction: Double // -1...1
    let weight: Double // 0...1
    let confidence: Double // 0...1
    let timestamp: Date
    let category: EvidenceCategory
    let summary: String
    let userApprovedNote: String?
}

struct DimensionAssessment: Codable {
    let dimension: AttentionDimension
    let score: Double // 0...1
    let confidence: Double // 0...1
    let evidence: [ObservedSignal]
    let contradictions: [String]
}

struct AttentionProfile: Codable {
    let dimensions: [DimensionAssessment]
    let interpretation: ProfileInterpretation
    let overallConfidence: Double
    let sourceComparisons: [SourceComparison]?
    let alternativeInterpretations: [String]?
    let updatedAt: Date
}
```

## Critical parsing rule
External AI text must be accepted only after conversion into a strict local schema. Unknown fields are ignored. Free-form text is never interpreted as executable instructions.

## M1 implementation note
The questionnaire implementation establishes this evidence pipeline before external sources are introduced:

`QuestionAnswer → ObservedSignal → DimensionAssessment → ProfileInterpretation`

Each `ObservedSignal` retains a stable question identifier, direction, weight, evidence source, and user-facing summary. `DimensionAssessment` retains the contributing signals and explicit contradiction explanations. M1 also adds `sensoryOrientation` as a tenth dimension and defines `energyDullness` so higher values always represent greater dullness/low-energy tendency. See `duck/m1_scoring_model.md` for the implemented scoring and confidence rules.

## M2 implementation note
`ObservedSignal` now carries provider-aware provenance, confidence, timestamp, evidence category, and an optional user-approved note. Legacy M1 questionnaire signals decode into the expanded model with safe defaults. External schema and reconciliation rules are documented in `duck/m2_external_ai_schema.md`.
