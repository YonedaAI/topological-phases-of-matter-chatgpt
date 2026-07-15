# Final Lean and Haskell audit

Date: 2026-07-14

## Scope

This is a clean, source-preserving audit of the formal and executable artifacts
for the six-paper corpus:

- 6 LaTeX manuscripts under `papers/latex/`;
- 16 Haskell modules in 6 executable packages under `src/`;
- 10 Lean files, including the root module and executable test module, under
  `lean/`.

No Lean, Haskell, or paper source was modified by this audit. The only source
change observed during the audit was the owning Paper 4 revision that made the
Haskell relative-class API literally target first and reference second. That
change was independently rebuilt and rechecked below.

## Toolchains

- GHC 9.14.1, target `aarch64-apple-darwin`:
  `/opt/homebrew/bin/ghc`
- Corroborating GHC 9.10.1, target `aarch64-apple-darwin`:
  `/Users/mlong/.ghcup/bin/ghc-9.10.1`
- Lean 4.32.0, `arm64-apple-darwin24.6.0`, commit
  `8c9756b28d64dab099da31a4c09229a9e6a2ef35`
- Lake 5.0.0

An earlier GHC 9.14.1 invocation transiently emitted architecture-mismatched
assembler diagnostics. A clean direct reproduction attempt then succeeded, as
did a complete clean rebuild of all six packages with the same 9.14.1 binary.
The failure did not recur, was not attributable to a source change, and is not
a source or release finding. All six packages also passed under native GHC
9.10.1.

## Haskell rebuild and executable checks

Every package was rebuilt from source with warnings as errors, then its sole
`Main.hs` executable was run. The command shape was:

```sh
cd src/<package>
rm -rf .audit-build .audit-exe
/opt/homebrew/bin/ghc \
  -fforce-recomp -Wall -Wextra -Werror <optimization> \
  -outputdir .audit-build -i. -o .audit-exe Main.hs
./.audit-exe
rm -rf .audit-build .audit-exe
```

The same six invocations were also run with
`/Users/mlong/.ghcup/bin/ghc-9.10.1`.

| Package | Modules | Optimization | Compile | Run | Executable evidence |
|---|---:|---:|---|---|---|
| `condensed-observables` | 1 | `-O0` | PASS | PASS | 8 PASS, 0 FAIL |
| `invertible-condensed-phase-spectrum` | 4 | `-O0` | PASS | PASS | 20/20 PASS, 0 FAIL |
| `locality-condensed-families` | 2 | `-O2` | PASS | PASS | all norm, propagation, gap-threshold, and weak-defect diagnostics completed; exit 0 |
| `microscopic-effective-theories` | 4 | `-O0` | PASS | PASS | 20/20 properties and 5/5 proof checks, 0 FAIL |
| `physical-realizability` | 2 | `-O2` | PASS | PASS | 4/4 rows `contract-valid=True`; registry errors `[]`; exit 0 |
| `thermodynamic-gaps` | 3 | `-O0` | PASS | PASS | 9 PASS, 0 FAIL |

Totals: 16 modules, 6 clean builds, 6 successful executables, 62 explicit
PASS labels, 0 FAIL labels, and 4 additional valid realizability contracts.
The locality executable is diagnostic rather than PASS-label based and exited
successfully.

The Paper 4 package was rerun after the target/reference correction. It again
passed 20/20 properties and 5/5 proof checks under strict warnings-as-errors.

## Lean clean build, tests, and trust checks

The clean verification commands were:

```sh
cd lean
lake clean
lake build
lake exe topological-phases-test
```

Results:

- `lake build`: PASS, 11 jobs;
- executable build: PASS, 22 jobs;
- runtime checks: 28 PASS, 0 FAIL;
- `#print axioms` directives: 42;
- all 42 reported that the named declaration does not depend on any axioms.

The static trust scans were:

```sh
rg -n '\b(axiom|sorry|admit|unsafe|native_decide)\b' lean --glob '*.lean'
rg -n '^\s*instance\b' lean --glob '*.lean'
rg -n '^\s*noncomputable\b' lean --glob '*.lean'
```

Each scan returned zero matches. In particular, there are no `sorry`, `admit`,
declared axioms, unsafe declarations, `native_decide` escapes, global
instances, or global `noncomputable` declarations in the Lean corpus.

## Cross-corpus claim and orientation audit

### Quantitative witnesses versus the propositional image

PASS.

- Paper 3 and the synthesis distinguish the quantitative gap-witness
  fibration from its propositional image.
- Lean represents the distinction as `WitnessedFamily` data versus
  `QualitativelyGapped : Prop` at
  `lean/TopologicalPhases/SpectralGaps.lean:132-150`, then reuses it as
  `QuantitativeGapFibration` and `PropositionalGappedImage` at
  `lean/TopologicalPhases/CondensedPhaseSpectrum.lean:159-178`.
- Haskell represents the alternatives as `WitnessFibration` and
  `PropositionalImage`; the synthesis validator rejects use of the former as
  the qualitative gapped locus at
  `src/invertible-condensed-phase-spectrum/Core.hs:147-150` and
  `Properties.hs:199-205`.

No code path turns a chosen quantitative witness into the definition of the
qualitative substack.

### Relative-class orientation

PASS after correction and rerun.

The corpus now uses the literal convention

```text
kappa(target, reference) = target - reference.
```

- Paper 4 uses this order in its governing definition and appendix; the
  synthesis states it explicitly at
  `papers/latex/invertible-condensed-phase-spectrum.tex:1030-1040`.
- Lean passes the family projection first and the reference projection second
  to `RelativeClass` at `lean/TopologicalPhases/MicroscopicEFT.lean:96-105`.
- Haskell now defines
  `relativeWinding tolerance target reference` and returns
  `targetClass - referenceClass` at
  `src/microscopic-effective-theories/Core.hs:190-196`.
- All Haskell callers were changed to the target-first order, and the explicit
  property `relative class is target minus reference` passed.

The initial reversed Haskell API was a release blocker. It was corrected by the
owning revision agent and is no longer present.

### Controlled free K-theory map and the three broader comparisons

PASS.

The only established microscopic flattening map in this part of the program is

```text
Ham_free,gap -> K_op.
```

Paper 4 displays it separately from the broader chain at
`papers/latex/microscopic-effective-theories.tex:1533-1565`. The broader
claims remain:

```text
Ham_micro,gap --open L--> EFT_invertible
EFT_invertible --scoped I--> stable or bordism class
stable or bordism class --open R--> Real_lattice.
```

The solid `I` is restricted to the stated effective-field-theory domain; the
papers do not claim a universal microscopic/EFT equivalence, a
`K_op -> EFT` map, or a commutative comparison square.

Lean supplies a theorem-provider interface only for the controlled bounded
free flattening sector at `lean/TopologicalPhases/MicroscopicEFT.lean:65-132`.
Its general microscopic-to-EFT and realization declarations are explicitly
`openProblem` with `suppliedMap := none` at the same file's lines 172-198.
Haskell keeps the three assessments distinct as `ControlledSector`,
`InvariantOnly`, and `OpenProblem` at
`src/microscopic-effective-theories/Core.hs:272-287`; the synthesis validator
separately records the controlled functional-calculus K-map as established on
its declared domain.

### Bordism-to-lattice realization

PASS.

The universal arrow from an abstract bordism or stable-homotopy class to an
explicit local uniformly gapped lattice representative remains OPEN in Papers
4 and 5 and in the synthesis. Lean supplies no map for the general declaration
and marks its provenance `openProblem` at
`lean/TopologicalPhases/MicroscopicEFT.lean:186-227`. Haskell's arbitrary
Freed-Hopkins torsion row has no microscopic witnesses, uses
`ComparisonOpen`, and has `realizationStatus = Open` at
`src/physical-realizability/Realizability.hs:246-258`.

No finite realized example is promoted to universal surjectivity.

### Higher families and defects

PASS, with a representation-scope note.

The synthesis says that a `pi_k` class is a based `k`-parameter family and
becomes a codimension-`k+1` physical defect only through a separate controlled
family-to-defect construction at
`papers/latex/invertible-condensed-phase-spectrum.tex:842-855`.

Lean encodes the dimension shift as
`defectCodimensionOfBasedFamily k = k + 1` and requires a
`FamilyToDefectInterface`; the provider remains optional in the homotopy
interpretation interface at
`lean/TopologicalPhases/CondensedPhaseSpectrum.lean:309-344`.

The finite Haskell synthesis validator does not model the higher-family and
defect types. It therefore neither proves nor contradicts this interpretation.
This is a deliberate executable-validator scope limit, not a status mismatch;
the precise condition is represented in Lean and in the synthesis paper.

### Stage five: represented invertibility before spectrification

PASS, with a representation-scope note.

The synthesis first restricts to the Picard subobject of phases with represented
stacking inverses, then conditionally applies internal connective
spectrification at
`papers/latex/invertible-condensed-phase-spectrum.tex:688-739`.

Lean keeps these as separate provider interfaces:
`InvertibleSectorInterface` requires represented left and right inverses at
`lean/TopologicalPhases/CondensedPhaseSpectrum.lean:223-242`, and
`InternalConnectiveSpectrificationInterface` supplies the conditional spectrum
at lines 244-255. Haskell compresses the final proposed stage into the provider
description `Picard object and internal spectrification` at
`src/invertible-condensed-phase-spectrum/Properties.hs:32-36`. Its validator
rejects promotion of any assembly arrow to `Established`.

This compression loses type-level detail in Haskell but preserves order and
epistemic status. It is not a claim contradiction.

## Independent review evidence

- The final cross-paper mathematical audit reports PASS at
  `reviews/final-cross-paper-mathematical-audit.md`.
- Fresh Paper 4 AGY round 4 explicitly accepts the target-first convention and
  the corrected comparison-map domains at
  `reviews/microscopic-effective-theories-agy-review-round-4.md`.
- Fresh post-fix Claude Haskell review round 3 at
  `reviews/microscopic-effective-theories-claude-code-review-round-3.md`
  postdates the corrected source, verifies the public
  `tolerance, target, reference` order and all six call sites, rechecks
  additivity and the preserved numeric results, and ends `VERDICT: PASS`.

The fresh Claude review records only nonblocking maintainability observations:
duplicated finite test fixtures and comparison helpers, error messages that do
not name which relative-class operand failed, one missing module header, and
some exported numeric helpers that rely on their current validated call paths.
None changes a result, claim status, or release decision.

## Artifact cleanup

After all verification runs:

```sh
cd lean && lake clean
find lean src -type f \
  \( -name '*.o' -o -name '*.hi' -o -name '*.dyn_o' \
     -o -name '*.dyn_hi' -o -name '*.hie' -o -name '*.olean' \
     -o -name '*.ilean' -o -name '*.c' -o -name '*.bc' \
     -o -name '.audit-exe' -o -name 'topological-phases-test' \
     -o -name 'synthesis-validator' -o -name 'locality-demo' \
     -o -name 'physical-realizability-demo' \) -print
```

The final artifact count is 0, and `lean/.lake/build` is absent.

FINAL VERDICT: PASS
