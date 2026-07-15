# Claude Lean review, round 2

Scope: final Paper 3 Lean files after the first review observations were addressed.

## Confirmed fixes

- Both finite-gap structures now state that a concrete instantiation must use the genuine spectral distance.
- `GNSGapWitness` is quantitative data over an abstract bulk-gap predicate.
- `GNSGapTheoremInterface` remains an uninstantiated provider interface.
- Spectral-flow and controlled LTQO stability inputs and conclusions remain explicit and unchanged.
- No global axiom, `sorry`, `admit`, provider instance, default proof field, or fabricated analytic proof was found.

## Finding

1. Required fix: `GNSGapTheoremInterface.derive` accepted hypotheses for one input system but returned a `GNSGapWitness` whose internal `system` field could name a different system. This made the hypotheses logically inert for a constant provider. The result must be indexed by, or otherwise prove equality with, the exact input system.
2. Minor: add a toy `GNSGapWitness` data value to exercise the result type, while continuing to leave the analytic interface uninstantiated.

VERDICT: NEEDS_FIX
