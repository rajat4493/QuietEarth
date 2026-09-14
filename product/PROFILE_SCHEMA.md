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
    let externalEvidence: ExternalEvidenceBundle?
    let updatedAt: Date
}
```

## Critical parsing rule
External AI text must be accepted only after conversion into a strict local schema. Unknown fields are ignored. Free-form text is never interpreted as executable instructions.

## M1 implementation note
The questionnaire implementation establishes this evidence pipeline before external sources are introduced:

`QuestionAnswer → ObservedSignal → DimensionAssessment → ProfileInterpretation`

Each `ObservedSignal` retains a stable question identifier, direction, weight, evidence source, and user-facing summary. `DimensionAssessment` retains the contributing signals and explicit contradiction explanations. M1 also adds `sensoryOrientation` as a tenth dimension and defines `energyDullness` so higher values always represent greater dullness/low-energy tendency. See `duck/m1_scoring_model.md` for the implemented scoring and confidence rules.

## M1.6 inference reset
Questionnaire weights remain a private deterministic implementation detail and are presented as qualitative bands/evidence strength. External AI observations use separate `QualitativeEvidenceRecord` values with provider provenance, timestamp, category, strength label, statement, reason, counterpoint, and optional approved note.

External evidence never becomes an `ObservedSignal`, never receives a direction or weight, and never changes questionnaire scores. The shared product boundary is qualitative evidence; only the questionnaire engine retains its internal numeric implementation. External schema and comparison rules are documented in `duck/m2_external_ai_schema.md`.
