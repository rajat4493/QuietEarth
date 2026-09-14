import Foundation
@testable import ProjectStill

enum ExternalAIFixture {
    static func payload(
        scores: [AttentionDimension: Double] = [:],
        behavioralSummary: String = "Behavior shows a stable mix of switching and persistence.",
        dimensions: [AttentionDimension] = AttentionDimension.allCases,
        overallConfidence: Double = 0.8
    ) -> ExternalAIProfilePayload {
        ExternalAIProfilePayload(
            schemaVersion: 1,
            selfReportSummary: "The user describes attention as inconsistent.",
            behavioralSummary: behavioralSummary,
            dimensions: dimensions.map { dimension in
                ExternalAIDimension(
                    name: name(for: dimension),
                    score: scores[dimension] ?? 0.5,
                    confidence: 0.85,
                    evidenceSummary: "Observed evidence for \(dimension.title.lowercased()).",
                    counterEvidence: "None found."
                )
            },
            keyDisagreements: ["Self-description may understate context-specific persistence."],
            alternativeInterpretations: [
                ExternalAIAlternative(
                    label: "Generalized weak concentration",
                    confidence: 0.3,
                    reason: "Possible, but it does not explain sustained engagement."
                )
            ],
            overallConfidence: overallConfidence,
            limitations: ["Conversation behavior is only one context."]
        )
    }

    static func json(from payload: ExternalAIProfilePayload) throws -> String {
        let data = try JSONEncoder().encode(payload)
        return String(decoding: data, as: UTF8.self)
    }

    private static func name(for dimension: AttentionDimension) -> String {
        ExternalAIProfileParser.dimensionNames.first { $0.value == dimension }!.key
    }
}

