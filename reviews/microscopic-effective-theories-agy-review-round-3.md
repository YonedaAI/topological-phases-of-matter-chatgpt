---
reviewer: AGY, Gemini 3.1 Pro (High)
type: scientific peer review
paper: microscopic-effective-theories
round: 3
date: 2026-07-14
---

# Referee report

## Overview and physics scope

The manuscript provides a clear and rigorous disambiguation of the maps connecting microscopic lattice Hamiltonians, low-energy effective field theories (EFTs), operator K-theory, and bordism classifications. By explicitly separating the microscopic-to-EFT scaling limit, the EFT-to-bordism classification, and the abstract-to-lattice realization problem, the author avoids compressing these distinct mathematical operations into a single commutative square of "equivalence."

## Mathematical correctness and assumptions

The paper's mathematical framework is sound. The application of continuous functional calculus to extract the Fermi projection and operator K-class is executed correctly. The analysis of the SSH model, including the explicit band-gap calculations, transition charges, and the staggered-mass detour, is analytically precise. The framing of the BDI Fidkowski-Kitaev interaction reduction as a boundary on the unmodified extension of free K-theory is physically insightful and mathematically correct. The assumptions strictly control the scope, including the distinction between mobility gaps and C*-spectral gaps, and deliberately forbid overclaims.

## Verification of post-acceptance corrections

Both requested post-acceptance corrections have been integrated without introducing a new issue.

1. **Relative K-class definition and signs.** The manuscript enforces the convention
   $\kappa(\text{target},\text{reference})=[\text{target}]-[\text{reference}]$.
   The main definition is
   $\kappa_S(h,h_{\mathrm{ref}})=[p_h]-[p_{h_{\mathrm{ref}}}]$.
   Appendix B.2 correctly derives
   $\kappa(h_0,h_2)=\kappa(h_0,h_1)+\kappa(h_1,h_2)$, which expands to
   $[p_{h_0}]-[p_{h_2}]=([p_{h_0}]-[p_{h_1}])+([p_{h_1}]-[p_{h_2}])$.
   Appendix B.3 correctly handles the reference change
   $\kappa(h,r')=\kappa(h,r)+\kappa(r,r')$.

2. **Separation of comparison diagrams and domain restrictions.** The diagram is properly decoupled into two distinct chains. The top chain confines the established flattening map to the $\Ham^{\mathrm{free,gap}}\to K_{\mathrm{op}}$ domain. The bottom chain is
   $\Ham^{\mathrm{micro,gap}}\dashrightarrow\EFT^{\mathrm{invertible}}\to\Class^{\mathrm{bord}}\dashrightarrow\Real_{\mathrm{lattice}}$.
   The realization map now targets explicit lattice realizations. The text disclaims any unsupported $K_{\mathrm{op}}$-to-EFT map or commutative square. The established labeling of $I$ is restricted to the reflection-positive invertible-EFT domain classified by Freed and Hopkins.

## Literature, notation, and exposition

The citation list is relevant and representative, covering foundational topology and operator-algebra papers and recent condensed-mathematics formalisms. The notation is standard for C*-algebraic physics and easy to follow. The status vocabulary and equivalence-audit table make the boundaries of the paper's claims explicit.

The manuscript is mathematically accurate, physically precise, and readable. The required corrections have been implemented successfully.

VERDICT: ACCEPT
