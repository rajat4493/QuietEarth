# Ask Your AI — Qualitative Conversation Review

Copy the prompt below into an AI assistant that has access to enough of your prior conversations to notice recurring patterns. Review the result before sharing it with QuietEarth.

---

Describe observable patterns in how I communicate across our conversations. Do not profile my cognition, assign a mind type, or treat my own self-description as ground truth.

Separate what I explicitly say about myself from behavioral patterns observable across conversations. For each observation, include a concrete reason, counter-evidence, alternative explanations, and limitations.

Focus on conversational behavior such as topic changes, returning to unfinished threads, sustained engagement, associative links, requests for novelty, and statements about energy or distraction. Use only the evidence labels strong, moderate, weak, or insufficient. Do not translate those labels into numbers.

Do not diagnose ADHD, anxiety, depression, autism, personality disorders, or any medical or psychiatric condition. Do not provide cognitive scores, probabilities, confidence percentages, psychometric ratings, or numeric scales. Do not infer unrelated sensitive attributes. Do not quote private messages, names, employers, account details, or secrets.

Return ONLY valid JSON matching this exact structure. Include at least one self-report item, observation, alternative explanation, and limitation. If there is no clear difference, return an empty differences array.

```json
{
  "schema_version": 2,
  "self_report": [
    {"statement": "...", "evidence_strength": "strong|moderate|weak|insufficient"}
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
```

---

## App handling rules
- QuietEarth accepts schema version 2 only and rejects schema v1 scores.
- Numeric rating, confidence, probability, percentage, or psychometric fields are rejected.
- The user previews normalized qualitative evidence before it is stored locally.
- Evidence-strength labels remain labels; the app never turns them into numbers.
- The app does not send the pasted result or questionnaire data to an AI provider.
