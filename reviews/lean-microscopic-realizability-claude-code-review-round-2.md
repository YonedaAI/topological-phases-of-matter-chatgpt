# Claude Lean review, Papers 4 and 5, round 2

Scope: final `MicroscopicEFT.lean`, `PhysicalRealizability.lean`, and their executable tests.

## Verified fixes

- Unstable finite-band data is now an explicit item in the flattening loss contract and is not marked retained.
- Controlled flattening has an explicit boundedness predicate for family and reference data.
- Each declared Fermi-gap value is tied to its exact Hamiltonian fiber, in addition to the common positive lower bound.
- Relative-charge results are indexed by the exact base and gapped locus supplied with the pair hypotheses.
- Excision results are indexed by the exact global pair and the neighborhood carried by the excision evidence.
- Tests reject an invalid spacetime-dimension shift and verify every open comparison declaration carries no map.
- Candidate, open, and obstructed matrix states retain their distinct evidence rules.
- The connecting and Thom degree shifts and explicit orientation requirement remain correct.

No analytic or classification provider is instantiated. No global axiom, `sorry`, `admit`, fake instance, default proof, or fabricated result was found.

No remaining correctness or manuscript-fidelity defects were found.

VERDICT: PASS
