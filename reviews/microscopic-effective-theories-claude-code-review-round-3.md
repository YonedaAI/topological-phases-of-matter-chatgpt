# Code review: Paper 4 Haskell interface (release correction to `relativeWinding`)

**Summary: the release correction is implemented correctly, every call site uses the new argument order with consistent semantics, the additivity identity remains valid, and I found no correctness defects. Only low-severity maintainability notes below.** Line numbers refer to the embedded sources.

## Focal item: `relativeWinding` signature and semantics — CORRECT

`Core.hs:192-196` defines exactly what the correction requires:

```haskell
relativeWinding :: Double -> SSHModel -> SSHModel -> Either String Int
relativeWinding tolerance target reference = do
  targetClass <- winding tolerance target
  referenceClass <- winding tolerance reference
  pure (targetClass - referenceClass)
```

Tolerance first, then target, then reference, computing target − reference — literally κ(target, reference) = target − reference. The Haddock comment (`Core.hs:190-191`, "target first and reference second: target winding minus reference winding") matches the code, and the export list (`Core.hs:27`) publishes it. Parameter validation is inherited from `winding` (tolerance and both models are validated), so no unvalidated path exists.

## All call sites verified — six total, all consistent with the new order

1. **Main.hs:49** — `relativeWinding 1.0e-12 topologicalModel trivialModel` under the label "topological minus trivial winding". With w(topological)=1 (|0.5|<|1.0|) and w(trivial)=0 (|1.5|>|1.0|), this prints 1, matching the label. Correct.
2. **Properties.hs:~111** — property "relative class is target minus reference" expects `Right 1` for `(topologicalModel, trivialModel)`. Under the new semantics 1−0=1. Correct, and this property would fail under the old (reference-first) order, so it genuinely pins the correction.
3. **Proofs.hs:~96-98** (`relativeAdditivityCheck`) — three calls where the binding names encode the semantics: `secondFromFirst = relativeWinding tolerance second first` reads as "class of second measured from first" = w(second)−w(first). Names and argument order agree.
4. **Proofs.hs (`transitionBoundaryCheck`)** — `jump <- relativeWinding tolerance topological trivial` gives +1; the check asserts `charge == negate jump` with `localTransitionCharge 4096` = −1. Correct, and orientation-sensitive: under the old order this check would have failed, so the reported 5/5 is consistent with the corrected semantics being live.

## Additivity identity — still valid and non-vacuous

With first=(1.5,1,0) → w=0, second=(0.5,1,0) → w=1, third=(2.0,1,0) → w=0: secondFromFirst=1, thirdFromSecond=−1, thirdFromFirst=0, and 0 = 1 + (−1) holds. The identity κ(c,a)=κ(b,a)+κ(c,b) is algebraically guaranteed by target-minus-reference semantics, and the chosen triple crosses phases (values 1, −1, 0), so the check is not trivially 0+0=0. The detail string "trivial, topological, trivial triple" accurately describes the fixtures.

## Numerical and mathematical spot-checks — all preserved

- `halfGap` = √((|t₁|−|t₂|)² + m²) is the exact minimum of |d(k)| for this Bloch vector (min over cos k ∈ [−1,1] handles both hopping signs). `gapFormulaCheck`'s 4096-segment mesh contains both k=0 and k=π exactly, so it hits the analytic minimum for all four fixture models, including the negative-hopping one whose minimum is at k=0.
- The detour keeps bandGap exactly 2r = 1.0: |t₁|−|t₂| = r·cos a and m = r·sin a, so halfGap = r identically. Both `detourHasConstantGap` and `detourGapCheck` are checking a true invariant.
- `numericWinding`'s coarse-mesh guard (`Core.hs:172,186-188`) is mathematically sufficient, not just heuristic: |dφ/dk| ≤ |q′|/|q| ≤ |t₂|/chiralHalfGap, so `angularStepBound` bounds the true per-segment phase variation, and requiring it < π rules out branch-cut aliasing. The per-increment `>= pi` check is redundant defense-in-depth. The gapless rejection (chiralHalfGap ≤ tolerance) also guarantees no division by a zero q-value.
- `localTransitionCharge` computes the degree of e^(−iθ), which is −1 for any samples ≥ 4; the increments are −2π/samples, safely below π.
- Counts match the reported run: `properties` has exactly 20 entries and `proofChecks` exactly 5. Property 20 additionally gates on `all proofPassed proofChecks`, so 20/20 and 5/5 are mutually consistent.
- Error handling is thorough and tested: non-finite parameters, non-finite momenta, negative/non-finite tolerances, undersampled meshes, broken chiral symmetry, and the gapless discriminant all return `Left` and are exercised by properties 10-12 and 14.
- No import cycles (Core ← Proofs ← Properties ← Main), no unused imports, no defaulting or shadowing that would trip `-Wall -Wextra -Werror`; consistent with the clean GHC 9.10.1 build.

## Findings

1. **Low (maintainability) — duplicated fixtures and helpers.** `topologicalModel`/`trivialModel` are defined independently in `Main.hs:16-20` and `Properties.hs:21-25`, and `approx` is duplicated in `Properties.hs:15-16` and `Proofs.hs` (with the same 1.0e-9 threshold). If a fixture or threshold changes in one module but not the other, the demo output and the checks could silently diverge. No behavioral impact today.
2. **Low (error reporting) — `relativeWinding` errors don't identify the failing operand.** `Core.hs:193-196`: if the target and reference can each fail with identical messages (e.g. "the staggered mass breaks chiral symmetry"), the caller cannot tell which model was rejected. Fine for release; worth a message prefix if this becomes user-facing.
3. **Info (docs consistency) — `Properties.hs` lacks the Haddock module header** (copyright/license/maintainer) that Core, Main, and Proofs all carry.
4. **Info (robustness, unreachable in current call graph) — `bandGap`/`minimumBandGap` propagate NaN silently** for non-finite models, and `minimum` over a list containing NaN is unreliable (`Proofs.hs:45`, `Core.hs` `minimumBandGap`). Every current call path is validated upstream (detour output, fixed finite fixtures), so no reachable defect; noted only because these are exported.
5. **Info (redundancy, arguably intentional) — proof checks are double-gated.** Property 20 embeds `all proofPassed proofChecks` and `main` separately requires `runProofs` to pass, so a proof failure fails both counters. Harmless; it does mean the two summary lines are not independent signals.

None of these affect correctness, the published numeric results, or the release correction.

VERDICT: PASS
