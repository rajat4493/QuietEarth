# TheDuck — Human Summary

We are building a small, serious meditation app that does not begin by telling everyone to breathe for ten minutes.

It first asks how the user's mind behaves, optionally lets the user bring in a privacy-preserving profile generated inside their own ChatGPT/Claude, and then shows where self-perception and observed behavior agree or disagree.

The app forms a provisional attention hypothesis, chooses a short 7-day practice experiment, explains why, and updates the model based on what actually happens.

Success for MVP is not “lots of meditations.” Success is that Client 0 can complete the full loop and feel that the app understood something real, challenged something questionable, prescribed something plausible, and learned from the result.

## Build status
M0 is complete. ProjectStill now opens as a native iPhone app with the Quiet Earth visual foundation and working routes from the opening screen to either a short explanation or the privacy-choice screen. The app clearly offers a questionnaire-only path before any conversation-derived evidence. No personal data is collected, stored, or sent in this milestone. Questionnaire behavior begins in M1 after milestone review.

M1 is complete. A user can now finish a 12–15 question adaptive intake and see a provisional profile made of individual attention dimensions, evidence statements, confidence, and visible contradictions. The app explains any broader interpretation instead of presenting it as a permanent type. Progress and completed profiles stay on the device and survive relaunch, and answers can be reviewed and changed. No AI import, external API, or meditation recommendation has been added.

M2 is complete. A user can now copy a constrained analysis prompt into ChatGPT, Claude, or another assistant and paste back only the structured profile they approve. ProjectStill validates and previews that profile locally, marks every observation with its provider and confidence, and shows “How the two views compare.” Agreement, disagreement, alternatives, and source-specific scores remain visible. A realistic weak-self-reported-focus/strong-observed-persistence case produces “Capacity present, gating appears variable” rather than an averaged “medium focus.” AI evidence can be removed to restore the questionnaire-only result. The app still makes no external API call and provides no meditation recommendation.
