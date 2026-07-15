Compilation is clean under `-Wall -Wextra -Werror` (GHC 9.14.1). Static review complete. Findings below.

## Review: `src/invertible-condensed-phase-spectrum/`

### Compiler hygiene — OK
`Makefile:2` sets `-Wall -Wextra -Werror -O0`; a `-fno-code` typecheck of all four modules produces zero warnings. Explicit export lists, no partial functions (`head`/`fromJust`), the single `case` on `thomDegree` (`Core.hs:194`) is exhaustive, and the only import (`Data.Maybe (isNothing)`, `Core.hs:19`) is used. Totality and type safety are sound.

### Honesty of scope — OK, with a naming nit
`README.md:4-6` explicitly disclaims proving Lieb-Robinson, spectral gaps, or comparison theorems, and the `Status` type (`Core.hs:21-27`: `Established/Proposed/Conjectural/Open/Obstructed`) is a genuine finite status contract. However `Proofs.hs` / `ProofCheck` / `proofName` / `proofPassed` present unit checks (e.g. `Proofs.hs:54` "adjacentPairs computes the four arrows…") as "proofs." These are computational status checks, not proofs. The README mitigates this, so it is a minor naming concern, not a scope-honesty failure.

### Finding 1 — Duplicate arrows are NOT detected (correctness gap)
`Core.hs:132-140`. The sequence check tests set membership with `notElem` in both directions, so it only verifies that the *set* of arrow endpoint-pairs equals the *set* of expected pairs. Multiplicity is ignored. A `Program` whose `programArrows` contains two identical assembly arrows (e.g. two `LocalQuantumInteractions → CondensedHamiltonianModuli` arrows) passes: the duplicate is a member of `expectedPairs` (no error from direction 1), and every expected pair is still present (no error from direction 2). `providerErrors`/`statusErrors` also pass for a well-formed duplicate. Net: `isValid` returns `True` for a program that violates the "exactly these four assembly arrows" contract. Missing arrows *are* caught (direction 2, `Core.hs:137-140`), but the task's explicitly-flagged duplicate case is not.

### Finding 2 — Arrow validation rules have zero negative-test coverage (test-strength gap)
`Properties.hs:117-167`. Of the 13 `ValidationError` constructors, these are never exercised by any check:
- `ArrowSequenceMismatch` (`Core.hs:88`) — no test for a wrong-order or missing arrow.
- `ArrowMissingProvider` (`Core.hs:89`) — no test for an arrow with `arrowProvider = Nothing`.
- `EstablishedAssemblyArrow` (`Core.hs:90`) — no test that an assembly arrow marked `Established` is rejected (`Core.hs:146-150`).
- `NegativeCodimension` (`Core.hs:95`) — no test for `codimension < 0`.
- `ThomDegreeMismatch` (`Core.hs:96`) — never triggered in isolation and never asserted.

The arrow rules are precisely the area the task emphasizes ("duplicate or missing arrow detection"), yet regressions to `sequenceErrors`, `providerErrors`, or `statusErrors` in `validateProgram` would pass all checks silently.

### Finding 3 — Bundled negative tests do not isolate the rule under test
- `unsupportedEquivalence` (`Properties.hs:93-99`) is `Equivalence` + `Open` + `Nothing`, which fires **both** `EquivalenceMissingTheorem` and `EquivalenceHasUnsupportedStatus` (`Core.hs:166-177`). The check at `Properties.hs:136-142` only asserts `not (isValid …)`, so it still passes if either rule is silently broken. No test isolates the status rule (Equivalence with theorem but non-`Established`/`Conjectural` status) or the theorem rule (Equivalence, `Conjectural`, no theorem).
- `badDegreeCharge` (`Properties.hs:102`) sets `relativeDegree = 2` while `invariantDegree = 2`, `codimension = 1`, `thomDegree = Just 2`. This fires **both** `RelativeDegreeMismatch` (expected 3) and `ThomDegreeMismatch` (expectedThom becomes `2 − 1 = 1 ≠ 2`). So the "raises degree by one" check (`Properties.hs:143-149`) does not isolate the degree rule.

The genuinely isolated negative tests are `badOrientationCharge`, `badPhysicalCharge`, `badDimensionProgram`, the witness-fibration check, and the stage-removal check.

### Finding 4 — Orientation check is skipped when `thomDegree = Nothing` (verify intent)
`Core.hs:193-203`. `UnorientedUntwistedThomTarget` is nested inside the `Just actual` branch of the `case`. A charge with `thomDegree = Nothing`, `normalBundleOriented = False`, `usesTwistedTarget = False` produces no orientation error. If the intended semantics is "orientation bookkeeping only applies once a Thom degree is asserted," this is correct by design; if unoriented/untwisted normal bundles should be flagged independently of whether the Thom degree is recorded, this is a coverage gap. Flagging for confirmation rather than asserting a bug — lower severity than 1–3.

### Correctly handled (for the record)
- `n = d + 1`: `Core.hs:156-161` checks `spacetimeDimension /= spatialDimension + 1`; negative-tested at `Properties.hs:114-115,164-166`. Correct.
- Physical-charge qualification: `Core.hs:204-208` requires `hasMicroscopicComparison` when `calledPhysical`; isolated negative test at `Properties.hs:111-112`. Correct.
- Relative-degree shift and Thom degree formula (`expectedRelative = invariantDegree + 1`, `expectedThom = relativeDegree − codimension`): `Core.hs:183,192`. Logic correct; positive-tested by `orientedCharge`/`twistedCharge` (`Proofs.hs:23-41,59-64`).
- Equivalence-provider accept path is positively tested (`Proofs.hs:43-49,65-67`).

Findings 1 and 2 are real gaps squarely inside the areas the task singled out (duplicate/missing arrow detection and negative-test strength).

VERDICT: FIXES REQUIRED
