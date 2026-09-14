# M3 profile review increment

Added an explicitly user-authored “My perspective” note with Save, Cancel, edit, and clear-to-remove. The note is capped at 2,000 characters and stored locally in UserDefaults, separately from questionnaire and external evidence. It survives relaunch. It is global to the current local user, not attached to a historical profile version. It does not change scores, confidence, imported observations, or hypotheses. Answer revision remains the route for recalculation.

Appearance is replaceable through the design-system file: semantic color roles, typography, spacing, card geometry, and the landscape asset reference are centralized. Saved settings offer system/light/dark presentation and an optional welcome landscape (off by default). These settings are available from both welcome and profile and do not affect domain logic. This is a foundation for replacing the theme, not a claim that multiple finished brand themes exist. Some view-specific spacing and geometry remain local.

## Scope and status

This increment advances M3. It does not implement practice recommendations, sessions, or seven-day adaptation. Those remain M4–M6 and require their own deterministic rules and verification.

The user rejected the visual direction as wallpaper rather than a coherent theme. Visual design is **not approved**. Previous “visual completion” language is superseded. Further redesign should replace presentation tokens and components without changing evidence logic.

## Privacy and limitations

No network path or new dependency added. UserDefaults stores the note and appearance settings on the device. Global reset must include `profile.userPerspective`, `appearance.mode`, and `appearance.landscape`; user-facing global reset remains outstanding. Text editor changes are a draft until Save and may be lost if the app closes before saving.

## Verification

Xcode simulator build passed. The focused UI regression for saving the note and reopening the app passed on iPhone 16 Pro / iOS 18.1. Original evidence is preserved structurally: the note is not an input to the profile engine. Note deletion and appearance persistence were not independently automated in this increment.
