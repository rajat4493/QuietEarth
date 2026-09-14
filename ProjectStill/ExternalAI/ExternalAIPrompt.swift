import Foundation

enum ExternalAIPrompt {
    static let text = #"""
Describe observable patterns in how I communicate across our conversations. Do not profile my cognition, assign a mind type, or treat my own self-description as ground truth.

Separate what I explicitly say about myself from behavioral patterns observable across conversations. For each conclusion, look for counter-evidence, alternative explanations, and limitations.

Focus on concrete conversational behavior such as topic changes, returning to unfinished threads, sustained engagement, associative links, requests for novelty, and statements about energy or distraction. Use only the evidence labels strong, moderate, weak, or insufficient. Do not translate those labels into numbers.

Do not diagnose ADHD, anxiety, depression, autism, personality disorders, or any medical or psychiatric condition. Do not provide cognitive scores, probabilities, confidence percentages, psychometric ratings, or numeric scales. Do not infer unrelated sensitive attributes. Do not quote private messages, names, employers, account details, or secrets.

Return ONLY valid JSON matching this exact qualitative structure. Include at least one self-report item, observation, alternative explanation, and limitation. If there is no clear difference, return an empty differences array.

{
  "schema_version": 2,
  "self_report": [
    {"statement":"...","evidence_strength":"strong|moderate|weak|insufficient"}
  ],
  "observations": [
    {"pattern":"...","evidence_strength":"strong|moderate|weak|insufficient","reason":"...","counterpoint":"..."}
  ],
  "differences_between_self_report_and_observation": ["..."],
  "alternative_explanations": ["..."],
  "limitations": ["..."]
}
"""#
}
