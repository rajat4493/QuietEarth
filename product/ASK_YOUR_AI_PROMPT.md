# Ask Your AI — User-Controlled Analysis Prompt

Copy the text below into an AI assistant that has access to enough of your prior conversations to analyze recurring patterns. Review its result before sharing anything with the app.

---

Analyze my conversational behavior specifically for how my attention appears to operate. Do not treat my own self-description as ground truth.

Separate:
1. what I explicitly say about myself,
2. behavioral patterns observable across my conversations,
3. evidence that contradicts each major interpretation,
4. alternative explanations,
5. confidence and limitations.

Assess only these dimensions:
- attentional switching
- persistence once engaged
- associative branching
- ease of disengaging from a topic
- novelty dependence
- emotional capture
- low-energy/dullness tendency
- tolerance for low-stimulation tasks
- metacognitive noticing/self-correction

Important constraints:
- Do not diagnose ADHD, anxiety, depression, autism, personality disorders, or any medical/psychiatric condition.
- Do not infer race, religion, sexuality, politics, health conditions, finances, or other unrelated sensitive attributes.
- Do not quote private messages, names, employers, account details, or secrets.
- Do not summarize unrelated parts of my life.
- For every major conclusion, actively search for counter-evidence.
- If evidence is weak or contradictory, say “insufficient evidence.”

Return ONLY valid JSON in this structure:

{
  "self_report_summary": "...",
  "behavioral_summary": "...",
  "dimensions": [
    {
      "name": "attentional_switching",
      "score": 0.0,
      "confidence": 0.0,
      "evidence_summary": "...",
      "counter_evidence": "..."
    }
  ],
  "key_disagreements": ["..."],
  "alternative_interpretations": [
    {"label": "...", "confidence": 0.0, "reason": "..."}
  ],
  "overall_confidence": 0.0,
  "limitations": ["..."]
}

Scores and confidence must be between 0 and 1.
---
