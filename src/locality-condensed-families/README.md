# Locality and gap diagnostics

This small Haskell program evaluates finite proxies for the decay assumptions
used in `locality-condensed-families.tex`. It also displays the moving weak
defect family, whose individual fibers are gapped while its gaps have no
positive uniform lower bound.

Build and run it with:

```sh
make run
```

The build uses `-Wall -Wextra -Werror`. The program depends only on `base`.
Its numerical outputs are finite diagnostics, not proofs about the infinite
system.
