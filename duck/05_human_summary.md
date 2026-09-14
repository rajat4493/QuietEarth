# TheDuck — Human Summary

We are building a small, serious meditation app that does not begin by telling everyone to breathe for ten minutes.

It first asks how the user's mind behaves, optionally lets the user bring in a privacy-preserving profile generated inside their own ChatGPT/Claude, and then shows where self-perception and observed behavior agree or disagree.

The app forms a provisional attention hypothesis, chooses a short 7-day practice experiment, explains why, and updates the model based on what actually happens.

Success for MVP is not “lots of meditations.” Success is that Client 0 can complete the full loop and feel that the app understood something real, challenged something questionable, prescribed something plausible, and learned from the result.

## Build status
M0 is complete. ProjectStill now opens as a native iPhone app with the Quiet Earth visual foundation and working routes from the opening screen to either a short explanation or the privacy-choice screen. The app clearly offers a questionnaire-only path before any conversation-derived evidence. No personal data is collected, stored, or sent in this milestone. Questionnaire behavior begins in M1 after milestone review.

M1 is complete. A user can now finish a 12–15 question adaptive intake and see a provisional profile made of individual attention dimensions, evidence statements, confidence, and visible contradictions. The app explains any broader interpretation instead of presenting it as a permanent type. Progress and completed profiles stay on the device and survive relaunch, and answers can be reviewed and changed. No AI import, external API, or meditation recommendation has been added.

M1.6 is complete and supersedes the first M2 inference model. A user can copy a constrained prompt into ChatGPT, Claude, or another assistant and paste back only the structured profile they approve. ProjectStill accepts qualitative schema-v2 evidence, rejects the old numeric schema and score-shaped prose, and keeps external observations separate from questionnaire scoring.

The profile now presents working hypotheses rather than conclusions. Each one exposes its basis, a counterpoint, a prediction, and what would weaken it. When self-report and conversation evidence differ, that contested claim appears first; neither view is averaged away and external evidence cannot mutate questionnaire dimensions. Everything remains on-device and removable. There is still no provider API, diagnosis, meditation recommendation, audio, analytics, or backend.

Verification is current: the app builds for the iPhone 16 Pro simulator, all 20 unit tests and all 6 UI tests pass, and light, dark, Reduce Motion, and seeded profile screenshots are stored under `duck/evidence/M1.6/`.
