import TopologicalPhases.PhysicalRealizability

namespace TopologicalPhases

/-!
This module records the conditional architecture of the synthesis paper. It
keeps the prose construction order separate from the variance of the actual
categorical arrows. None of the provider interfaces below has a global
implementation in this library.
-/

/-- The five displayed stages of the research program, in prose order. -/
inductive CondensedProgramStage where
  | localQuantumInteractions
  | condensedHamiltonianModuli
  | uniformlyGappedPropositionalSubstack
  | stabilizedPhaseInfinityGroupoid
  | invertibleCondensedPhaseSpectrum
deriving DecidableEq, Repr

/-- The exact five-stage construction flow from the synthesis paper. -/
def condensedPhaseConstructionFlow : List CondensedProgramStage := [
  .localQuantumInteractions,
  .condensedHamiltonianModuli,
  .uniformlyGappedPropositionalSubstack,
  .stabilizedPhaseInfinityGroupoid,
  .invertibleCondensedPhaseSpectrum
]

/-- A prose step records dependency order, not the direction of a functor. -/
structure ConstructionFlowStep where
  source : CondensedProgramStage
  target : CondensedProgramStage
  status : ClaimStatus
deriving DecidableEq, Repr

def condensedPhaseConstructionSteps : List ConstructionFlowStep := [
  { source := .localQuantumInteractions
    target := .condensedHamiltonianModuli
    status := .proposed },
  { source := .condensedHamiltonianModuli
    target := .uniformlyGappedPropositionalSubstack
    status := .proposed },
  { source := .uniformlyGappedPropositionalSubstack
    target := .stabilizedPhaseInfinityGroupoid
    status := .proposed },
  { source := .stabilizedPhaseInfinityGroupoid
    target := .invertibleCondensedPhaseSpectrum
    status := .proposed }
]

/-- Supporting objects make witness and Picard stages visible in typed arrows. -/
inductive CondensedAssemblyObject where
  | localInteractions
  | hamiltonianModuli
  | quantitativeGapWitnesses
  | propositionalGappedLocus
  | stabilizedPhases
  | invertiblePhaseObject
  | condensedPhaseSpectrum
deriving DecidableEq, Repr

/-- The role of an arrow in the conditional assembly. -/
inductive CondensedAssemblyArrowKind where
  | analyticPackaging
  | witnessProjection
  | propositionalImage
  | gappedSubobjectInclusion
  | phaseLocalizationAndStabilization
  | stackingInvertibleSector
  | invertibleSectorAndSpectrification
  | connectiveSpectrification
deriving DecidableEq, Repr

/-- A categorical arrow carries its true variance and its research status. -/
structure CondensedAssemblyArrow where
  kind : CondensedAssemblyArrowKind
  source : CondensedAssemblyObject
  target : CondensedAssemblyObject
  status : ClaimStatus
  obligations : List String
deriving DecidableEq, Repr

/--
The main categorical diagram is `Int -> Ham <- Gap -> Phase -> IP`. The
second arrow deliberately points from the gapped subobject into Hamiltonian
moduli, unlike the prose construction step that first builds the moduli and
then cuts out the gapped locus.
-/
def mainCondensedCategoricalArrows : List CondensedAssemblyArrow := [
  { kind := .analyticPackaging
    source := .localInteractions
    target := .hamiltonianModuli
    status := .proposed
    obligations := [
      "controlled Hamiltonian morphisms",
      "higher descent",
      "variable microscopic presentations"
    ] },
  { kind := .gappedSubobjectInclusion
    source := .propositionalGappedLocus
    target := .hamiltonianModuli
    status := .proposed
    obligations := [
      "pullback-stable propositional image",
      "descent of common thermodynamic witnesses"
    ] },
  { kind := .phaseLocalizationAndStabilization
    source := .propositionalGappedLocus
    target := .stabilizedPhases
    status := .proposed
    obligations := [
      "controlled path localization",
      "atomic stabilization",
      "compatibility with descent"
    ] },
  { kind := .invertibleSectorAndSpectrification
    source := .stabilizedPhases
    target := .condensedPhaseSpectrum
    status := .proposed
    obligations := [
      "coherent stacking",
      "represented physical inverses",
      "internal connective spectrification"
    ] }
]

/-- The quantitative witness object maps to both qualitative targets. -/
def quantitativeGapCategoricalArrows : List CondensedAssemblyArrow := [
  { kind := .witnessProjection
    source := .quantitativeGapWitnesses
    target := .hamiltonianModuli
    status := .proposed
    obligations := ["functorial restriction of quantitative witnesses"] },
  { kind := .propositionalImage
    source := .quantitativeGapWitnesses
    target := .propositionalGappedLocus
    status := .proposed
    obligations := ["pullback-stable image factorization"] }
]

/-- Stage five factors through actual stacking-invertible phases. -/
def internalSpectrumCategoricalArrows : List CondensedAssemblyArrow := [
  { kind := .stackingInvertibleSector
    source := .stabilizedPhases
    target := .invertiblePhaseObject
    status := .proposed
    obligations := [
      "stacking descends through localization",
      "inverses have microscopic phase representatives"
    ] },
  { kind := .connectiveSpectrification
    source := .invertiblePhaseObject
    target := .condensedPhaseSpectrum
    status := .proposed
    obligations := ["internal grouplike recognition"] }
]

/-- Quantitative gap data reuse the dependent witness object from Paper 3. -/
abbrev QuantitativeGapFibration
    (Hamiltonian : Type)
    (GapWitness : Hamiltonian -> Type) :=
  WitnessedFamily Hamiltonian GapWitness

/-- The gapped locus remembers only that a quantitative witness exists. -/
abbrev PropositionalGappedImage
    {Hamiltonian : Type}
    (GapWitness : Hamiltonian -> Type)
    (hamiltonian : Hamiltonian) : Prop :=
  QualitativelyGapped GapWitness hamiltonian

/-- Forgetting witness data lands in the propositional image. -/
theorem quantitativeGapFibration_toPropositionalImage
    {Hamiltonian : Type}
    {GapWitness : Hamiltonian -> Type}
    (witnessed : QuantitativeGapFibration Hamiltonian GapWitness) :
    PropositionalGappedImage GapWitness witnessed.family :=
  witnessed.qualitativelyGapped

/-- Localization of controlled gapped paths is a conditional provider. -/
structure PhaseLocalizationInterface
    (GappedFamily Path Phase : Type)
    (IsControlledGappedPath : GappedFamily -> GappedFamily -> Path -> Prop)
    (Represents : GappedFamily -> Phase -> Prop) where
  localize : GappedFamily -> Phase
  represents : forall family, Represents family (localize family)
  pathInvariant : forall {left right} path,
    IsControlledGappedPath left right path -> localize left = localize right

/-- Atomic stabilization needs declared ancillas and restriction compatibility. -/
structure AtomicStabilizationInterface
    (Phase Atomic StabilizedPhase : Type)
    (IsDeclaredAtomic : Atomic -> Prop)
    (RepresentsStabilization : Phase -> Atomic -> StabilizedPhase -> Prop)
    (RestrictionCompatible : StabilizedPhase -> Prop) where
  stabilize : forall (_phase : Phase) atomic,
    IsDeclaredAtomic atomic -> StabilizedPhase
  represents : forall phase atomic (declared : IsDeclaredAtomic atomic),
    RepresentsStabilization phase atomic (stabilize phase atomic declared)
  restrictionCompatible : forall phase atomic (declared : IsDeclaredAtomic atomic),
    RestrictionCompatible (stabilize phase atomic declared)

/-- Coherent stacking descent is supplied only after its analytic laws hold. -/
structure StackingDescentInterface
    (Phase : Type)
    (IsGapped : Phase -> Prop)
    (Equivalent : Phase -> Phase -> Prop)
    (RestrictionCompatible : Phase -> Prop)
    (CoherentlySymmetricMonoidal : Stacking Phase -> Prop) where
  stacking : Stacking Phase
  preservesGap : forall left right,
    IsGapped left -> IsGapped right -> IsGapped (stacking.stack left right)
  preservesEquivalence : forall {left left' right right'},
    Equivalent left left' ->
    Equivalent right right' ->
    Equivalent (stacking.stack left right) (stacking.stack left' right')
  descendsUnderRestriction : forall left right,
    RestrictionCompatible left ->
    RestrictionCompatible right ->
    RestrictionCompatible (stacking.stack left right)
  coherent : CoherentlySymmetricMonoidal stacking

/--
The invertible sector contains represented inverses, not merely formal
Grothendieck inverses.
-/
structure InvertibleSectorInterface
    (Phase InvertiblePhase : Type)
    (Equivalent : Phase -> Phase -> Prop)
    (SheafwiseInvertible : InvertiblePhase -> Prop) where
  stacking : Stacking Phase
  embed : InvertiblePhase -> Phase
  inverse : InvertiblePhase -> InvertiblePhase
  leftInverse : forall phase,
    Equivalent
      (stacking.stack (embed (inverse phase)) (embed phase))
      stacking.atomic
  rightInverse : forall phase,
    Equivalent
      (stacking.stack (embed phase) (embed (inverse phase)))
      stacking.atomic
  sheafwiseInvertible : forall phase, SheafwiseInvertible phase

/-- Internal connective spectrification is a provider, not a global assumption. -/
structure InternalConnectiveSpectrificationInterface
    (PicardObject Spectrum : Type)
    (IsGrouplikeEInfinity : PicardObject -> Prop)
    (IsConnectiveSpectrum : Spectrum -> Prop)
    (ZerothSpaceMatches : Spectrum -> PicardObject -> Prop) where
  spectrify : forall picard,
    IsGrouplikeEInfinity picard -> Spectrum
  connective : forall picard (grouplike : IsGrouplikeEInfinity picard),
    IsConnectiveSpectrum (spectrify picard grouplike)
  zerothSpace : forall picard (grouplike : IsGrouplikeEInfinity picard),
    ZerothSpaceMatches (spectrify picard grouplike) picard

/-- The eight hypotheses of the synthesis paper's conditional assembly theorem. -/
inductive ConditionalAssemblyAssumption where
  | interactionHyperdescent
  | hamiltonianHigherDescent
  | quantitativeGapWitnessDescent
  | pullbackStablePropositionalImage
  | controlledPathLocalization
  | atomicStabilization
  | coherentStacking
  | internalPicardSpectrification
deriving DecidableEq, Repr

def conditionalAssemblyAssumptions : List ConditionalAssemblyAssumption := [
  .interactionHyperdescent,
  .hamiltonianHigherDescent,
  .quantitativeGapWitnessDescent,
  .pullbackStablePropositionalImage,
  .controlledPathLocalization,
  .atomicStabilization,
  .coherentStacking,
  .internalPicardSpectrification
]

/-- A completed conditional assembly returns a connective spectrum witness. -/
structure ConditionalCondensedSpectrumResult
    (Spectrum : Type)
    (IsConnectiveSpectrum : Spectrum -> Prop) where
  spectrum : Spectrum
  connective : IsConnectiveSpectrum spectrum

/-- No result can be obtained until a provider discharges all eight assumptions. -/
structure ConditionalCondensedSpectrumAssemblyInterface
    (Spectrum : Type)
    (IsConnectiveSpectrum : Spectrum -> Prop)
    (Discharges : ConditionalAssemblyAssumption -> Prop) where
  derive :
    (forall assumption, Discharges assumption) ->
    ConditionalCondensedSpectrumResult Spectrum IsConnectiveSpectrum

/-- Analytic transport is the extra input that turns a loop into a pump. -/
structure AdiabaticPumpTransportInterface
    (Loop Pump : Type)
    (UniformlyGapped : Loop -> Prop)
    (HasQuasiAdiabaticTransport : Loop -> Prop)
    (RepresentsPhysicalPump : Loop -> Pump -> Prop) where
  transport : forall loop,
    UniformlyGapped loop -> HasQuasiAdiabaticTransport loop -> Pump
  represents : forall loop
    (gapped : UniformlyGapped loop)
    (provider : HasQuasiAdiabaticTransport loop),
    RepresentsPhysicalPump loop (transport loop gapped provider)

/-- A based `S^k` family can only target spatial codimension `k + 1`. -/
def defectCodimensionOfBasedFamily (sphereDimension : Nat) : Nat :=
  sphereDimension + 1

/-- A higher family becomes a defect only through this separate provider. -/
structure FamilyToDefectInterface
    (HigherFamily Defect : Nat -> Type)
    (IsControlled : forall k, HigherFamily k -> Prop)
    (IsStableDefectOf : forall k,
      HigherFamily k -> Defect (defectCodimensionOfBasedFamily k) -> Prop) where
  toDefect : forall k (family : HigherFamily k),
    IsControlled k family -> Defect (defectCodimensionOfBasedFamily k)
  valid : forall k (family : HigherFamily k) (controlled : IsControlled k family),
    IsStableDefectOf k family (toDefect k family controlled)

/--
Homotopy meanings are supplied as interface data. In particular, the pump
and defect providers are optional and no implementation is installed here.
-/
structure PhaseSpectrumHomotopyInterpretationInterface
    (Pi : Nat -> Type)
    (InvertibleStabilizedPhase Loop Pump : Type)
    (HigherFamily Defect : Nat -> Type)
    (UniformlyGapped : Loop -> Prop)
    (HasQuasiAdiabaticTransport : Loop -> Prop)
    (RepresentsPhysicalPump : Loop -> Pump -> Prop)
    (IsControlledFamily : forall k, HigherFamily k -> Prop)
    (IsStableDefectOf : forall k,
      HigherFamily k -> Defect (defectCodimensionOfBasedFamily k) -> Prop) where
  piZero : Pi 0 -> InvertibleStabilizedPhase
  piOneLoop : Pi 1 -> Loop
  higherFamily : forall k, Pi (k + 2) -> HigherFamily (k + 2)
  pumpTransport : Option (AdiabaticPumpTransportInterface
    Loop Pump UniformlyGapped HasQuasiAdiabaticTransport RepresentsPhysicalPump)
  familyToDefect : Option (FamilyToDefectInterface
    HigherFamily Defect IsControlledFamily IsStableDefectOf)

/-!
The synthesis uses the relative-charge interfaces from Paper 5 directly.
These aliases make that reuse explicit without copying any prerequisites.
-/

abbrev SynthesisRelativePairHypotheses := RelativePairHypotheses
abbrev SynthesisRelativeChargeTheoremInterface := RelativeChargeTheoremInterface
abbrev SynthesisExcisionHypotheses := ExcisionHypotheses
abbrev SynthesisExcisionTheoremInterface := ExcisionTheoremInterface
abbrev SynthesisThomOrientationHypotheses := ThomOrientationHypotheses
abbrev SynthesisThomLocalizationTheoremInterface := ThomLocalizationTheoremInterface
abbrev SynthesisMicroscopicChargeComparisonInterface :=
  MicroscopicChargeComparisonInterface
abbrev SynthesisConditionalPhysicalChargeInterface :=
  ConditionalPhysicalChargeInterface

def conditionalAssemblyProvenance : Provenance where
  claim := "The five stages conditionally assemble an invertible condensed phase spectrum"
  status := .proposed
  assumptions := [
    "all eight conditional assembly obligations are discharged",
    "the Picard object has represented physical inverses",
    "internal connective spectrification applies"
  ]

def spatialOmegaStructureProvenance : Provenance where
  claim := "Spatial suspension gives the condensed construction an Omega-spectrum structure"
  status := .openProblem
  assumptions := ["a lattice-direction delooping theorem is not supplied"]

def physicalHigherDefectInterpretationProvenance : Provenance where
  claim := "Every higher homotopy family canonically determines a physical defect"
  status := .openProblem
  assumptions := [
    "a controlled family-to-defect provider is required",
    "a based S^k family targets spatial codimension k + 1"
  ]

end TopologicalPhases
