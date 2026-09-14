import Foundation
@testable import ProjectStill

enum ExternalAIFixture {
    static func payload(
        observations: [ExternalAIObservation] = [branchingObservation()],
        selfReport: [ExternalAISelfReport] = [
            ExternalAISelfReport(statement: "I say I cannot focus.", evidenceStrength: .moderate)
        ],
        differences: [String] = ["The self-description understates sustained engagement on some subjects."],
        alternatives: [String] = ["Generalized weak concentration — possible, but it does not explain sustained engagement."],
        limitations: [String] = ["Conversation behavior is only one context."],
        schemaVersion: Int = 2
    ) -> ExternalAIPayload {
        ExternalAIPayload(
            schemaVersion: schemaVersion,
            selfReport: selfReport,
            observations: observations,
            differences: differences,
            alternativeExplanations: alternatives,
            limitations: limitations
        )
    }

    static func branchingObservation(strength: EvidenceStrength = .strong) -> ExternalAIObservation {
        ExternalAIObservation(
            pattern: "Often opens adjacent lines of inquiry before closing the original one.",
            evidenceStrength: strength,
            reason: "Follow-up questions frequently introduce a related topic before the first is resolved.",
            counterpoint: "On narrowly scoped requests the original thread is usually finished first."
        )
    }

    static func depthObservation(strength: EvidenceStrength = .strong) -> ExternalAIObservation {
        ExternalAIObservation(
            pattern: "Some subjects produce much deeper and longer sustained engagement than others.",
            evidenceStrength: strength,
            reason: "A few topics run across long exchanges without the thread being dropped.",
            counterpoint: "Routine requests end quickly."
        )
    }

    static func json(from payload: ExternalAIPayload) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        return String(decoding: data, as: UTF8.self)
    }

    /// Observations as the app stores them, already filed under a theme.
    static func observations(
        _ items: [(ExternalAIObservation, AttentionTheme?)],
        provider: AIProvider = .chatGPT
    ) -> [ExternalObservation] {
        items.enumerated().map { index, entry in
            ExternalObservation(
                id: "external.\(provider.rawValue).\(index)",
                pattern: entry.0.pattern,
                reason: entry.0.reason,
                counterpoint: entry.0.counterpoint,
                strength: entry.0.evidenceStrength,
                theme: entry.1,
                provider: provider,
                approvedAt: .distantPast,
                userApprovedNote: nil
            )
        }
    }
}
