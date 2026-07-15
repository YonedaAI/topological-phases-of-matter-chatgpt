# Claude Haskell review, round 1

Reviewer: Claude Opus, high effort, read-only (`Read`, `Glob`, `Grep`)

## Findings

Claude verified by inspection the SSH Bloch spectrum, the arbitrary-sign gap
formula, the exact constant-gap symmetry-breaking detour, incremental-phase
branch handling, relative orientation, the three-arrow distinction, explicit
exports and signatures, and the meaningful finite proof checks.

1. **Medium:** `numericWinding` could silently alias a near-critical winding
   when the momentum mesh was too coarse for the inverse-gap phase-variation
   scale. Add a sampling-adequacy check; apply a branch-ambiguity check to the
   local transition degree too.
2. **Medium:** classification functions did not reject `NaN` or infinite model
   parameters, so invalid data could be classified as winding zero. Add finite
   input validation.
3. **Low:** strengthen the properties with trivial, negative-hopping,
   broken-symmetry, gapless, undersampled, and non-finite cases. Replace a
   string-membership check with a semantic disjointness invariant.
4. **Low:** guard the internal zero-sample momentum helper against division by
   zero.

## Required disposition

All four findings are accepted for correction before round 2.

VERDICT: NEEDS_FIX
