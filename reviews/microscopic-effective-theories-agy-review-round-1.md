---
reviewer: AGY, Gemini 3.1 Pro (High)
type: scientific peer review
paper: microscopic-effective-theories
round: 1
date: 2026-07-14
---

# Referee report

## General comments

The manuscript provides a highly rigorous, conceptually clear, and mathematically precise framework separating three distinct operations often conflated in the study of topological phases: the low-energy effective field theory limit, stable invariant extraction via operator K-theory, and microscopic lattice realization. The careful treatment of C*-algebraic continuous functional calculus, coupled with exact calculations in the Su-Schrieffer-Heeger model and the BDI interacting boundary, makes this a strong conceptual contribution to the mathematical-physics literature. The incorporation of condensed mathematics via Aoki's solidification results is constrained appropriately, using it for organizational and homological descent without presenting it as a substitute for analytic gap estimates.

## Mathematical correctness and physics scope

- **Functional calculus and K-theory:** The use of continuous functional calculus for $M_N(C(S,A))$ to produce the flattened Hamiltonian involution and relative $K_0$ class is correctly executed. The proof of gapped-homotopy invariance and stacking additivity uses standard C*-algebraic arguments.

- **Disorder and mobility gaps:** The warning distinguishing C*-spectral gaps from mobility gaps is an important physical clarification. The crossed-product algebra handles the stated spectral-gap construction, while localized regimes require separate Sobolev or localization estimates and index pairings.

- **SSH computations:** The gap, winding, local transition charge, and symmetry-breaking detour are correct. The local momentum-mass linking circle has degree $-1$ in the stated orientation. The detour correctly shows that the distinction disappears when AIII chiral symmetry is not enforced.

- **The BDI boundary:** The use of the Fidkowski-Kitaev $\mathbb Z$ to $\mathbb Z/8$ reduction is accurate and correctly limits any attempted universal promotion of the free classification.

- **Equivalence audit:** The equivalence audit and final comparison checklist give a useful standard for future lattice and EFT comparison claims.

## Critical or major issues

None. The theorem hypotheses, proofs, limitations, and topological calculations are sound. The physical scope is stated precisely, and the information-loss contract is delivered.

## Minor corrections and suggestions

1. In the introduction, typeset "infinity-groupoid" as "$\infty$-groupoid" to match standard homotopy-theoretic notation.

2. Near the local Taylor expansion, note explicitly that a scalar energy shift has already been removed using the Fermi-level convention.

3. The Aoki citation correctly points to arXiv:2409.01462. Keep its year synchronized with the cited revision or final publication record.

VERDICT: ACCEPT
