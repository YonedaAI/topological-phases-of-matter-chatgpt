# Synthesis status validator

This small executable checks the dependency contract in the synthesis paper.
It does not prove a Lieb-Robinson bound, a thermodynamic spectral gap, or a
comparison theorem.

The validator requires the exact five-stage order, represents the qualitative
gapped locus by a propositional image rather than the witness fibration, and
rejects equivalence claims without theorem providers. It also checks the
degree shift for relative classes, Thom-orientation bookkeeping, microscopic
qualification of physical charges, and the relation `n = d + 1`.
Orientation is required only when a Thom target is asserted. If no Thom
localization is claimed, the registry leaves the orientation field unused.

`ContractChecks.hs` contains executable consistency checks. They are not
called proofs because they verify this finite data contract, not the analytic
or homotopical statements in the paper.

Run it with:

```sh
make test
```

Compilation uses `-Wall -Wextra -Werror`.
