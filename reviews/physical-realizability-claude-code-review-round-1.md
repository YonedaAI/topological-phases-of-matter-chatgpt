I've read all four source files and cross-checked them against `physical-realizability.tex`. Here is my review.

## Findings

**1. [Low / naming] `entryIsComplete` reports `True` for an intentionally unpopulated row.**
`entryIsComplete = null . validateEntry` (Realizability.hs:159–160), and `validateEntry` only enforces witness population when `realizationStatus == Realized` (lines 151–157). So `openBordismEntry` (all witnesses `Nothing`/empty, status `Open`) yields `entryIsComplete = True`, and Main prints `contract-valid=True` for it. This is correct *as a validator* (an Open row is validly incomplete), but the paper's §"Realizability row" states "The row is complete only if every required field is populated" (tex:372). The function name `entryIsComplete` therefore overclaims relative to the paper's "complete row" notion; it is really "no contract violations." Main's `contract-valid` label is accurate; only the exported name is a potential misnomer. Non-blocking.

**2. [Low / scope] Registry has a 4th entry not in the paper's matrix.**
The verified low-dimensional matrix (tex:390–411) contains exactly three `REAL` rows: class-D Kitaev, BDI stack, spin-1 AKLT. The code adds `openBordismEntry` ("arbitrary Freed-Hopkins torsion class", `Open`). This is *consistent* with the Status-language section (tex:217, OPEN = "no realization or obstruction theorem is asserted") and with the paper's thesis that general torsion classes lack a realization theorem, but it is an addition beyond the tabulated contract. Worth a one-line note in README that the registry illustrates the OPEN status beyond the three tabulated rows. Non-blocking.

**3. [Low / fidelity] `extendsAcrossGaplessLocus` field name risks the exact conflation the paper warns against.**
`relativeCharge` returns `ZeroByExtension` when this flag is set (Realizability.hs:182), encoding the Extension criterion "Q_Σ(ν)=0 precisely when ν lies in the image of j*" (tex, prop:extension-criterion). But the paper explicitly cautions this cohomological extension "does not say that a Hamiltonian family itself extends across Σ while remaining gapped" (tex:~778). The chosen name evokes the physical gapped extension the paper distinguishes. The logic is correct; consider a name like `restrictsFromBaseClass`. Non-blocking.

**4. [Info] Partial record selectors are exported.**
`GapWitness(..)` exports `gapLowerBound`/`exactGapReason`/`theoremCitation`, and `RelativeResult(..)` exports `zeroRelativeDegree`/`relativeDegree`/`localizedThomDegree` — each partial across constructors. They are never misused internally (all access is via pattern matching in `validGapWitness` and in `relativeCharge`), and GHC 9.10 does not warn on these under `-Wall -Wextra` (only under the opt-in `-Wincomplete-record-selectors`), so this does not threaten the `-Werror` build. Flagged only as a latent runtime-error surface for external callers.

## Confirmed correct (no action)

- **Degree bookkeeping matches the tex.** `connectingDegree q = q+1` matches ∂: E^q→E^{q+1} (eq:relative-charge); `thomLocalizedDegree q c = (q+1)-c` matches the localized degree q+1−c (thm:thom-charge, eq:thom-localization). The localized Thom degree is emitted (`Just`) only when both `excisionHypothesesHold` **and** `normalBundleIsOriented` (lines 194–197), matching the paper's excision (thm:excision) + E-orientation hypotheses.
- **Relative-charge branch order** (invalid codim → no invariant → extension → localized class) is total and matches the paper's case logic; `normalCodimension <= 0` is rejected, consistent with codimension c>0.
- **Dimension validation** `n == d+1`, `d ≥ 0` (lines 102–105) matches tex:361; all four entries satisfy it (1/2, 1/2, 1/2, 3/4).
- **REAL completeness** (explicit interaction + full symmetry + valid nonempty uniform-gap + microscopic invariant, lines 151–157) matches the Status definition (tex:208–216) and prop:matrix-criterion. `ExactGap 2.0` for class-D matches E(k)=2t at t=1 (tex:505).
- **Comparison scoping**: only `UnprovedSpectrumEquivalence` is unscoped (line 133), matching the paper's warning that "agreement" ≠ spectrum identification; it is checked for *all* statuses, and every registry row uses `EffectiveAgreement`/`ComparisonOpen`.
- **Exports**: all 27 exported names are defined; helpers `validGapWitness`/`nonBlank` are used (no unused-binding warnings); `Data.Char (isSpace)` is used; `nonBlank ""` = `False` is correct.
- **Deterministic output**: fixed registry order, `show`-based, no `Map`/`Set` ordering, no randomness/time.
- **Portability / flags**: base-only; `GHC ?= ghc` is overridable; Makefile compiles both modules under `-Wall -Wextra -Werror -O2` with correct `.PHONY`; README claims ("only base", "make run", published gaps stored as named witnesses) are accurate.

None of the findings require a change before this passes; all four are advisory.

VERDICT: PASS
