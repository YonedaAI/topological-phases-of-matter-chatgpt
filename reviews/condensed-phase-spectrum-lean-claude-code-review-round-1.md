# Claude code review: Condensed phase spectrum Lean, round 1

Review complete. Claude read the synthesis paper, synthesis brief, synthesis
module, imported interfaces, root import, and executable tests.

## Results

- Exact five-stage program: PASS.
- Construction flow versus categorical variance: PASS. The categorical form
  is `Int -> Ham <- Gap -> Phase -> IP`.
- Quantitative witness data versus propositional gapped image: PASS.
- Conditional localization, stabilization, stacking, invertibility, and
  spectrification providers: PASS. No fabricated implementations were found.
- Homotopy interpretation: PASS. Pump and defect meanings require optional
  providers, and a based `S^k` family targets codimension `k + 1`.
- Typed reuse of Paper 5 relative-charge interfaces: PASS.
- Claim-status discipline: PASS, with the minor inherited mismatch below.
- Tests and safety scan: PASS. No `sorry`, `admit`, global assumption, or
  `unsafe` declaration was found.

## Findings

### F1, minor: universal relative-charge claim has the wrong status

`lean/TopologicalPhases/PhysicalRealizability.lean` states "Every relative
generalized cohomology class is a physical transition charge" with status
`proposed`. The accepted synthesis claim ledger marks that universal statement
`obstructed`, because a microscopic invariant and natural comparison map are
additional required data. The status should be changed to `obstructed`, or the
claim should be reworded conditionally.

### F2, informational: composite arrow label can be more precise

The main `stabilizedPhases -> condensedPhaseSpectrum` arrow is labelled
`connectiveSpectrification`, although it includes restriction to the physical
invertible sector before spectrification. The factored arrows are correct, but
a composite label would improve the main diagram's bookkeeping.

### F3, informational: missing source on established provenance

`freedHopkinsClassificationProvenance` is established but has no source entry.
Adding the Freed-Hopkins paper would make it consistent with other established
provenance records.

VERDICT: PASS
