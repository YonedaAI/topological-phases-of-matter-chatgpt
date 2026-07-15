---
reviewer: AGY (Gemini 3.1 Pro High)
paper: thermodynamic-gaps
round: 1
date: 2026-07-14
---

This is a mathematically careful and conceptually clarifying paper. It successfully isolates the analytic moving parts of thermodynamic spectral gaps from the categorical organization of parameterized families. The explicit status vocabulary is particularly effective.

### CRITICAL

- **Witness data do not define a subfunctor inclusion (Sections 8.1 and 8.4).** A gapped family has many witnesses, including every smaller positive lower bound. The projection from witnessed families to Hamiltonian families is not injective. The witnessed object is a bundle or category fibered in groupoids over the Hamiltonian object, not a subfunctor in the monomorphism sense. Consequently, the pullback of witnessed data is not itself a subset that can be subtracted from the parameter space. Define the qualitative gapped locus as the image or support of the witness projection, or quotient witnesses suitably.

### MAJOR

- **Clarify LTQO degeneracy (Sections 7.3 and 7.4).** The selected nondegenerate state refers to the vacuum vector in a chosen infinite-volume GNS sector. It does not remove the topological degeneracy of finite-volume local ground spaces handled by LTQO.
- **Add a foundational GNS reference (Section 3.4).** Cite Bratteli and Robinson, *Operator Algebras and Quantum Statistical Mechanics 2*, for ground states and positive GNS generators.

### MINOR

- **Empty complement in the band-gap definition.** Require the selected band to have a nonempty spectral complement, or declare an infinity convention.
- **Explain the lattice tail condition.** On a translation-invariant lattice, the tail sum is independent of the base point and reduces to the tail of a convergent series.
- **Relate compactness to finite-cover descent.** Compactness allows a locally supplied open-cover family of quantitative bounds to be reduced to a finite subcover, after which their positive minimum is a common bound, provided the predicate and witness conventions agree.

VERDICT: MAJOR REVISIONS
