import Foundation
import Testing
@testable import ProjectStill

struct ProfileEngineTests {
    private let engine = ProfileEngine()

    @Test("Scattered persona remains exploratory and traceable")
    func scatteredPersona() throws {
        let profile = engine.makeProfile(from: answers([
            "switching": "very_often", "persistence": "brief", "branching": "many",
            "disengagement": "easy", "novelty": "seek_change", "emotion": "brief",
            "dullness": "bright", "low_stimulation": "uncomfortable", "noticing": "late",
            "sensory": "words", "deadline": "fragments", "quiet_sit": "thoughts",
            "switching_followup": "late"
        ]))

        #expect(profile.assessment(for: .attentionalSwitching).score > 0.75)
        #expect(profile.assessment(for: .associativeBranching).score > 0.75)
        #expect(profile.assessment(for: .focusPersistence).score < 0.3)
        #expect(profile.interpretation.title == "Exploratory or intermittently focused")
        #expect(!profile.assessment(for: .attentionalSwitching).evidence.isEmpty)
    }

    @Test("Low-energy persona produces a high dullness range")
    func lowEnergyPersona() throws {
        let profile = engine.makeProfile(from: answers([
            "switching": "sometimes", "persistence": "short", "branching": "few",
            "disengagement": "mostly_easy", "novelty": "mostly_steady", "emotion": "brief",
            "dullness": "sleepy", "low_stimulation": "okay", "noticing": "soon",
            "sensory": "body", "deadline": "same", "quiet_sit": "sleepy",
            "dullness_followup": "little"
        ]))

        let dullness = profile.assessment(for: .energyDullness)
        #expect(dullness.score > 0.85)
        #expect(dullness.confidence > 0.7)
        #expect(profile.interpretation.title == "Low-energy or dull at times")
    }

    @Test("Sustained persona produces high persistence and low switching")
    func sustainedPersona() throws {
        let profile = engine.makeProfile(from: answers([
            "switching": "rarely", "persistence": "very_long", "branching": "single",
            "disengagement": "easy", "novelty": "steady", "emotion": "passes",
            "dullness": "bright", "low_stimulation": "comfortable", "noticing": "immediate",
            "sensory": "senses", "deadline": "locks", "quiet_sit": "settled",
            "sustained_followup": "easy"
        ]))

        #expect(profile.assessment(for: .focusPersistence).score > 0.85)
        #expect(profile.assessment(for: .attentionalSwitching).score < 0.15)
        #expect(profile.interpretation.title == "Naturally sustained or one-pointed")
    }

    @Test("Contradiction stays visible and lowers confidence")
    func contradictionPenalty() throws {
        let contradictory = engine.makeProfile(from: answers([
            "switching": "very_often", "deadline": "locks", "switching_followup": "often"
        ])).assessment(for: .attentionalSwitching)
        let consistent = engine.makeProfile(from: answers([
            "switching": "very_often", "deadline": "fragments", "switching_followup": "often"
        ])).assessment(for: .attentionalSwitching)

        #expect(!contradictory.contradictions.isEmpty)
        #expect(contradictory.confidence < consistent.confidence)
        #expect(contradictory.evidence.count == 3)
    }

    @Test("Adaptive questionnaire remains within the 12 to 15 question boundary")
    func adaptiveQuestionCount() {
        #expect(QuestionnaireBank.questions(for: []).count == 12)

        let allFollowUps = answers([
            "switching": "very_often",
            "persistence": "very_long",
            "dullness": "sleepy"
        ])
        let questions = QuestionnaireBank.questions(for: allFollowUps)
        #expect(questions.count == 15)
        #expect(questions.map(\.id).suffix(3) == [
            "switching_followup", "dullness_followup", "sustained_followup"
        ])
    }

    private func answers(_ selections: [String: String]) -> [QuestionAnswer] {
        selections.map { questionID, optionID in
            QuestionAnswer(questionID: questionID, optionID: optionID, answeredAt: .distantPast)
        }
    }
}
