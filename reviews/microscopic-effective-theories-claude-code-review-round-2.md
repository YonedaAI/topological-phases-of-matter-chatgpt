# Claude Haskell review, round 2

Reviewer: Claude Opus, high effort, read-only (`Read`, `Glob`, `Grep`)

## Prior findings

1. **Sampling adequacy: resolved.** For
   $q(k)=t_1+t_2e^{ik}$, Claude checked
   $|d\arg(q)/dk|\leq |t_2|/|q|$ and
   $\min_k|q(k)|=||t_1|-|t_2||$. The implemented bound
   $2\pi|t_2|/(N\,||t_1|-|t_2||)<\pi$ is a sufficient condition for every
   true phase increment to remain inside the principal branch.
2. **Branch ambiguity: resolved.** Both numerical winding routines reject an
   increment reaching magnitude $\pi$.
3. **Invalid floating-point data: resolved.** Model, tolerance, momentum, and
   norm validation now reject `NaN`, infinity, negative tolerances, and
   overflow where the API can report an error. `isGapped` conservatively
   returns `False` for an invalid model.
4. **Test independence: resolved.** Tests now cover trivial and topological
   phases, negative hoppings, broken symmetry, the gapless point,
   undersampling, non-finite data, and a semantic disjointness invariant for
   retained, discarded, and outside-domain information.
5. **Zero-sample partiality: resolved.** Momentum and sampled-gap helpers now
   return `[]` and `Nothing` on invalid sample counts.

## Independent recheck

Claude independently rechecked the arbitrary-sign SSH gap formula, analytic
winding, exact symmetry-breaking detour gap, relative orientation and local
degree, all three comparison arrows, explicit module exports, all top-level
type signatures, and strict-warning compatibility by inspection. It found no
mathematical overclaim: the inverse lattice-realization arrow remains an open
problem and the code explicitly excludes a general many-body scaling limit.

Two residual observations were non-blocking: the runtime branch check is
redundant after the a-priori sampling bound, and the information-loss property
checks category structure rather than exact string content.

VERDICT: PASS
