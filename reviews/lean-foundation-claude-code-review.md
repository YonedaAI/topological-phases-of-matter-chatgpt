# Independent Lean 4 Review: Topological Phases Library

## Findings

1. **Low: `ObjectwiseInvolution` imposes only involutivity, not the star-algebra laws.** `lean/TopologicalPhases/Observables.lean:6-9` requires `star (star v) = v` and nothing else. It is honest under the literal reading of "involution," and the downstream `starSquarePositive` and `cstarIdentity` fields use it meaningfully. It is weaker than a genuine C-star involution because additivity and anti-multiplicativity are absent. This is acceptable as a minimal conditions interface, but a concrete instance should not mistake it for a full star-ring.

2. **Low: `toyCone` is a degenerate positive cone.** `lean/TopologicalPhasesTest.lean:28-39` sets every element to positive. This is a legitimate instance of `ObjectwisePositiveCone` and is honestly presented as an interface smoke test, not a physical cone. It exercises the laws vacuously.

3. **Low: `PhaseEquivalence` does not constrain `Stacking.atomic` and assumes no monoid laws.** `lean/TopologicalPhases/Core.lean:47-61` gives congruence under stacking but does not state associativity, commutativity, or a unit law. This is consistent with the requested interface scope.

4. **Information: the deep-result interfaces are never inhabited.** `LiebRobinsonTheoremInterface` in `lean/TopologicalPhases/Locality.lean:82-95` and `AokiConnectiveComparisonInterface` in `lean/TopologicalPhases/Observables.lean:53-62` take explicit predicates. An implementer could choose trivial predicates, but this library constructs no provider. It therefore asserts no thermodynamic limit, propagation estimate, or solidification theorem. The provenance entries are data with citations, not proofs. This satisfies the requirement to represent deep results as interfaces or documented assumptions without fake analytic proofs.

All required components are present and honest: the self-contained project, status and provenance, finite metric sites and local supports, parameterized uniform bounds, a finite-volume gap witness, objectwise involution and positivity, C-star norm conditions, stacking and phase equivalence, and finite executable examples. There is no `sorry`, `admit`, or user-declared logical assumption. Names and assumptions are readable, and the library stays conservatively minimal.

## Verification assessment

This was a read-only review. Claude did not build, execute, or edit the project. The reported successful `lake build`, executable test run, and axiom inspection are consistent with the source. No type-level dishonesty, fake analytic proof, or compilation red flag was found.

## Verdict

The findings are low-severity or informational limitations of intentionally small interfaces. None makes a stated result false or violates the contract.

VERDICT: PASS
