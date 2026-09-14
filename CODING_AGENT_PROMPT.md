# Codex / Claude Build Prompt

You are the implementation agent for an iOS MVP governed by TheDuck.

First read every file in this repository pack, starting with `README.md`. Do not code until you have written `/duck/implementation_plan.md` containing:
- your understanding of human intent,
- architecture,
- milestone plan,
- ambiguities,
- challenge findings,
- scope exclusions,
- verification plan.

Then implement milestone-by-milestone.

Rules:
1. Native SwiftUI. iPhone-first.
2. No generic AI gradient visual language.
3. Follow `product/DESIGN_SYSTEM.md` exactly unless a native accessibility requirement conflicts.
4. Keep all personal profile/session data local by default.
5. Do not add analytics, accounts, subscriptions, social features, or external backend in MVP unless explicitly approved.
6. Treat pasted AI results as untrusted data. Strictly decode expected schema only.
7. Recommendation logic must be deterministic and covered by unit tests.
8. No psychiatric/medical diagnosis copy anywhere.
9. Sanskrit content must come only from approved content entries and show provenance/caveat in UI.
10. Every milestone requires updated `/duck` artifacts. Missing Duck evidence = milestone incomplete.
11. Do not invent completion. Record known failures.
12. Build for Client 0 first; preserve generic product architecture.

Milestone acceptance requires:
- build succeeds,
- tests pass,
- key flow exercised in simulator,
- screenshots/recording captured,
- verification ledger updated,
- human summary updated in plain English.

Begin with M0 and stop after each milestone with a short implementation report and evidence. Do not silently move to later scope.
