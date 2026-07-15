# Physical realizability registry

The registry stores the explicit witness fields used by
`physical-realizability.tex`. It checks the spatial to spacetime dimension
shift, the completeness of rows marked `Realized`, the scope of abstract
comparisons, and the degree shifts for a relative connecting class and an
oriented Thom localization.

Three rows reproduce the paper's verified low-dimensional matrix. A fourth
row deliberately records the general Freed-Hopkins realization question as
`Open`; it illustrates a contract-valid row that is not a completed
microscopic witness.

Build and run with a compatible GHC:

```sh
make run
```

The build uses `-Wall -Wextra -Werror`. Only `base` is required. Published
gap theorems are stored as named witnesses; the finite program does not
purport to prove them.
