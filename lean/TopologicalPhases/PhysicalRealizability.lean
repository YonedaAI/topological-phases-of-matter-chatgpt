import TopologicalPhases.MicroscopicEFT

namespace TopologicalPhases

/-!
Paper 5 treats physical realizability as a witness registry, not a
surjectivity theorem. It also separates established relative-cohomology
bookkeeping from the open microscopic comparison needed for physical charge.
-/

/-- Realization status is finer than the general research claim status. -/
inductive RealizationStatus where
  | realized
  | candidate
  | openProblem
  | obstructed
deriving DecidableEq, Repr

/-- The phase objects in Paper 5 are not identified by notation alone. -/
inductive PhaseObjectKind where
  | microscopicStabilized
  | kubotaSpectrum
  | freedHopkins
  | condensedSpectrum
deriving DecidableEq, Repr

/-- A comparison can be declared open without carrying a fabricated map. -/
structure PhaseObjectComparison
    (Source Target : Type) where
  sourceKind : PhaseObjectKind
  targetKind : PhaseObjectKind
  status : ClaimStatus
  suppliedMap : Option (Source -> Target)
  requiredProofs : List String

def PhaseObjectComparison.HasSuppliedMap
    {Source Target : Type}
    (comparison : PhaseObjectComparison Source Target) : Prop :=
  Exists fun map => comparison.suppliedMap = some map

/--
Every matrix column is explicit. Optional fields allow candidate, open, and
obstructed rows to record exactly which microscopic evidence is absent.
-/
structure RealizabilityRow
    (AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type) where
  proposedClass : AbstractClass
  spatialDimension : Nat
  spacetimeDimension : Nat
  kinematics : Option Kinematics
  boundaryConvention : Option Boundary
  interaction : Option Interaction
  symmetry : Option Symmetry
  uniformGapEvidence : Option GapEvidence
  microscopicInvariant : Option Invariant
  abstractTarget : Target
  abstractComparison : Option Comparison
  comparisonStatus : ClaimStatus
  realizationStatus : RealizationStatus
  obstructionEvidence : Option ObstructionEvidence

namespace RealizabilityRow

/-- The paper uses spacetime dimension `n = d + 1`. -/
def dimensionValid
    {AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type}
    (row : RealizabilityRow
      AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence) : Bool :=
  row.spacetimeDimension == row.spatialDimension + 1

/-- A candidate model must at least specify its microscopic construction. -/
def explicitModelPresent
    {AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type}
    (row : RealizabilityRow
      AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence) : Bool :=
  row.kinematics.isSome &&
  row.boundaryConvention.isSome &&
  row.interaction.isSome &&
  row.symmetry.isSome

/-- A realized row additionally supplies a uniform gap and microscopic invariant. -/
def microscopicWitnessComplete
    {AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type}
    (row : RealizabilityRow
      AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence) : Bool :=
  row.explicitModelPresent &&
  row.uniformGapEvidence.isSome &&
  row.microscopicInvariant.isSome

def abstractComparisonSupported
    {AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type}
    (ComparisonSupported : Comparison -> ClaimStatus -> Bool)
    (row : RealizabilityRow
      AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence) : Bool :=
  match row.abstractComparison with
  | some comparison => ComparisonSupported comparison row.comparisonStatus
  | none => false

/--
The matrix contract checks dimensions and status-specific evidence. The
`ComparisonSupported` callback prevents a row from claiming more than its
supplied low-energy or abstract comparison justifies.
-/
def contractHolds
    {AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence : Type}
    (ComparisonSupported : Comparison -> ClaimStatus -> Bool)
    (row : RealizabilityRow
      AbstractClass Kinematics Boundary Interaction Symmetry GapEvidence
      Invariant Target Comparison ObstructionEvidence) : Bool :=
  row.dimensionValid &&
  match row.realizationStatus with
  | .realized =>
      row.microscopicWitnessComplete &&
      row.abstractComparisonSupported ComparisonSupported
  | .candidate =>
      row.explicitModelPresent &&
      !(row.microscopicWitnessComplete &&
        row.abstractComparisonSupported ComparisonSupported)
  | .openProblem => true
  | .obstructed => row.obstructionEvidence.isSome

end RealizabilityRow

/-- The connecting morphism raises generalized cohomology degree by one. -/
def relativeChargeDegree (degree : Int) : Int :=
  degree + 1

/-- An oriented codimension `c` Thom step changes `q + 1` to `q + 1 - c`. -/
def thomLocalizedDegree (degree : Int) (codimension : Nat) : Int :=
  relativeChargeDegree degree - Int.ofNat codimension

theorem relativeChargeDegree_eq (degree : Int) :
    relativeChargeDegree degree = degree + 1 :=
  rfl

theorem thomLocalizedDegree_eq (degree : Int) (codimension : Nat) :
    thomLocalizedDegree degree codimension =
      degree + 1 - Int.ofNat codimension :=
  rfl

/-- The pair and cofibrancy data required before forming a relative class. -/
structure RelativePairHypotheses
    (Base GappedLocus GaplessLocus : Type)
    (GaplessClosed : GaplessLocus -> Prop)
    (IsComplement : Base -> GappedLocus -> GaplessLocus -> Prop)
    (PairAxiom : Base -> GappedLocus -> Prop)
    (CofibrantModel : Base -> GappedLocus -> Prop)
    (base : Base)
    (gappedLocus : GappedLocus)
    (gaplessLocus : GaplessLocus) where
  gaplessClosed : GaplessClosed gaplessLocus
  isComplement : IsComplement base gappedLocus gaplessLocus
  pairAxiom : PairAxiom base gappedLocus
  cofibrantModel : CofibrantModel base gappedLocus

/-- A relative connecting-map result carries exactness for global extensions. -/
structure RelativeChargeResult
    (Base GappedLocus : Type)
    (WholeClass : Base -> Int -> Type)
    (GappedClass : GappedLocus -> Int -> Type)
    (RelativeClass : Base -> GappedLocus -> Int -> Type)
    (Restricts : {base : Base} -> {gappedLocus : GappedLocus} ->
      {degree : Int} ->
      WholeClass base degree -> GappedClass gappedLocus degree -> Prop)
    (IsZero : {base : Base} -> {gappedLocus : GappedLocus} ->
      {degree : Int} -> RelativeClass base gappedLocus degree -> Prop)
    (base : Base)
    (gappedLocus : GappedLocus) where
  boundary : {degree : Int} ->
    GappedClass gappedLocus degree ->
    RelativeClass base gappedLocus (relativeChargeDegree degree)
  extensionVanishes : forall {degree : Int}
    (whole : WholeClass base degree)
    (gapped : GappedClass gappedLocus degree),
    Restricts whole gapped -> IsZero (boundary gapped)

/--
The connecting morphism is available only after the pair and cofibrancy
hypotheses are supplied. No provider is installed by this module.
-/
structure RelativeChargeTheoremInterface
    (Base GappedLocus GaplessLocus : Type)
    (WholeClass : Base -> Int -> Type)
    (GappedClass : GappedLocus -> Int -> Type)
    (RelativeClass : Base -> GappedLocus -> Int -> Type)
    (GaplessClosed : GaplessLocus -> Prop)
    (IsComplement : Base -> GappedLocus -> GaplessLocus -> Prop)
    (PairAxiom : Base -> GappedLocus -> Prop)
    (CofibrantModel : Base -> GappedLocus -> Prop)
    (Restricts : {base : Base} -> {gappedLocus : GappedLocus} ->
      {degree : Int} ->
      WholeClass base degree -> GappedClass gappedLocus degree -> Prop)
    (IsZero : {base : Base} -> {gappedLocus : GappedLocus} ->
      {degree : Int} -> RelativeClass base gappedLocus degree -> Prop) where
  derive : forall
    (base : Base)
    (gappedLocus : GappedLocus)
    (gaplessLocus : GaplessLocus),
    RelativePairHypotheses
      Base GappedLocus GaplessLocus
      GaplessClosed IsComplement PairAxiom CofibrantModel
      base gappedLocus gaplessLocus ->
    RelativeChargeResult
      Base GappedLocus WholeClass GappedClass RelativeClass
      Restricts IsZero base gappedLocus

/-- Explicit inverse data for an isomorphism used by excision or Thom theory. -/
structure EquivalenceData (Left Right : Type) where
  forward : Left -> Right
  backward : Right -> Left
  leftInverse : forall left, backward (forward left) = left
  rightInverse : forall right, forward (backward right) = right

/-- Neighborhood and pair hypotheses required before invoking excision. -/
structure ExcisionHypotheses
    (Base GappedLocus GaplessLocus Neighborhood : Type)
    (IsNeighborhood : Neighborhood -> GaplessLocus -> Prop)
    (ClosureCondition : Base -> GappedLocus -> Neighborhood -> Prop)
    (ExcisionApplies : Base -> GappedLocus -> Neighborhood -> Prop)
    (base : Base)
    (gappedLocus : GappedLocus)
    (gaplessLocus : GaplessLocus) where
  neighborhood : Neighborhood
  isNeighborhood : IsNeighborhood neighborhood gaplessLocus
  closureCondition : ClosureCondition base gappedLocus neighborhood
  excisionApplies : ExcisionApplies base gappedLocus neighborhood

/-- Excision is an explicit provider and is not inferred from a neighborhood name. -/
structure ExcisionTheoremInterface
    (Base GappedLocus GaplessLocus Neighborhood : Type)
    (GlobalRelative : Base -> GappedLocus -> Int -> Type)
    (LocalRelative : Neighborhood -> GaplessLocus -> Int -> Type)
    (GaplessClosed : GaplessLocus -> Prop)
    (IsComplement : Base -> GappedLocus -> GaplessLocus -> Prop)
    (PairAxiom : Base -> GappedLocus -> Prop)
    (CofibrantModel : Base -> GappedLocus -> Prop)
    (IsNeighborhood : Neighborhood -> GaplessLocus -> Prop)
    (ClosureCondition : Base -> GappedLocus -> Neighborhood -> Prop)
    (ExcisionApplies : Base -> GappedLocus -> Neighborhood -> Prop) where
  localize : forall
    (base : Base)
    (gappedLocus : GappedLocus)
    (gaplessLocus : GaplessLocus),
    RelativePairHypotheses
      Base GappedLocus GaplessLocus
      GaplessClosed IsComplement PairAxiom CofibrantModel
      base gappedLocus gaplessLocus ->
    (excision : ExcisionHypotheses
      Base GappedLocus GaplessLocus Neighborhood
      IsNeighborhood ClosureCondition ExcisionApplies
      base gappedLocus gaplessLocus) ->
    forall degree,
      EquivalenceData
        (GlobalRelative base gappedLocus degree)
        (LocalRelative excision.neighborhood gaplessLocus degree)

/-- Smooth embedding, tubular, rank, and orientation data for the Thom step. -/
structure ThomOrientationHypotheses
    (Base CriticalLocus NormalBundle ThomClass : Type)
    (codimension : Nat)
    (SmoothClosedEmbedding : CriticalLocus -> Base -> Prop)
    (IsNormalBundle : NormalBundle -> CriticalLocus -> Base -> Prop)
    (HasTubularNeighborhood : NormalBundle -> Prop)
    (HasRank : NormalBundle -> Nat -> Prop)
    (IsEOrientation : ThomClass -> NormalBundle -> Nat -> Prop) where
  base : Base
  criticalLocus : CriticalLocus
  normalBundle : NormalBundle
  thomClass : ThomClass
  smoothClosedEmbedding : SmoothClosedEmbedding criticalLocus base
  isNormalBundle : IsNormalBundle normalBundle criticalLocus base
  tubularNeighborhood : HasTubularNeighborhood normalBundle
  normalRank : HasRank normalBundle codimension
  orientation : IsEOrientation thomClass normalBundle codimension

/--
The untwisted Thom isomorphism can be invoked only with an explicit
orientation witness. Without it, a separate twisted theory is required.
-/
structure ThomLocalizationTheoremInterface
    (Base CriticalLocus NormalBundle ThomClass : Type)
    (LocalRelative CriticalClass : Int -> Type)
    (SmoothClosedEmbedding : CriticalLocus -> Base -> Prop)
    (IsNormalBundle : NormalBundle -> CriticalLocus -> Base -> Prop)
    (HasTubularNeighborhood : NormalBundle -> Prop)
    (HasRank : NormalBundle -> Nat -> Prop)
    (IsEOrientation : ThomClass -> NormalBundle -> Nat -> Prop) where
  localize : forall codimension,
    ThomOrientationHypotheses
      Base CriticalLocus NormalBundle ThomClass codimension
      SmoothClosedEmbedding IsNormalBundle HasTubularNeighborhood
      HasRank IsEOrientation ->
    forall degree,
      EquivalenceData
        (LocalRelative degree)
        (CriticalClass (thomLocalizedDegree degree codimension))

/--
Physical charge needs a natural microscopic comparison. This provider is
separate from the algebraic-topology connecting morphism.
-/
structure MicroscopicChargeComparisonInterface
    (Family : Type)
    (CohomologyClass : Int -> Type)
    (degree : Int)
    (GappedHomotopic : Family -> Family -> Prop)
    (RestrictionCompatible : Family -> CohomologyClass degree -> Prop) where
  compare : Family -> CohomologyClass degree
  homotopyInvariant : forall {left right},
    GappedHomotopic left right -> compare left = compare right
  naturalUnderRestriction : forall family,
    RestrictionCompatible family (compare family)

/-- An established algebraic relative class is not automatically a physical charge. -/
structure ConditionalPhysicalChargeInterface
    (Family : Type)
    (CohomologyClass RelativeClass : Int -> Type)
    (degree : Int)
    (GappedHomotopic : Family -> Family -> Prop)
    (RestrictionCompatible : Family -> CohomologyClass degree -> Prop) where
  microscopicComparison : MicroscopicChargeComparisonInterface
    Family CohomologyClass degree GappedHomotopic RestrictionCompatible
  boundary : CohomologyClass degree -> RelativeClass (relativeChargeDegree degree)
  physicalCharge : Family -> RelativeClass (relativeChargeDegree degree)
  isBoundary : forall family,
    physicalCharge family = boundary (microscopicComparison.compare family)

/-- Open comparison from Kubota's microscopic spectrum to Freed-Hopkins classes. -/
def kubotaToFreedHopkinsComparison : PhaseObjectComparison Nat Nat where
  sourceKind := .kubotaSpectrum
  targetKind := .freedHopkins
  status := .openProblem
  suppliedMap := none
  requiredProofs := [
    "define a common domain",
    "prove continuity and homotopy invariance",
    "preserve symmetry and stabilization",
    "justify the low-energy field-theory comparison"
  ]

/-- Open comparison from the smooth microscopic spectrum to a proposed condensed one. -/
def kubotaToCondensedComparison : PhaseObjectComparison Nat Nat where
  sourceKind := .kubotaSpectrum
  targetKind := .condensedSpectrum
  status := .openProblem
  suppliedMap := none
  requiredProofs := [
    "construct the condensed phase spectrum",
    "compare smooth and condensed parameter families",
    "prove compatibility with stabilization"
  ]

def freedHopkinsClassificationProvenance : Provenance where
  claim := "Freed-Hopkins classifies the discrete topological field-theory sector under its stated hypotheses"
  status := .established
  sources := [{
    citation := "Freed and Hopkins, Reflection positivity and invertible topological phases"
    locator := some "Geometry and Topology 25 (2021), 1165-1330"
  }]
  assumptions := [
    "fixed spacetime symmetry type",
    "reflection positivity and invertibility",
    "field-theory deformation category"
  ]

def generalMicroscopicFreedHopkinsComparisonProvenance : Provenance where
  claim := "A general microscopic phase maps naturally and completely to the Freed-Hopkins spectrum"
  status := .openProblem
  assumptions := ["no comparison with all required analytic and functorial properties is supplied"]

def equalGroupsImplyEquivalentSpectraProvenance : Provenance where
  claim := "Isomorphic finite classification groups by themselves identify the underlying phase spectra"
  status := .obstructed
  assumptions := [
    "group agreement does not define a comparison map",
    "the phase objects can use different domains and homotopies"
  ]

def everyRelativeClassIsPhysicalProvenance : Provenance where
  claim := "Every relative generalized cohomology class is a physical transition charge"
  status := .obstructed
  assumptions := [
    "requires a microscopic invariant",
    "requires a natural comparison map",
    "local Thom interpretation requires excision and orientation"
  ]

end TopologicalPhases
