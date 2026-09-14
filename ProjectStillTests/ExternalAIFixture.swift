import Foundation
@testable import ProjectStill

enum ExternalAIFixture {
    static func payload(
        differences: [String] = ["Self-report emphasizes weak focus, while conversation shows sustained engagement when personally interested."],
        observationPattern: String = "The user often changes topics, then returns to an earlier thread and develops it in depth."
    ) -> ExternalAIProfilePayload {
        ExternalAIProfilePayload(
            schemaVersion: 2,
            selfReport: [
                ExternalAISelfReport(
                    statement: "The user frequently says they cannot stay focused.",
                    evidenceStrength: .strong
                )
            ],
            observations: [
                ExternalAIObservation(
                    pattern: observationPattern,
                    evidenceStrength: .moderate,
                    reason: "Several conversations contain long, detailed follow-through after an initial topic change.",
                    counterpoint: "The sample mostly covers topics the user chose and may not represent routine tasks."
                )
            ],
            differencesBetweenSelfReportAndObservation: differences,
            alternativeExplanations: [
                "Interest and context may explain the difference better than a general concentration trait."
            ],
            limitations: ["Conversation behavior represents only one setting."]
        )
    }

    static func json(from payload: ExternalAIProfilePayload) throws -> String {
        let data = try JSONEncoder().encode(payload)
        return String(decoding: data, as: UTF8.self)
    }
}
