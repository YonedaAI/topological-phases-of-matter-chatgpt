I've reviewed the four files and cross-checked the code against `papers/latex/locality-condensed-families.tex`.

## Review: `src/locality-condensed-families/`

### Mathematical correspondence (verified against the paper)
- `finiteSummability` = `sup_x Σ_y F(d(x,y))` — matches eq. `F-sum` (`\|F\|`). ✓
- `finiteConvolutionConstant` = `sup_{x,y} (1/F(d(x,y))) Σ_z F(d(x,z))F(d(z,y))` — matches eq. `F-conv` (`C_F`), including the `z=x`/`z=y` terms the paper's sum contains. ✓
- `polynomialF power r = (1+r)^(-power)` — matches `F(r)=1/(1+r)^{ν+ε}`. ✓
- `liebRobinsonEnvelope` = `(2/C_F)(e^{2C_F‖Φ‖|t|}-1)·‖A‖·‖B‖·D` — matches eq. `LR-single` (line 511). ✓
- Moving weak defect: `defectGap n = 1/n`, `limitGap = 1` — matches `γ_n=1/n, γ_∞=1` (lines 991, 1014–1016). ✓
- `pointwisePositive` / `uniformlyAbove` mirror the paper's "every gap positive" vs. "uniform lower bound" distinction (line 1107). `locallyAgreesWithLimit` mirrors local-continuity invisibility. ✓

No mathematical discrepancies.

### Findings

1. **[Info] Domain guards fall outside the paper's F-function domain.** `polynomialF power <= 0 = 0` (line 42) and `liebRobinsonEnvelope`'s non-positivity guards (lines 83–85) return `0` for inputs the paper excludes (F must be strictly positive, `C_F>0`). These are defensive totality guards, never hit by `Main` (`power=3.0`, `C_F>0`). Correct and total; just note the `0` sentinel is a diagnostic convenience, not a paper value.

2. **[Info] `max 0 radius` in `polynomialF` (line 43) is dead code.** `distance = abs(...)` is always ≥ 0 and all call sites feed distances, so the clamp never fires. Harmless.

3. **[Low] Vacuous-truth edge on empty gap lists.** `pointwisePositive []` and `uniformlyAbove b []` both return `True` (via `all` over `[]`), whereas `firstNGapMinimum 0 = Nothing`. Empty-family semantics are mildly inconsistent, but the paper scopes these to a "finite list of positive gaps" and `Main` never passes empty lists, so no functional impact.

### Totality / edge cases
`sites` handles `size ≤ 0` (yields `[]`); `maximumOrZero` handles the empty list, so `finiteSummability`/`finiteConvolutionConstant`/`interactionSupremum` are total on degenerate lines. `firstNGapMinimum` guards `count ≤ 0`. `finiteConvolutionConstant`'s `denominator > 0` guard is safe. No partial `head`/`maximum`/division-by-zero paths. ✓

### API & signatures
Explicit export list; `FiniteLine(..)`/`Fiber(..)` constructors exported; every top-level binding (and the `where`-bound `ratio`) carries an explicit signature. `Main` imports an explicit subset with explicit constructor imports. Unused public exports are intentional API, not `-Wall` violations. ✓

### Determinism
All logic is pure; list-comprehension ordering is fixed, `maximum`/`minimum` are deterministic, no NaN is produced (finite inputs, `power>0`), and `printf` formatting is fixed-precision. Output is reproducible. ✓

### Portability & build
Depends only on `base` (incl. `Text.Printf`). Makefile pins `-Wall -Wextra -Werror -O2`, declares `.PHONY`, and provides `all`/`run`/`clean`; `ghc Main.hs Locality.hs` resolves module deps correctly. README's `make run` instructions and the "finite diagnostics, not proofs" caveat are accurate. Confirmed already compiled/ran clean under GHC 9.10.1 with the stated flags. ✓

No blocking code changes required; the three findings are informational/low-severity polish only.

VERDICT: PASS
