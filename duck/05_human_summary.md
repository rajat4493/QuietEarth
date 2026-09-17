# TheDuck — Human Summary

M4–M7 close the core loop, which until now was open: the app could form a hypothesis but never test one. It can now choose a short practice from your profile with deterministic rules and say why in plain evidence statements, run that practice as a quiet timed session with no audio, streaks or badges, take a three-tap reflection afterwards, and at day seven compare what it predicted against what you actually reported. The verdict can be "we were wrong" or "not enough to say", and a hypothesis cannot change on fewer than four completed sessions. Settings now has a real delete-everything, covering the settings and note that previous milestones left behind.

None of it has been compiled. It was written in a Linux container with no Xcode, so the four new test suites have never run and no screenshots exist. Per TheDuck that means M4–M7 are incomplete until someone runs them on a Mac; expect compile errors on the first pass. See `duck/m4_m7_core_loop.md`.

Earlier update: visual design remains unapproved following user feedback. A wallpaper did not establish a complete theme. Appearance is now configurable (system/light/dark and optional landscape), and future visual work is separated from evidence logic. M3 adds a saved, editable user perspective alongside the profile. Practice recommendation/session/adaptation features remain future milestones. See `duck/m3_profile_review.md`.

Visual update: the public identity is now QuietEarth, with a bundled still mountain landscape, neutral reading surfaces, lighter responsive typography, and corrected dark-mode action contrast. Continuous decorative animation and unavailable import placeholders are removed. See `duck/evidence/M1.6/visual-final.md` for current screenshots, asset provenance, and verification limits.

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
