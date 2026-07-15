# Five-paper consistency pre-audit

Date: 2026-07-14

## Scope and decision

This is an author-side consistency check of the five AGY-accepted manuscripts against `.knowledge-base.md`, the canonical AGY reviews, and `docs/research/06-synthesis.md`. It does not replace AGY review. The check covers definitions, arrows, hypotheses, symbols, status labels, citations, and nonclaims at the interfaces used by the synthesis.

| Paper | Revision before final audit? | Decision |
|---|---:|---|
| 1, Locality and Lieb-Robinson bounds | No | Its locality, tail, continuity, and thermodynamic-limit contracts are internally consistent. |
| 2, Positivity and C*-norm descent | No | Its analytic input and descent claims are consistent with the later papers. Bibliographic normalization is optional. |
| 3, Thermodynamic gaps | **Yes** | Its thermodynamic-dynamics corollary omits the uniform-tail hypothesis that its proof uses, and its definition of local F-continuity folds in a separate tail condition. |
| 4, Microscopic systems and effective theories | **Yes** | Its appendix reverses the declared argument convention for `\kappa`, and its proposed comparison diagram mis-targets `R` and contains an unsupported solid arrow. |
| 5, Physical realizability | No | Its realizability and relative-charge qualifications are consistent. Renaming one comparison-map symbol would reduce cross-paper ambiguity but is not a correctness fix. |

Papers 3 and 4 therefore need small source corrections before the final cross-paper audit. Because those edits postdate their canonical AGY acceptances, each corrected manuscript should receive another AGY review round under the project review contract.

## Corrections required

### 1. Paper 3 must state the uniform-tail hypothesis

Paper 1 separates three conditions:

1. an F-function and convolution bound (`papers/latex/locality-condensed-families.tex:277-296`);
2. local F-continuity on every fixed finite region (`papers/latex/locality-condensed-families.tex:403-420`);
3. the additional uniform tail `T_F(R) -> 0`, recorded separately because uniform summability alone does not imply it on general geometry (`papers/latex/locality-condensed-families.tex:354-380`).

Its uniform Lieb-Robinson estimate needs the common F-norm bound (`papers/latex/locality-condensed-families.tex:543-569`), while uniform thermodynamic convergence explicitly assumes the uniform tail (`papers/latex/locality-condensed-families.tex:616-658`).

Paper 3 declares the same uniform-tail condition for general countable metric spaces (`papers/latex/thermodynamic-gaps.tex:247-280`), but then folds a tail estimate into "local F-continuity" (`papers/latex/thermodynamic-gaps.tex:301-310`). More importantly, its thermodynamic-dynamics corollary says that the assumptions of the Lieb-Robinson theorem suffice (`papers/latex/thermodynamic-gaps.tex:323-350`), although its proof uses a common vanishing F-tail (`papers/latex/thermodynamic-gaps.tex:353-358`).

Required correction: use Paper 1's terminology, keep local F-continuity local, and add `T_F(R) -> 0` to the thermodynamic-dynamics corollary. An alternative is to restrict that corollary to a standard translation-invariant lattice where the tail is automatic, but the broader explicit hypothesis is cleaner.

### 2. Paper 4 must keep one `\kappa` argument convention

The main definition is target first and reference second:

```tex
\kappa_S(h,h_{\mathrm{ref}})=[p_h]-[p_{h_{\mathrm{ref}}}].
```

See `papers/latex/microscopic-effective-theories.tex:549-558`. The reference-change formula uses that convention (`papers/latex/microscopic-effective-theories.tex:1888-1898`). The appendix instead defines

```tex
\kappa(h_i,h_j)=[p_{h_j}]-[p_{h_i}],
```

at `papers/latex/microscopic-effective-theories.tex:1873-1885`, reversing the sign and the arguments.

Required correction: replace the appendix formula with `[p_{h_i}]-[p_{h_j}]`. The stated cocycle and reference-change formulas then agree with the main definition.

### 3. Paper 4 must repair its proposed comparison diagram

The paper's governing factorization defines

```text
Ham_micro --L--> EFT_low --I--> Class_stable
Class_stable --R--> Real_lattice,
```

and explicitly says that `R` is a realization problem, not an inverse to `I o L` (`papers/latex/microscopic-effective-theories.tex:162-215`).

The later proposed diagram instead draws `R` from `Class^bord` back to `EFT^invertible` and draws an unlabeled solid arrow from `K_op` to `EFT^invertible` (`papers/latex/microscopic-effective-theories.tex:1533-1553`). Neither arrow follows from the definitions. The immediately following text says that the lower arrows require separate results and that no unproved comparison square is claimed (`papers/latex/microscopic-effective-theories.tex:1556-1558`), which makes the solid `K_op -> EFT` arrow especially misleading.

Required correction: target `R` at a lattice-realization object, not the EFT object. Remove the `K_op -> EFT` arrow or render it explicitly open or conjectural with its domain and proposed comparison stated. Do not present a commutative square until such a map is defined and proved.

## Interface checks

### Locality and Lieb-Robinson control

Apart from Paper 3's omitted tail hypothesis, the locality interface is consistent. A common F-norm yields family-uniform propagation constants, while a common vanishing F-tail is the additional input for family-uniform thermodynamic convergence. Neither condition supplies a spectral gap. Paper 1's moving weak-defect family makes this separation explicit (`papers/latex/locality-condensed-families.tex:957-1035`), and Paper 3 preserves the same logical separation in its gap discussion (`papers/latex/thermodynamic-gaps.tex:361-364`, `papers/latex/thermodynamic-gaps.tex:929-951`).

Synthesis contract: never infer a thermodynamic gap from locality, and never infer a common parameter gap from pointwise gappedness.

### Positivity, C*-norm, and descent

Paper 2 begins with a chosen C*-algebra and gives `C(S,A)` the supremum norm and fiberwise positive cone (`papers/latex/condensed-observables.tex:260-319`). Finite jointly surjective profinite covers descend the sections isometrically and preserve positivity (`papers/latex/condensed-observables.tex:335-372`). The multiple-norm example proves that a ring or abstract star-algebra does not select its C*-norm or order (`papers/latex/condensed-observables.tex:446-479`). It also distinguishes a continuous family of fiber states from a state on the section algebra (`papers/latex/condensed-observables.tex:493-544`).

Paper 4 uses the same section-algebra input in its controlled free-fermion sector and correctly warns that a common positive spectral lower bound is needed (`papers/latex/microscopic-effective-theories.tex:1489-1531`). Its discussion of Aoki also says that solidification is a K-theory bridge after the Banach algebra is given, not a construction of norm, order, states, or interactions (`papers/latex/microscopic-effective-theories.tex:1560-1571`). There is no contradiction.

Synthesis contract: norm, involution, completeness, positive cone, and physical state data are analytic inputs that can descend. Condensed algebraic data do not manufacture them.

### Witness fibration and qualitative gapped image

Paper 3's `Gap_F^wit` retains the gap predicate, boundary or GNS convention, selected sector, common lower bound, verification, and continuity data (`papers/latex/thermodynamic-gaps.tex:819-847`). Its projection to Hamiltonians is generally not injective, so the witnessed object is a data fibration rather than a subfunctor (`papers/latex/thermodynamic-gaps.tex:849-856`). Only the propositional image `Gap_F^prop` is the qualitative gapped subfunctor (`papers/latex/thermodynamic-gaps.tex:858-868`). Consequently, the gapless locus is the complement of the qualitative pullback, not the complement of a witness bundle (`papers/latex/thermodynamic-gaps.tex:907-924`).

Paper 4's `Ham^{free,gap}` is a controlled one-particle property, not automatically Paper 3's thermodynamic witnessed object (`papers/latex/microscopic-effective-theories.tex:427-439`, `papers/latex/microscopic-effective-theories.tex:1489-1502`). Paper 5's proposed realizability subfunctor records complete microscopic witness families with a common gap (`papers/latex/physical-realizability.tex:948-958`). These objects can be related only after their predicates and forgetful maps are fixed. They are not interchangeable definitions.

### Finite-volume bands, GNS gaps, and one-particle spectral gaps

Paper 3 distinguishes the literal finite-volume ground-state gap (`papers/latex/thermodynamic-gaps.tex:367-391`), selected ground-band gap (`papers/latex/thermodynamic-gaps.tex:393-412`), uniform finite-volume band gap with an exhaustion and boundary convention (`papers/latex/thermodynamic-gaps.tex:414-427`), GNS bulk gap for a selected state (`papers/latex/thermodynamic-gaps.tex:429-447`), and uniform parameterized GNS gap (`papers/latex/thermodynamic-gaps.tex:449-463`). Its implication table correctly says that passage between these notions requires hypotheses and that open boundaries can carry protected low-energy modes (`papers/latex/thermodynamic-gaps.tex:929-951`, `papers/latex/thermodynamic-gaps.tex:993-1000`).

Paper 5's examples use a finite-volume low-energy sector and a size-independent band above it (`papers/latex/physical-realizability.tex:249-269`). Kubota's object instead includes a chosen nondegenerate gapped GNS ground state (`papers/latex/physical-realizability.tex:304-320`). A verified finite-volume realization row therefore cannot be placed in Kubota's spectrum without checking Kubota's hypotheses. Paper 4's Fermi gap for bounded one-particle operators is another distinct C*-spectral predicate (`papers/latex/microscopic-effective-theories.tex:305-349`). No manuscript claims the forbidden automatic implications.

### The microscopic, EFT, invariant, and realization arrows

Paper 4 correctly defines `L`, `I`, and `R` on separate domains and requires independent control of low-energy reduction, invariant extraction, and realization (`papers/latex/microscopic-effective-theories.tex:162-221`). It also rejects a general microscopic-to-EFT equivalence and universal realization claims (`papers/latex/microscopic-effective-theories.tex:1648-1701`, `papers/latex/microscopic-effective-theories.tex:1773-1784`).

The program sequence from local interactions through a gapped moduli object to a stabilized phase spectrum is an organizational construction. It is not the same factorization as `L`, `I`, and `R`. The synthesis should show comparison maps between these layers only when a common domain, equivalence relation, stabilization, and continuity theorem are supplied.

### Freed-Hopkins, Kubota, Aoki, and the proposed condensed spectrum

Paper 5 keeps four targets distinct:

- Freed-Hopkins classifies a specified field-theory sector, and its application to lattice systems assumes a valid low-energy EFT (`papers/latex/physical-realizability.tex:276-302`).
- Kubota constructs an Omega-spectrum for invertible gapped quantum spin systems with its own smooth-family and GNS hypotheses (`papers/latex/physical-realizability.tex:304-320`).
- The condensed invertible phase spectrum remains a proposed target and is not identified with either preceding spectrum (`papers/latex/physical-realizability.tex:322-353`).
- Aoki compares solidified algebraic K-theory with operator K-theory under connective or Bott-periodic qualifications (`papers/latex/condensed-observables.tex:797-909`). That invariant-level bridge is not a phase-spectrum equivalence.

Paper 5's status ledger and limitations preserve these distinctions (`papers/latex/physical-realizability.tex:1001-1029`, `papers/latex/physical-realizability.tex:1044-1081`). Kubota's stated spin-system scope also cannot silently absorb the fermionic models in Papers 4 and 5. There is no cross-paper contradiction, but every comparison arrow in the synthesis must remain dotted, partial, or open unless a theorem supplies it.

### Relative transition charge

Paper 5 defines the connecting class only for a suitable pair `(B,U)` with closed `Sigma`, cofibrant replacement when needed, and excision hypotheses (`papers/latex/physical-realizability.tex:739-780`, `papers/latex/physical-realizability.tex:786-810`). Localization on `Sigma` further requires a smooth submanifold and an E-oriented normal bundle, or else the correctly twisted theory (`papers/latex/physical-realizability.tex:812-851`). The linking sphere must lie in the full parameter space relevant to the invariant (`papers/latex/physical-realizability.tex:853-869`). Its physical interpretation is conditional on a natural microscopic comparison map (`papers/latex/physical-realizability.tex:871-899`).

Paper 3 defines `U_f` using the qualitative gapped image and `Sigma_f` as its complement (`papers/latex/thermodynamic-gaps.tex:907-924`), but openness is available only within a stability-controlled class (`papers/latex/thermodynamic-gaps.tex:901-905`). Thus the synthesis may form `E^{q+1}(B,B \setminus Sigma)` only after stating the topology or good-pair hypotheses that make `U` open and `Sigma` closed, plus excision and orientation or twisting when the Thom localization is used.

The degree shift is consistent:

```text
E^q(U) -> E^{q+1}(B,U) -> E^{q+1-c}(Sigma).
```

Paper 4's SSH computation gives local degree `-1` for its chosen orientation and explains why the oriented phase jump can use the opposite boundary convention (`papers/latex/microscopic-effective-theories.tex:1900-1918`). This is not a contradiction. The sign is meaningful only after the connecting-map and normal-orientation conventions are fixed.

## Notation and status labels

There is one avoidable symbol collision. Paper 4 uses `\kappa` for a relative operator K-theory difference (`papers/latex/microscopic-effective-theories.tex:549-563`), while Paper 5 uses `\kappa` for a natural comparison map from a microscopic invariant to `E^q(U)` (`papers/latex/physical-realizability.tex:871-899`). These meanings are not contradictory, but the synthesis should reserve `\kappa` for one and rename the other, for example `c_E` for the comparison map. A Paper 5 rename is optional.

The manuscripts also use two compatible but different status axes. `ESTABLISHED`, `PROPOSED`, `CONJECTURAL`, `OPEN`, and `OBSTRUCTED` describe epistemic claim status. Paper 3's `COMPUTATIONAL` and Paper 5's `REALIZED` or `CANDIDATE` describe evidence or witness status. Paper 5 defines the latter independently (`papers/latex/physical-realizability.tex:204-222`) and its ledger demonstrates the distinction (`papers/latex/physical-realizability.tex:1001-1029`). The synthesis should not report a `REALIZED` example row as an established universal comparison theorem.

## Citation normalization

No citation drift changes a theorem used in the synthesis. Two entries should nevertheless be normalized during final copyediting:

- Aoki's arXiv paper is cited as the 2024 posting in Paper 2 (`papers/latex/condensed-observables.tex:1294-1298`) and as revised in 2026 in Paper 4 (`papers/latex/microscopic-effective-theories.tex:2003-2007`). Use one formulation such as "first posted 2024, revised 2026."
- Clausen-Scholze is cited as the 2019 lecture notes in Papers 1 and 2 (`papers/latex/locality-condensed-families.tex:1530-1534`, `papers/latex/condensed-observables.tex:1318-1322`) and as arXiv:2605.03658 in Paper 4 (`papers/latex/microscopic-effective-theories.tex:2024-2027`). The synthesis should choose one edition and identify it exactly.

Freed-Hopkins and the BDI mod-eight sources are used consistently at the level needed here.

## Synthesis gate

The current synthesis brief asks for a conditional sequence that does not identify analytic, K-theoretic, EFT, and realization equivalences without proof (`docs/research/06-synthesis.md:3-15`) and explicitly says that the condensed spectrum is not yet constructed and that physical relative charge needs a comparison map (`docs/research/06-synthesis.md:28-32`). That brief is consistent with this audit.

Before final audit, the synthesis and corrected inputs should satisfy this checklist:

- [ ] Paper 3 states the uniform tail in its thermodynamic-convergence result and keeps it separate from local F-continuity.
- [ ] Paper 4 fixes the `\kappa` sign convention.
- [ ] Paper 4 sends `R` to lattice realizations and removes or marks open the unsupported `K_op -> EFT` arrow.
- [ ] The synthesis distinguishes witnessed and qualitative gapped objects.
- [ ] Every gap statement names its finite-volume, band, one-particle, or GNS predicate and its boundary or state data.
- [ ] The Freed-Hopkins, Kubota, Aoki, and proposed condensed spectra remain distinct.
- [ ] Relative charge is stated with good-pair, excision, orientation or twist, degree, and comparison-map qualifications.
- [ ] Claim status and realization evidence are reported on separate axes.
- [ ] Papers 3 and 4 receive AGY review after correction.

The other three accepted manuscripts do not require revision before the final audit.
