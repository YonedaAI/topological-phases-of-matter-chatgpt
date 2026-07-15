# Topological Phases of Matter in Condensed Mathematics

This repository develops a six-paper research program for organizing topological phases and phase transitions in a condensed-mathematical setting. Its central question is precise: how far can one pass from local quantum lattice interactions to an invertible phase spectrum without hiding the analytic conditions that make the systems physical?

Read the papers and inspect the executable artifacts on the [live research site](https://condensed-phase-spectrum.vercel.app). The public source repository is [YonedaAI/topological-phases-of-matter-chatgpt](https://github.com/YonedaAI/topological-phases-of-matter-chatgpt).

The proposed sequence is

\[
\text{local quantum interactions}
\longrightarrow
\text{condensed moduli stack of Hamiltonians}
\longrightarrow
\text{uniformly gapped substack}
\longrightarrow
\text{stabilized phase }\infty\text{-groupoid}
\longrightarrow
\text{invertible condensed phase spectrum}.
\]

This is a conditional program, not a claimed general theorem. Each paper separates established results from proposed definitions, conjectures, open problems, and known obstructions. In particular, condensed descent does not create Lieb-Robinson bounds, positivity, a C*-norm, a thermodynamic gap, an effective field theory, or a microscopic realization.

## Papers

| Paper | Question | PDF | Source | Executable model |
|---|---|---|---|---|
| Uniform Locality for Condensed Families | Which uniform hypotheses support parameterized Lieb-Robinson estimates and thermodynamic dynamics? | [PDF](papers/pdf/locality-condensed-families.pdf) | [LaTeX](papers/latex/locality-condensed-families.tex) | [Haskell](src/locality-condensed-families/) |
| Condensed Families of Quantum Observables | How do positivity, C*-norms, states, descent, and solid K-theory fit together? | [PDF](papers/pdf/condensed-observables.pdf) | [LaTeX](papers/latex/condensed-observables.tex) | [Haskell](src/condensed-observables/) |
| Thermodynamic Spectral Gaps | What data witnesses a uniform bulk gap, and when is that gap stable? | [PDF](papers/pdf/thermodynamic-gaps.pdf) | [LaTeX](papers/latex/thermodynamic-gaps.tex) | [Haskell](src/thermodynamic-gaps/) |
| From Microscopic Lattice Hamiltonians to Effective Theories | Which comparison maps are established, conditional, or still open? | [PDF](papers/pdf/microscopic-effective-theories.pdf) | [LaTeX](papers/latex/microscopic-effective-theories.tex) | [Haskell](src/microscopic-effective-theories/) |
| Physical Realizability of Invertible Phase Classes | Which abstract bordism or homotopy classes have explicit, uniformly gapped lattice witnesses? | [PDF](papers/pdf/physical-realizability.pdf) | [LaTeX](papers/latex/physical-realizability.tex) | [Haskell](src/physical-realizability/) |
| The Invertible Condensed Phase Spectrum Program | How do the five layers assemble, and exactly where are theorem providers still missing? | [PDF](papers/pdf/invertible-condensed-phase-spectrum.pdf) | [LaTeX](papers/latex/invertible-condensed-phase-spectrum.tex) | [Haskell](src/invertible-condensed-phase-spectrum/) |

Each paper also has a page-one image in [`images/`](images/) and independent review records in [`reviews/`](reviews/).

## What the program establishes

The papers prove or carefully reuse several controlled bridges:

- uniform interaction bounds yield parameter-uniform Lieb-Robinson estimates under the stated geometric and decay hypotheses;
- compactly parameterized section algebras carry pointwise C*-operations, fiberwise positivity, and finite-cover descent;
- a quantitative gap-witness fibration can be separated from its qualitative propositional image;
- bounded free-fermion Hamiltonians with a common Fermi-level gap determine relative operator K-classes;
- selected low-dimensional bordism and homotopy classes have explicit lattice representatives.

The general comparison from interacting microscopic models to effective field theories, and the general realization map from abstract classes back to uniformly gapped lattice systems, remain open. The synthesis records these missing maps as interfaces, not assumptions disguised as conclusions.

## Formal and executable representations

The shared Lean library in [`lean/`](lean/) represents the architecture, dependency contracts, claim statuses, and selected finite statements. It deliberately does not claim to formalize the analytic theorems cited by the papers.

```sh
cd lean
lake build
lake exe topological-phases-test
```

The Haskell programs in [`src/`](src/) are executable contract checks and finite diagnostics. They are not proofs of infinite-volume locality, stability, or realizability. Packages with a `Makefile` can be run directly, for example:

```sh
make -C src/locality-condensed-families run
make -C src/physical-realizability run
make -C src/invertible-condensed-phase-spectrum test
```

## Repository map

- [`context/`](context/) contains the originating research perspective.
- [`.knowledge-base.md`](.knowledge-base.md) records shared definitions, conventions, sources, and nonclaims.
- [`docs/research/`](docs/research/) contains one master checklist and six concise research briefs.
- [`papers/latex/`](papers/latex/) and [`papers/pdf/`](papers/pdf/) contain the reviewed manuscripts.
- [`src/`](src/) contains the Haskell representations.
- [`lean/`](lean/) contains the shared Lean representation.
- [`reviews/`](reviews/) contains scientific, code, and final consistency audits.
- [`website/`](website/) contains the static research site.

## Claim labels

The project uses five labels throughout:

- `ESTABLISHED`: a cited theorem or a proved construction under explicit hypotheses.
- `PROPOSED`: a definition or framework introduced here.
- `CONJECTURAL`: a precise claim not proved here.
- `OPEN`: no proof or counterexample is supplied in the stated scope.
- `OBSTRUCTED`: a theorem or counterexample rules out the claim as stated.

## Citation

Citation metadata is provided in [`CITATION.cff`](CITATION.cff). Individual papers contain their own bibliographies and should be cited separately when their results or formulations are used.

## License

Code and original text in this repository are released under the [MIT License](LICENSE). Third-party references remain subject to their respective licenses and citation terms.
