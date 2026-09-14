import Foundation

enum ExternalAIPrompt {
    /// Schema version 2 (M1.6). Asks for observable conversational behaviour
    /// with ordinal evidence strength. It never asks the assistant to rate,
    /// score, or assess the user.
    static let text = #"""
Look across our conversations and describe observable patterns in how I interact with you.

Do not diagnose or assess my mental health, cognition, attention disorder, personality, or any medical or psychiatric condition.

Do not assign numerical scores, probabilities, percentiles, clinical labels, or psychometric-style ratings.

Do not assume that what I say about myself is necessarily accurate. Keep my self-description separate from patterns you can actually observe in our conversations.

Focus only on conversational behavior that you can reasonably observe, such as:

* whether I tend to stay with one topic or open related branches
* whether I return to earlier ideas after exploring something else
* whether some subjects produce much deeper or longer engagement than others
* whether I frequently ask to compress, simplify, expand, challenge, or reframe information
* whether I revisit conclusions after they appear settled
* whether I make connections between apparently separate subjects
* whether my interaction style seems different depending on the type of task
* how often I notice and question my own assumptions or your interpretation of me

For each observation:

1. State the observable pattern.
2. Explain briefly what in the conversational behavior supports it, without quoting private messages.
3. Give any meaningful counter-example or alternative explanation.
4. Mark the evidence as one of:
   * strong
   * moderate
   * weak
   * insufficient

Do not infer anything that cannot reasonably be observed from conversation.

Do not include names, employers, private facts, account information, health information, financial information, relationships, or unrelated sensitive details.

Return valid JSON only in this structure:

{
  "schema_version": 2,
  "self_report": [
    { "statement": "...", "evidence_strength": "strong|moderate|weak|insufficient" }
  ],
  "observations": [
    {
      "pattern": "...",
      "evidence_strength": "strong|moderate|weak|insufficient",
      "reason": "...",
      "counterpoint": "..."
    }
  ],
  "differences_between_self_report_and_observation": ["..."],
  "alternative_explanations": ["..."],
  "limitations": ["..."]
}
"""#
}
