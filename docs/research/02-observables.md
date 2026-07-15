# Paper 2 Brief: Observables and Positivity

## Research question

Which C*-norm, involution, positivity, and state structures survive passage from quasi-local observable algebras to compactly or profinitely parameterized condensed families?

## Strongest defensible target

Prove objectwise C*-algebra and descent statements for `C(S,A)`, preserve the distinction between state families and states of a section algebra, and state Aoki's solid K-theory comparison with its exact connective and Bott-periodic qualifications.

## Dependencies

- Quasi-local C*-inductive limit.
- Compact Hausdorff or profinite parameter space.
- Chosen C*-completion and positive cone.

## Deliverables and gates

- LaTeX paper and current PDF of at least 20 pages.
- Strict Haskell checks for finite involution, positivity, states, and sup norms.
- Lean interfaces for objectwise algebraic structure and theorem providers.
- Primary-source audit and AGY publishability review.

## Nonclaims

- A condensed ring does not choose a C*-norm or positive cone.
- `State(C(S,A))` is not `C(S,State(A))`.
- Solidification does not reconstruct the observable algebra or Hamiltonian.
