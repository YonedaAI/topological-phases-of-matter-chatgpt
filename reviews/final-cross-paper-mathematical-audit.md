# Final cross-paper mathematical audit

Date: 2026-07-14

## Scope and decision

This is the final Ultra mathematical consistency review of the corrected sources for all five companion papers, the accepted synthesis, the canonical AGY reports, and `reviews/five-paper-consistency-preaudit.md`. It does not replace or rewrite any AGY report.

No release-blocking mathematical contradiction or code-interface mismatch remains. The preaudit corrections, the release copyedits, and the target-first Haskell API correction are present. Fresh AGY reviews accepted Paper 4 and the synthesis, and a fresh Claude review passed the modified Haskell code.

## Sources and preserved AGY decisions

| Artifact | Canonical review evidence | Result |
|---|---|---|
| Paper 1, locality | `reviews/locality-condensed-families-agy-review.md:1-25` | ACCEPT |
| Paper 2, observables | `reviews/condensed-observables-agy-review.md:1-7` | ACCEPT |
| Paper 3, gaps | `reviews/thermodynamic-gaps-agy-review.md:1-20` | Round 3 ACCEPT after the tail and witness corrections |
| Paper 4, microscopic to EFT | `reviews/microscopic-effective-theories-agy-review.md:1-23` | Round 4 ACCEPT after final interface and citation normalization |
| Paper 5, realizability | `reviews/physical-realizability-agy-review.md:1-16` | ACCEPT |
| Synthesis | `reviews/invertible-condensed-phase-spectrum-agy-review.md:1-48` | Round 5 ACCEPT after the tail, notation, and citation corrections |
| Paper 4 Haskell | `reviews/microscopic-effective-theories-claude-code-review.md:1-50` | Round 3 PASS after target-first API correction |

All canonical decisions remain intact. This audit adds a cross-paper check only.

## Preaudit corrections

### Paper 3 tail separation

PASS.

Paper 3 now separates the three required inputs:

1. The F-function conditions appear at `papers/latex/thermodynamic-gaps.tex:247-280`.
2. Local F-continuity is a finite-region condition at `papers/latex/thermodynamic-gaps.tex:302-314`.
3. The uniform tail `T_F(R) -> 0` is an additional hypothesis for thermodynamic convergence at `papers/latex/thermodynamic-gaps.tex:349-365`.

The Lieb-Robinson estimate itself uses the common F-norm at `papers/latex/thermodynamic-gaps.tex:327-347`. The following corollary adds the tail before asserting family-uniform thermodynamic dynamics. This agrees with Paper 1, which separates the tail at `papers/latex/locality-condensed-families.tex:354-380`, local continuity at `papers/latex/locality-condensed-families.tex:403-420`, the common-norm propagation bound at `papers/latex/locality-condensed-families.tex:543-569`, and thermodynamic convergence at `papers/latex/locality-condensed-families.tex:616-658`.

The correction is independently confirmed in the canonical Paper 3 AGY report at `reviews/thermodynamic-gaps-agy-review.md:9-20`.

### Paper 4 target-first kappa

PASS.

The governing definition is

```tex
\kappa_S(h,h_{\mathrm{ref}})=[p_h]-[p_{h_{\mathrm{ref}}}]
```

at `papers/latex/microscopic-effective-theories.tex:549-558`. The appendix now uses the same target-first convention at `papers/latex/microscopic-effective-theories.tex:1880-1891`. Its cocycle law and reference-change identity at `papers/latex/microscopic-effective-theories.tex:1895-1902` have the corresponding signs. No reversed convention remains.

### Paper 4 Haskell interface

PASS.

The public Haskell API now takes `tolerance`, `target`, and `reference` in that order and computes target minus reference at `src/microscopic-effective-theories/Core.hs:190-196`. The runnable example and regression property call it as topological target against trivial reference at `src/microscopic-effective-theories/Main.hs:45-51` and `src/microscopic-effective-theories/Properties.hs:110-111`. The cocycle and transition-orientation checks use the same order at `src/microscopic-effective-theories/Proofs.hs:89-117`.

The regression property was changed before the implementation and failed under the former API with 19 of 20 properties passing. After the API and call-site correction, GHC 9.10.1 compiled all four modules with `-fforce-recomp -Wall -Wextra -Werror`; the executable reported 20 of 20 properties and 5 of 5 proof checks passing. The fresh canonical Claude review confirms the semantics, all six calls, the nontrivial additivity example, and preserved numerical results at `reviews/microscopic-effective-theories-claude-code-review.md:1-50`.

### Paper 4 comparison chains

PASS.

The corrected source displays the established free flattening map separately at `papers/latex/microscopic-effective-theories.tex:1533-1544`. The broader chain is

```text
Ham_micro,gap  --open L-->  EFT_invertible  --scoped I-->  Class_bord  --open R-->  Real_lattice
```

at `papers/latex/microscopic-effective-theories.tex:1545-1557`. The surrounding text restricts the solid `I` arrow to the declared Freed-Hopkins EFT domain, leaves `L` and `R` open, and expressly denies both a `K_op -> EFT` map and a commutative comparison square at `papers/latex/microscopic-effective-theories.tex:1560-1565`. This matches the governing definitions at `papers/latex/microscopic-effective-theories.tex:162-221`.

The canonical Paper 4 AGY report independently verifies the signs, domains, codomains, scoped status of `I`, and corrected citations at `reviews/microscopic-effective-theories-agy-review.md:1-23`.

## Analytic and categorical interfaces

### Locality does not imply a gap

PASS.

Paper 1 derives family-uniform propagation from a common interaction norm and does not use parameter compactness as an analytic substitute at `papers/latex/locality-condensed-families.tex:543-569`. It adds the tail for thermodynamic convergence at `papers/latex/locality-condensed-families.tex:616-658`. Its moving weak-defect family at `papers/latex/locality-condensed-families.tex:957-1035` separates uniform locality from a uniform spectral gap.

Paper 3 states the same separation explicitly at `papers/latex/thermodynamic-gaps.tex:367-370` and records the forbidden implication in its predicate table at `papers/latex/thermodynamic-gaps.tex:933-960`. The synthesis preserves both boundaries at `papers/latex/invertible-condensed-phase-spectrum.tex:329-369` and in its claim ledger at `papers/latex/invertible-condensed-phase-spectrum.tex:1425-1447`.

### Positivity and C-star norm conditions

PASS.

Paper 2 starts with a chosen C-star algebra, equips `C(S,A)` with the supremum norm and fiberwise positive cone, and proves the finite-cover descent statement at `papers/latex/condensed-observables.tex:260-372`. Its multiple-completion example at `papers/latex/condensed-observables.tex:446-479` blocks the inference of a physical norm or order from bare algebraic data. It also distinguishes a continuous family of fiber states from a state on the section algebra at `papers/latex/condensed-observables.tex:493-544`.

The Aoki bridge is restricted to the stated connective or Bott-periodic K-theory comparisons at `papers/latex/condensed-observables.tex:797-909`. The synthesis repeats that the Banach or C-star algebra is already input and that solidification does not reconstruct its norm, order, states, or interaction at `papers/latex/invertible-condensed-phase-spectrum.tex:1105-1116`. No algebraic descent claim is promoted to an analytic existence theorem.

### Witness fibration and propositional image

PASS.

Paper 3 defines a gap witness with predicate, boundary or GNS convention, selected sector, common lower bound, verification, and continuity data at `papers/latex/thermodynamic-gaps.tex:825-841`. Its projection is explicitly a generally nonmonic fibration of data at `papers/latex/thermodynamic-gaps.tex:843-862`. Only the truncated image is the qualitative gapped subfunctor at `papers/latex/thermodynamic-gaps.tex:864-874`.

The synthesis preserves the same distinction at `papers/latex/invertible-condensed-phase-spectrum.tex:543-592`. It pulls the gapless locus back from `Gap_F^prop`, not from the witness fibration, at `papers/latex/invertible-condensed-phase-spectrum.tex:858-881`. It also states the image-factorization and common-witness assumptions in the conditional assembly theorem at `papers/latex/invertible-condensed-phase-spectrum.tex:747-780`.

### Gap predicate boundaries

PASS.

The final sources keep these predicates distinct:

| Predicate | Evidence and boundary |
|---|---|
| Literal finite-volume ground gap | `papers/latex/thermodynamic-gaps.tex:367-391` |
| Selected finite-volume band gap | `papers/latex/thermodynamic-gaps.tex:393-427` |
| GNS bulk gap for a selected state | `papers/latex/thermodynamic-gaps.tex:429-463` |
| Controlled one-particle Fermi gap | `papers/latex/microscopic-effective-theories.tex:305-349` |
| Realization-row finite-volume band convention | `papers/latex/physical-realizability.tex:234-269` |
| Kubota nondegenerate gapped GNS input | `papers/latex/physical-realizability.tex:304-320` |

Paper 3's safe-implication table at `papers/latex/thermodynamic-gaps.tex:933-960` requires extra hypotheses between predicates. Its bulk and boundary discussion at `papers/latex/thermodynamic-gaps.tex:999-1006` prevents an open-boundary low-energy splitting from being confused with loss of the bulk gap. The synthesis restates separate finite-volume and GNS witnesses at `papers/latex/invertible-condensed-phase-spectrum.tex:520-541` and limits controlled stability to paths that already possess uniform locality and gap hypotheses at `papers/latex/invertible-condensed-phase-spectrum.tex:600-615`.

No final source infers a common parameter gap from pointwise gaps, a thermodynamic gap from finite-size gappedness, or an open-boundary literal gap from a bulk GNS gap.

## Stable homotopy and realization interfaces

### Homotopy groups and defect codimension

PASS.

The synthesis distinguishes homotopy sheaves, global sections, and ordinary homotopy groups at `papers/latex/invertible-condensed-phase-spectrum.tex:789-823`. It gives a physical pump interpretation to `pi_1` only when an analytic transport provider is present at `papers/latex/invertible-condensed-phase-spectrum.tex:825-840`.

For higher homotopy, `pi_k` records a based k-parameter family. A codimension `k+1` physical defect follows only after a separate family-to-defect construction compatible with homotopy, stacking, and spatial suspension. The exact qualification is at `papers/latex/invertible-condensed-phase-spectrum.tex:842-856`. The canonical synthesis AGY report confirms this point at `reviews/invertible-condensed-phase-spectrum-agy-review.md:25-30`.

### Freed-Hopkins, Kubota, Aoki, and the proposed spectrum

PASS.

Paper 5 distinguishes the targets at `papers/latex/physical-realizability.tex:276-353`:

1. Freed-Hopkins is an established theorem for the stated reflection-positive field-theory sector. Its use for lattice phases needs an EFT comparison.
2. Kubota constructs an established microscopic Omega-spectrum with smooth-family, almost-local, lattice, stabilization, and GNS hypotheses.
3. The condensed spectrum is proposed and is definitionally neither of the preceding targets.

Paper 2's Aoki result is an invariant-level K-theory comparison, not a phase-spectrum equivalence, at `papers/latex/condensed-observables.tex:797-909`.

The synthesis repeats these four scopes at `papers/latex/invertible-condensed-phase-spectrum.tex:1070-1116`. Every cross-target arrow in its comparison web is dotted, and the text denies a global equivalence at `papers/latex/invertible-condensed-phase-spectrum.tex:1118-1138`. Its claim ledger leaves the Kubota-to-condensed and microscopic-to-Freed-Hopkins identifications open at `papers/latex/invertible-condensed-phase-spectrum.tex:1473-1495`.

### Realization evidence and epistemic status

PASS.

Paper 5 defines `REALIZED`, `CANDIDATE`, `OPEN`, and `OBSTRUCTED` as witness statuses under fixed microscopic rules at `papers/latex/physical-realizability.tex:204-222`. These are not replacements for the synthesis's epistemic labels `ESTABLISHED`, `PROPOSED`, `CONJECTURAL`, `OPEN`, and `OBSTRUCTED`.

The synthesis's three concrete rows at `papers/latex/invertible-condensed-phase-spectrum.tex:1156-1189` record explicit gap witnesses and invariants, while their abstract comparisons are stated as agreements in controlled low-dimensional sectors. The following discussion denies general surjectivity or injectivity at `papers/latex/invertible-condensed-phase-spectrum.tex:1191-1207`. The claim ledger marks the concrete witness rows established on their explicit evidence but leaves realization of every bordism class open at `papers/latex/invertible-condensed-phase-spectrum.tex:1497-1503`.

This is not claim drift. An established concrete witness row does not become an established universal comparison theorem.

## Relative transition charge

PASS.

The synthesis forms `U_f` from the qualitative gapped image and defines `Sigma` only when that complement is represented at `papers/latex/invertible-condensed-phase-spectrum.tex:858-881`. It says that openness for interacting thermodynamic systems is an analytic stability theorem, not a consequence of sheafification, at `papers/latex/invertible-condensed-phase-spectrum.tex:883-890`.

The relative class then has all required prerequisites:

| Requirement | Exact synthesis evidence |
|---|---|
| Good pair `(B,U)` and long exact sequence | `papers/latex/invertible-condensed-phase-spectrum.tex:892-918` |
| Pair is `(B,B minus Sigma)` | `papers/latex/invertible-condensed-phase-spectrum.tex:894-907` |
| Excision to a neighborhood | `papers/latex/invertible-condensed-phase-spectrum.tex:924-932` |
| Closed smooth locus and rank-c normal bundle | `papers/latex/invertible-condensed-phase-spectrum.tex:933-944` |
| E-orientation or twisted replacement | `papers/latex/invertible-condensed-phase-spectrum.tex:935-947` |
| Degree `q+1-c` after Thom localization | `papers/latex/invertible-condensed-phase-spectrum.tex:938-943` |
| Natural microscopic comparison map | `papers/latex/invertible-condensed-phase-spectrum.tex:949-975` |
| Linking cycle in the full parameter space | `papers/latex/invertible-condensed-phase-spectrum.tex:977-988` |

The appendix repeats the exact sequence, excision, orientation, twist, degree, and comparison-map checklist at `papers/latex/invertible-condensed-phase-spectrum.tex:1677-1700`. Paper 5 supplies the same prerequisites in full at `papers/latex/physical-realizability.tex:739-899`.

The relative connecting class is established algebraic topology. Its name as a physical transition charge remains conditional on the microscopic invariant and comparison map. No final source confuses extension of a cohomology class with extension of a uniformly gapped Hamiltonian family.

## Synthesis claim-drift check

PASS.

The five-stage construction remains explicitly conditional. The phase infinity-groupoid is proposed at `papers/latex/invertible-condensed-phase-spectrum.tex:660-673`. The condensed spectrum and its spatial delooping limitations are proposed or open at `papers/latex/invertible-condensed-phase-spectrum.tex:688-741`. The assembly theorem lists eight assumptions and calls the full stack-level result proposed at `papers/latex/invertible-condensed-phase-spectrum.tex:747-787`.

The synthesis does not introduce an inverse to the microscopic, EFT, invariant, and realization arrows. Its `L`, `I`, and `R` diagram at `papers/latex/invertible-condensed-phase-spectrum.tex:990-1015` preserves their separate domains and claims no automatic inverse. Its controlled free K-class uses target first and reference second at `papers/latex/invertible-condensed-phase-spectrum.tex:1017-1040`.

The abstract now separates the hypotheses at `papers/latex/invertible-condensed-phase-spectrum.tex:123-127`: a common interaction norm gives the Lieb-Robinson bound, while family-uniform thermodynamic dynamics additionally require a common tail that vanishes at large distance. This matches the precise theorem at `papers/latex/invertible-condensed-phase-spectrum.tex:349-369` and the claim ledger at `papers/latex/invertible-condensed-phase-spectrum.tex:1425-1427`. AGY round 5 independently accepted this correction at `reviews/invertible-condensed-phase-spectrum-agy-review.md:12-15`.

## Verified release corrections

### Distinct comparison symbols

PASS.

The microscopic-to-cohomology natural transformation is now `c_E` at `papers/latex/invertible-condensed-phase-spectrum.tex:951-958`. The relative operator K-class remains `\kappa(h,h_ref)` at `papers/latex/invertible-condensed-phase-spectrum.tex:1030-1040`. A source scan finds no microscopic comparison map still denoted by `\kappa`, so the preaudit's notation collision is resolved.

### Citation-version normalization

PASS.

Paper 4 and the synthesis now use the key `Aoki2024` and cite arXiv:2409.01462 as 2024 at `papers/latex/microscopic-effective-theories.tex:2010-2013` and `papers/latex/invertible-condensed-phase-spectrum.tex:1760-1763`. Both use the key `Scholze2026` and list Peter Scholze as the official author of arXiv:2605.03658 at `papers/latex/microscopic-effective-theories.tex:2031-2034` and `papers/latex/invertible-condensed-phase-spectrum.tex:1788-1791`. These entries match the current official arXiv records: <https://arxiv.org/abs/2409.01462> and <https://arxiv.org/abs/2605.03658>.

AGY independently verified the corrected metadata in Paper 4 at `reviews/microscopic-effective-theories-agy-review.md:12-17` and in the synthesis at `reviews/invertible-condensed-phase-spectrum-agy-review.md:37-43`.

### Rebuilt release artifacts

PASS.

Both papers were compiled three times with `pdflatex -halt-on-error` in isolated build directories. The final logs had no undefined citation or reference warning. Paper 4 is 33 pages with SHA-256 `4bef0ff144f6f00269f6395c2cbe840acf763ac19df7d7c286374c4938760007`. The synthesis is 32 pages with SHA-256 `e101c8da49a0b65f40c07867254e74d5c121e35b3ed0e944cf09d1f4a6ebf27f`.

The regenerated 300 DPI page-one PNGs are each 2550 by 3300 pixels and were visually checked. Their SHA-256 values are `3b9753811dea8403e2b563bc2f488eb7bf86322aded075a1f63788e15e1d8aec` for Paper 4 and `eb3f8c16f38bdbec99acb0ff00dba16bada35efe853dcb0e8419c96bc7c73b27` for the synthesis.

## Final checklist

- [x] Paper 3 separates local continuity, the common F-norm, and the uniform tail.
- [x] Paper 3 states the tail in its thermodynamic-convergence result.
- [x] Paper 4 uses target-first `\kappa` throughout.
- [x] Paper 4 Haskell uses the target-first `relativeWinding` public API at every call site.
- [x] Paper 4 sends `R` to lattice realizations and removes the unsupported `K_op -> EFT` arrow.
- [x] Papers 3 and 4 have post-correction canonical AGY acceptances, including Paper 4 round 4.
- [x] The synthesis distinguishes the witness fibration from the propositional image.
- [x] Finite-volume, band, one-particle, and GNS gap predicates retain their boundaries.
- [x] `pi_k` is a k-parameter family, with codimension `k+1` defects only through a separate construction.
- [x] Freed-Hopkins, Kubota, Aoki, and the proposed condensed spectrum remain distinct.
- [x] Realization evidence and epistemic claim status remain separate.
- [x] Relative charge states the pair, excision, orientation or twist, degree, and comparison-map prerequisites.
- [x] The synthesis introduces no substantive claim drift.
- [x] The synthesis abstract states the separate tail needed for family-uniform thermodynamic dynamics.
- [x] The microscopic comparison map is `c_E`; `\kappa` is reserved for the relative operator K-class.
- [x] Aoki and Scholze citation metadata are normalized to the official records.
- [x] Paper 4 and synthesis have fresh canonical AGY ACCEPT reviews after these edits.
- [x] The modified Paper 4 Haskell has a fresh canonical Claude PASS review.
- [x] PDFs and 300 DPI page-one images were rebuilt and checked after the final edits.

FINAL VERDICT: PASS
