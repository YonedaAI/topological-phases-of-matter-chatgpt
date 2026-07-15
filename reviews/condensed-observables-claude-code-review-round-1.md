# Claude code review, round 1

Artifact: `src/condensed-observables/Main.hs`

Review complete. The file is mathematically sound; all findings are minor.

## Mathematical correctness

- `adjoint` is the correct conjugate transpose.
- `multiply` implements the standard two by two matrix product.
- `isHermitian` checks the diagonal and off-diagonal conditions with a tolerance.
- `isPositiveSemidefinite` uses the correct Hermitian two by two criterion: nonnegative diagonal entries and determinant.
- `stateExpectation` computes `Tr(rho A)`.
- `hermitianEigenvalues` uses the correct closed form, and `hermitianSpectralNorm` returns the maximum absolute eigenvalue.
- `supNorm` returns the maximum fiber norm, with zero for an empty family.
- `binaryValue`, `clopenApproximation`, and `clopenErrorBound` implement the stated binary expansion and the tail bound `2^(-n)`.

## Findings

1. Minor: the adjoint involution self-check uses a real symmetric matrix and therefore does not discriminate against an implementation that omits conjugation.
2. Minor: multiplication is exercised only on diagonal matrices, so the off-diagonal product formulas are not tested directly.
3. Minor: `hermitianSpectralNorm` is partial on non-Hermitian input, `supNorm` inherits that partiality, and `binaryValue` is not productive on an infinite list. These input contracts are not documented.
4. Minor: the clopen check compares a length-12 truncation to a length-40 truncation, not directly to an exact infinite value. The checked inequality is nevertheless valid.
5. Information: the numerical comparisons use a fixed absolute tolerance.
6. Information: multiplication would be the more idiomatic spelling for squaring than `(** 2)`, with no correctness impact here.
7. Information: failing self-checks use `error`, which still produces a suitable nonzero exit status.

## Structure and flags

- The module has an explicit export list.
- Every top-level binding has an explicit type signature.
- `-Wall -Wextra -Werror` is enabled.
- All six checks assert mathematically correct statements.

Everything asserted is mathematically correct and the program runs deterministically. The weaknesses concern test discrimination and documentation, not correctness.

VERDICT: PASS
