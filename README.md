# Product A — Adaptive Meditation MVP

This pack is the canonical MVP build handoff for Codex/Claude.

## Build intent
Create a native iPhone app that first forms an evidence-backed model of how a user's attention behaves, then assigns a short meditation experiment that fits the current pattern, then adapts based on observed outcomes.

Core loop:

Understand → Hypothesize → Practice → Verify → Adapt

The app must not diagnose mental-health conditions. It must distinguish self-report from observed evidence and competing interpretations.

## Entry point for coding agent
Read in this order:
1. `duck/00_human_intent.md`
2. `duck/01_scope_control.md`
3. `product/PRD.md`
4. `product/UX_FLOW.md`
5. `product/DESIGN_SYSTEM.md`
6. `product/PROFILE_SCHEMA.md`
7. `product/MEDITATION_ENGINE.md`
8. `product/CONTENT_AND_SAFETY.md`
9. `duck/02_ambiguity_challenge.md`
10. `duck/03_evidence_verification_ledger.md`
11. `duck/04_engineering_handover.md`
12. `duck/05_human_summary.md`
13. `duck/06_learning_capture.md`

## TheDuck completion rule
A milestone is not complete if its `/duck` evidence is missing or stale.
