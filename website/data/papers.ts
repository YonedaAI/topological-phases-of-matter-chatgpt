export type ClaimStatus =
  | "established"
  | "proposed"
  | "conjectural"
  | "open"
  | "obstructed";

export type Paper = {
  slug: string;
  sequence: string;
  shortTitle: string;
  metadataTitle: string;
  title: string;
  subtitle: string;
  description: string;
  pages: number;
  stage: string;
  stageIndex: number;
  status: ClaimStatus;
  statusNote: string;
  accent: "teal" | "coral" | "violet";
  codeFiles: string[];
  leanFiles: string[];
  reviewFiles: string[];
};

export const papers: Paper[] = [
  {
    slug: "locality-condensed-families",
    sequence: "I",
    shortTitle: "Uniform locality",
    metadataTitle: "Uniform Locality for Quantum Lattices",
    title: "Uniform Locality for Condensed Families of Quantum Lattice Interactions",
    subtitle: "The analytic first arrow",
    description:
      "Uniform interaction norms, not profiniteness, give parameter-independent Lieb-Robinson bounds. Thermodynamic dynamics also require a uniform vanishing tail.",
    pages: 23,
    stage: "Local quantum interactions",
    stageIndex: 1,
    status: "established",
    statusNote: "Established under explicit F-norm hypotheses",
    accent: "teal",
    codeFiles: ["Locality.hs", "Main.hs", "Makefile", "README.md"],
    leanFiles: ["TopologicalPhases/Locality.lean"],
    reviewFiles: [
      "locality-condensed-families-agy-review.md",
      "locality-condensed-families-claude-code-review.md",
    ],
  },
  {
    slug: "condensed-observables",
    sequence: "II",
    shortTitle: "Condensed observables",
    metadataTitle: "Condensed Families of Quantum Observables",
    title: "Condensed Families of Quantum Observables",
    subtitle: "Positivity, C*-norms, and descent",
    description:
      "Section algebras preserve fiberwise positivity and the supremum C*-norm while separating analytic structure from bare condensed algebra.",
    pages: 24,
    stage: "Condensed moduli stack",
    stageIndex: 2,
    status: "established",
    statusNote: "Established objectwise; categorical scope is explicit",
    accent: "teal",
    codeFiles: ["Main.hs"],
    leanFiles: ["TopologicalPhases/Observables.lean"],
    reviewFiles: [
      "condensed-observables-agy-review.md",
      "condensed-observables-claude-code-review.md",
    ],
  },
  {
    slug: "thermodynamic-gaps",
    sequence: "III",
    shortTitle: "Thermodynamic gaps",
    metadataTitle: "Thermodynamic Spectral Gaps",
    title: "Thermodynamic Spectral Gaps in Parameterized Quantum Lattice Systems",
    subtitle: "Witnesses, images, and stability",
    description:
      "A quantitative gap witness is data; the qualitative uniformly gapped locus is its propositional image, conditional on analytic input.",
    pages: 24,
    stage: "Uniformly gapped substack",
    stageIndex: 3,
    status: "proposed",
    statusNote: "Proposed packaging with established conditional analytic inputs",
    accent: "coral",
    codeFiles: ["Core.hs", "Main.hs", "Properties.hs"],
    leanFiles: ["TopologicalPhases/SpectralGaps.lean"],
    reviewFiles: [
      "thermodynamic-gaps-agy-review.md",
      "thermodynamic-gaps-claude-code-review.md",
    ],
  },
  {
    slug: "microscopic-effective-theories",
    sequence: "IV",
    shortTitle: "Microscopic → effective",
    metadataTitle: "Lattice Hamiltonians to Effective Theories",
    title: "From Microscopic Lattice Hamiltonians to Effective Theories",
    subtitle: "Three maps, not one equivalence",
    description:
      "Functional calculus gives a controlled free-fermion map to K-theory, while scaling, classification, and inverse realization remain distinct.",
    pages: 33,
    stage: "Stabilized phase ∞-groupoid",
    stageIndex: 4,
    status: "open",
    statusNote: "Controlled in free settings; a universal equivalence is open",
    accent: "violet",
    codeFiles: ["Core.hs", "Main.hs", "Proofs.hs", "Properties.hs"],
    leanFiles: ["TopologicalPhases/MicroscopicEFT.lean"],
    reviewFiles: [
      "microscopic-effective-theories-agy-review.md",
      "microscopic-effective-theories-claude-code-review.md",
    ],
  },
  {
    slug: "physical-realizability",
    sequence: "V",
    shortTitle: "Physical realizability",
    metadataTitle: "Realizability of Invertible Phase Classes",
    title: "Physical Realizability of Invertible Phase Classes",
    subtitle: "From abstract class to lattice witness",
    description:
      "Kitaev, BDI, and AKLT models verify concrete low-dimensional rows without claiming every bordism or homotopy class is realizable.",
    pages: 22,
    stage: "Stabilized phase ∞-groupoid",
    stageIndex: 4,
    status: "open",
    statusNote: "Explicit witnesses exist; general surjectivity is open",
    accent: "violet",
    codeFiles: ["Main.hs", "Makefile", "README.md", "Realizability.hs"],
    leanFiles: ["TopologicalPhases/PhysicalRealizability.lean"],
    reviewFiles: [
      "physical-realizability-agy-review.md",
      "physical-realizability-claude-code-review.md",
    ],
  },
  {
    slug: "invertible-condensed-phase-spectrum",
    sequence: "S",
    shortTitle: "Phase spectrum program",
    metadataTitle: "Invertible Condensed Phase Spectrum",
    title: "The Invertible Condensed Phase Spectrum Program",
    subtitle: "Conditional assembly and claim-status ledger",
    description:
      "The synthesis keeps the five-stage program precise: solid analytic inputs, conditional categorical assembly, and no unproved spectrum comparison.",
    pages: 32,
    stage: "Invertible condensed phase spectrum",
    stageIndex: 5,
    status: "proposed",
    statusNote: "Proposed spectrum; conditional assembly theorem",
    accent: "violet",
    codeFiles: [
      "ContractChecks.hs",
      "Core.hs",
      "Main.hs",
      "Makefile",
      "Properties.hs",
      "README.md",
    ],
    leanFiles: ["TopologicalPhases/CondensedPhaseSpectrum.lean"],
    reviewFiles: [
      "invertible-condensed-phase-spectrum-agy-review.md",
      "invertible-condensed-phase-spectrum-claude-code-review.md",
    ],
  },
];

export const stages = [
  {
    index: 1,
    label: "Local quantum interactions",
    notation: "Φ ∈ 𝓑F",
    tone: "teal",
    claim: "Uniform F-norm control supplies propagation estimates; tail control supplies thermodynamic dynamics.",
  },
  {
    index: 2,
    label: "Condensed moduli stack of Hamiltonians",
    notation: "Hamcond",
    tone: "teal",
    claim: "Families and descent organize Hamiltonians and observables.",
  },
  {
    index: 3,
    label: "Uniformly gapped propositional substack",
    notation: "Gap ⊂ Hamcond",
    tone: "coral",
    claim: "Uniform gappedness is a property only after witnesses are projected.",
  },
  {
    index: 4,
    label: "Stabilized phase ∞-groupoid",
    notation: "Ph∞",
    tone: "violet",
    claim: "Localize controlled paths, then stabilize under atomic ancillas.",
  },
  {
    index: 5,
    label: "Invertible condensed phase spectrum",
    notation: "Ephase",
    tone: "violet",
    claim: "A spectrum follows only after descent and coherence are established.",
  },
] as const;

export const ledgerClaims = [
  {
    id: "A.1",
    status: "established" as ClaimStatus,
    claim: "Uniform interaction norms imply uniform Lieb-Robinson estimates.",
    scope: "Under the stated summability and convolution hypotheses on F.",
  },
  {
    id: "A.2",
    status: "established" as ClaimStatus,
    claim: "C(S,A) carries pointwise positivity and the supremum C*-norm.",
    scope: "For compact Hausdorff S and a fixed C*-algebra A.",
  },
  {
    id: "A.3",
    status: "established" as ClaimStatus,
    claim: "A uniformly gapped locus supports stable spectral flow.",
    scope: "Requires a common gap and the relevant locality/stability assumptions.",
  },
  {
    id: "C.1",
    status: "open" as ClaimStatus,
    claim: "Controlled microscopic systems map to effective invariants.",
    scope: "Established in selected free and low-dimensional settings, not universally.",
  },
  {
    id: "P.1",
    status: "proposed" as ClaimStatus,
    claim: "The stabilized invertible sector defines a condensed spectrum.",
    scope: "Descent, coherences, and comparison maps remain research obligations.",
  },
];

export function paperBySlug(slug: string) {
  return papers.find((paper) => paper.slug === slug);
}
