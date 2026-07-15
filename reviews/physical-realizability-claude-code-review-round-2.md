All four files reviewed, plus the LaTeX correspondence. GHC 9.14.1 confirms a clean compile under the exact `-Wall -Wextra -Werror` flags (using `-fno-code`, so no source or build artifacts were touched).

## Review findings

**Prior advisory findings — all resolved:**

1. **Validator named `entryContractValid`** ✓ — Defined at `Realizability.hs:149-150` (`entryContractValid = null . validateEntry`), exported at line 17, and consumed in `Main.hs:9,51` for the `contract-valid=` column.
2. **Extension flag `invariantRestrictsFromBase`** ✓ — Field at `Realizability.hs:79`; drives the `ZeroByExtension` branch at line 172. This is the correct name and semantics: it matches the paper's Extension criterion (`prop:extension-criterion`, tex:770-775), where `Q_Σ(ν)` vanishes precisely when ν is the restriction of a class in `E^q(B)`.
3. **Extra OPEN row documented** ✓ — `openBordismEntry` (`Realizability.hs:246-258`, `Status = Open`) is explained in `README.md:9-12` as a deliberately contract-valid but non-realized row for the general Freed-Hopkins question.
4. **Partial record selectors on sum-type constructors removed** ✓ — Every multi-constructor type (`Status`, `GapWitness`, `ComparisonEvidence`, `RelativeResult`) uses positional fields only. Record syntax survives solely on single-constructor types (`Dimensions`, `SymmetryWitness`, `RealizationEntry`, `RelativeInput`), where the generated selectors are total.

**Strict-flags recheck:** `ghc -Wall -Wextra -Werror -fno-code -fforce-recomp` → exit 0, zero warnings. No unused imports (Main's import list is fully consumed; `Data.Char (isSpace)` feeds `nonBlank`), all top-level bindings carry signatures, and all case/guard analyses are exhaustive (`comparisonIsScoped`, `validGapWitness`, `relativeCharge`, `thomLocalizedDegree`). The Makefile applies these same flags plus `-O2`.

**Paper correspondence (`physical-realizability.tex`):**
- `connectingDegree = degree + 1` matches the connecting morphism `E^q(U)→E^{q+1}(B,U)` (tex:125-126, eq:relative-charge).
- `thomLocalizedDegree = degree + 1 − codimension`, gated on positive codimension, matches the Thom localization to degree `q+1−c` (thm:thom-charge, eq:thom-localization); the `excisionHypothesesHold && normalBundleIsOriented` guard matches the excision + orientation hypotheses.
- The three `Realized` rows reproduce the paper's table (tex:396-409): class-D Pfaffian parity / Spin-Arf ℤ₂, BDI ℤ₈ Pin⁻ Arf-Brown-Kervaire, AKLT `H²(SO(3),U(1))≅ℤ₂`. `comparisonIsScoped` rejecting `UnprovedSpectrumEquivalence` mirrors the paper's "no general spectrum map" caution.

No blocking change remains.

VERDICT: PASS
