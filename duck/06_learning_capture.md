# TheDuck — Project Learning Capture

## Learning hypotheses for TheDuck itself
- Forced separation between self-report and observed evidence reduces sycophantic product logic.
- Scope guardrails should explicitly prevent “content library” creep in consumer wellness builds.
- Privacy architecture should be captured as product behavior, not merely compliance text.
- Evidence ledgers should verify claims such as “local-first” through network inspection, not documentation alone.
- Ancient/academic source claims need a provenance checklist to prevent coding agents from inventing authority.

## At each milestone record
- What assumption was disproved?
- What did Client 0 find confusing?
- What did the agent overbuild?
- What was omitted despite being in intent?
- What new reusable TheDuck rule should be added?

## M1.6 — what we learned when a model refused

**What assumption was disproved?**
That a disclaimer neutralises a method. We assumed "do not diagnose ADHD" made a ten-construct
numeric rating request safe. It did not: the *shape* of the request — named cognitive constructs,
numeric severity, confidence weighting, required full coverage — is a screening instrument regardless
of the sentence attached to it. A frontier model declining the prompt surfaced a real methodological
weakness before any user did.

**What did the agent overbuild?**
Reconciliation arithmetic. A `0.18` agreement threshold, confidence multiplication, dispersion
penalties and weighted counter-evidence were all built on top of decimals an assistant had invented
from an impression. The machinery was sound; its inputs carried no information. Sophistication
downstream of a fabricated number produces confident nonsense, and it is expensive to unpick later
than it would have been to question early.

**What was omitted despite being in intent?**
Falsifiability. The intent always said "hypothesis, verified by practice", but the build had no
predictions and no disconfirmation conditions — nothing a week of sessions could actually refute.
Hypotheses now ship with both, or they do not ship.

**What did Client 0 find confusing?**
Nothing yet — this was caught before Client 0. That is the point worth keeping.

**New reusable TheDuck rules**
1. **Form is a claim.** Review the *shape* of what a product asks for, not only its wording. If the
   output would look at home in a clinical report, it is a clinical-looking output.
2. **Never render a number the product did not measure.** Precision must be earned by measurement.
   Ordinal words are the honest default where nothing was counted.
3. **No arithmetic on unmeasured values.** If a number cannot be defended at its source, no downstream
   threshold, weight, or comparison redeems it.
4. **A model's refusal is a design signal.** Treat it as a free review pass and investigate the method
   before reaching for a workaround prompt.
5. **Every claim about a person needs a stated way to be wrong,** and something in the product that
   can actually produce that disconfirmation.
6. **Calm is not the absence of energy.** Low saturation and low contrast read as tired, not serene —
   and they cost accessibility on the way.

**Process note from the M1.6 round**
The reset was written twice, in parallel, by two agents that could not see each other's work — one
locally with uncommitted changes, one in a cloud container that had only what was pushed. Nothing was
lost, but effort was. The reusable rule: **uncommitted work is invisible work.** Commit to a branch
before handing a task sideways, and before a session can run out of budget mid-refactor. A second
rule earned the same way: an agent should check what it can actually see before asking anyone to move
files around.
