---
reviewer: Claude
artifact: thermodynamic-gaps Haskell
round: 3
date: 2026-07-14
---

The round 2 blocker is resolved.

- `Gap` is now a non-record newtype with a private constructor.
- `unGap` is an ordinary pattern-matching function, so external record-update syntax cannot forge an invalid value.
- `mkGap` rejects NaN, infinities, zero, and negative values.
- The finite-list helpers and regression properties now reject non-finite values consistently.
- The reviewed functions are total, warning-clean by inspection, faithful to the paper's finite examples, and explicit that they do not prove a thermodynamic gap.

Nonblocking observations:

- Exporting `GapWitness(..)` leaves its provenance and status fields mutable by record update. A later opaque witness API could enforce stronger evidence hygiene.
- `uniformAtLeast` safely returns false for NaN but does not validate the sample list explicitly.
- `invalid == Nothing` could use `isNothing` as a style improvement.

No theorem overclaiming or new blocking defect was found.

VERDICT: PASS
