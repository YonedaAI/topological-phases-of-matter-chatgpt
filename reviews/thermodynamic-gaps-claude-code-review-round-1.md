---
reviewer: Claude
artifact: thermodynamic-gaps Haskell
round: 1
date: 2026-07-14
---

The finite computations match the paper's examples, remain honestly scoped, and appear warning-clean. The reviewer identified the following nonblocking improvements:

- `GapPredicate` admitted a literal-ground-state witness even though the paper's quantitative witness uses only a selected band or bulk GNS predicate.
- `GapWitness` omitted the evidence status field emphasized by the paper.
- Exporting the `Gap` constructor allowed callers to bypass its positive finite invariant.
- Spectrum functions should reject NaN and infinite inputs before sorting.
- The ferromagnetic expression `1 - cos(pi/L)` suffers cancellation for very large `L`; the half-angle formula is stable.
- Exact `Double` equality in two tests was brittle.
- Two properties used `last` where total structure could be explicit.
- `commonFiniteLowerBound` lacked an executable property.

The reviewer found no misleading theorem claim and judged the code faithful and total on its tested domain.

VERDICT: PASS
