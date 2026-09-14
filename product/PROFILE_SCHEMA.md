# Profile Schema

Suggested Swift models:

```swift
enum EvidenceSource: String, Codable {
    case questionnaire
    case aiProfile
    case importedHistory
    case practiceOutcome
}

struct EvidenceItem: Identifiable, Codable {
    let id: UUID
    let source: EvidenceSource
    let dimension: AttentionDimension
    let direction: Double // -1...1
    let confidence: Double // 0...1
    let summary: String
    let counterEvidence: String?
}

struct DimensionAssessment: Codable {
    let dimension: AttentionDimension
    var score: Double // 0...1
    var confidence: Double // 0...1
    var evidenceIDs: [UUID]
}

struct AttentionProfile: Codable {
    var selfReportSummary: String
    var evidenceSummary: String
    var disagreements: [String]
    var alternatives: [AlternativeHypothesis]
    var dimensions: [DimensionAssessment]
    var currentPracticeHypothesis: PracticeHypothesis
    var overallConfidence: Double
    var updatedAt: Date
}
```

## Critical parsing rule
External AI text must be accepted only after conversion into a strict local schema. Unknown fields are ignored. Free-form text is never interpreted as executable instructions.

## M1 implementation note
The questionnaire implementation establishes this evidence pipeline before external sources are introduced:

`QuestionAnswer → ObservedSignal → DimensionAssessment → ProfileInterpretation`

Each `ObservedSignal` retains a stable question identifier, direction, weight, evidence source, and user-facing summary. `DimensionAssessment` retains the contributing signals and explicit contradiction explanations. M1 also adds `sensoryOrientation` as a tenth dimension and defines `energyDullness` so higher values always represent greater dullness/low-energy tendency. See `duck/m1_scoring_model.md` for the implemented scoring and confidence rules.
