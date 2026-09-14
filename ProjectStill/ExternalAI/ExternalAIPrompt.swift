import Foundation

enum ExternalAIPrompt {
    static let text = #"""
Analyze my conversational behavior specifically for how my attention appears to operate. Do not treat my own self-description as ground truth.

Separate what I explicitly say about myself from behavioral patterns observable across conversations. For each conclusion, look for counter-evidence, alternative explanations, and limitations.

Assess only these dimensions: attentional switching, focus persistence, associative branching, disengagement difficulty, novelty dependence, emotional capture, energy/dullness (higher means more dull or low-energy), low-stimulation tolerance, metacognitive noticing, and sensory orientation.

Do not diagnose ADHD, anxiety, depression, autism, personality disorders, or any medical or psychiatric condition. Do not infer unrelated sensitive attributes. Do not quote private messages, names, employers, account details, or secrets. If evidence is weak, say “insufficient evidence.”

Return ONLY valid JSON matching this structure, with every dimension exactly once and all scores/confidence values between 0 and 1:

{
  "schema_version": 1,
  "self_report_summary": "...",
  "behavioral_summary": "...",
  "dimensions": [
    {"name":"attentional_switching","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"focus_persistence","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"associative_branching","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"disengagement_difficulty","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"novelty_dependence","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"emotional_capture","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"energy_dullness","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"low_stimulation_tolerance","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"metacognitive_noticing","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."},
    {"name":"sensory_orientation","score":0.0,"confidence":0.0,"evidence_summary":"...","counter_evidence":"..."}
  ],
  "key_disagreements": ["..."],
  "alternative_interpretations": [{"label":"...","confidence":0.0,"reason":"..."}],
  "overall_confidence": 0.0,
  "limitations": ["..."]
}
"""#
}

