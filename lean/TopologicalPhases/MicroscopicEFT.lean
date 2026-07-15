import TopologicalPhases.Observables
import TopologicalPhases.SpectralGaps

namespace TopologicalPhases

/-!
Paper 4 separates controlled operator K-theory from general low-energy and
realization claims. The declarations below preserve that separation. A map
exists only when a concrete provider supplies it.
-/

/-- The three arrows have different domains, codomains, and proof duties. -/
inductive ComparisonArrowKind where
  | microscopicToLowEnergy
  | invariantExtraction
  | microscopicRealization
deriving DecidableEq, Repr

/--
A declaration can record an open arrow without pretending that a map exists.
The absence of `suppliedMap` is data, not a failed proof.
-/
structure ComparisonArrowDeclaration
    (Source Target : Type) where
  kind : ComparisonArrowKind
  sourceName : String
  targetName : String
  status : ClaimStatus
  suppliedMap : Option (Source -> Target)
  obligations : List String

def ComparisonArrowDeclaration.HasSuppliedMap
    {Source Target : Type}
    (declaration : ComparisonArrowDeclaration Source Target) : Prop :=
  Exists fun map => declaration.suppliedMap = some map

/-- A controlled microscopic-to-low-energy map must prove its stated control relation. -/
structure MicroscopicToLowEnergyComparisonInterface
    (Microscopic LowEnergy : Type)
    (Admissible : Microscopic -> Prop)
    (Controlled : Microscopic -> LowEnergy -> Prop) where
  compare : (system : Microscopic) -> Admissible system -> LowEnergy
  controlled : forall system admissible,
    Controlled system (compare system admissible)

/-- Invariant extraction fixes its target conventions and respects the chosen equivalence. -/
structure InvariantExtractionInterface
    (LowEnergy StableClass : Type)
    (Equivalent : LowEnergy -> LowEnergy -> Prop)
    (SameClass : StableClass -> StableClass -> Prop) where
  extract : LowEnergy -> StableClass
  invariant : forall {left right},
    Equivalent left right -> SameClass (extract left) (extract right)

/--
Microscopic realization points from a stable class to a lattice witness.
It is not an inverse field on either forward comparison interface.
-/
structure MicroscopicRealizationInterface
    (StableClass MicroscopicWitness : Type)
    (Realizes : MicroscopicWitness -> StableClass -> Prop) where
  realize : StableClass -> MicroscopicWitness
  verified : forall stableClass, Realizes (realize stableClass) stableClass

/-- Inputs for the controlled bounded free-fermion flattening theorem. -/
structure ControlledFlatteningHypotheses
    (Parameter Hamiltonian Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (fermiGap : Parameter -> Gap)
    (Bounded SelfAdjoint SymmetryCompatible : Hamiltonian -> Prop)
    (HasFermiGapAtLeast : Hamiltonian -> Gap -> Prop) where
  family : Parameter -> Hamiltonian
  reference : Hamiltonian
  familyBounded : forall parameter, Bounded (family parameter)
  referenceBounded : Bounded reference
  familySelfAdjoint : forall parameter, SelfAdjoint (family parameter)
  referenceSelfAdjoint : SelfAdjoint reference
  familySymmetry : forall parameter, SymmetryCompatible (family parameter)
  referenceSymmetry : SymmetryCompatible reference
  commonFermiGap : CommonGapWitness Parameter Gap fermiGap
  familyGapValueVerified : forall parameter,
    HasFermiGapAtLeast (family parameter) (fermiGap parameter)
  familyGapVerified : forall parameter,
    HasFermiGapAtLeast (family parameter) commonFermiGap.lowerBound
  referenceGap : Gap
  referenceGapPositive : 0 < referenceGap
  referenceGapVerified : HasFermiGapAtLeast reference referenceGap

/-- The controlled output retains a projection family and relative stable class. -/
structure ControlledFlatteningResult
    (Parameter Hamiltonian Projection StableClass : Type)
    (Flattening : Hamiltonian -> Projection -> Prop)
    (RelativeClass : Projection -> Projection -> StableClass -> Prop)
    (NaturalProjection : (Parameter -> Projection) -> Prop)
    (GappedHomotopyInvariant StackingAdditive : StableClass -> Prop)
    (family : Parameter -> Hamiltonian)
    (reference : Hamiltonian) where
  projections : Parameter -> Projection
  referenceProjection : Projection
  flattenedFamily : forall parameter,
    Flattening (family parameter) (projections parameter)
  flattenedReference : Flattening reference referenceProjection
  stableClass : Parameter -> StableClass
  relativeClass : forall parameter, RelativeClass
    (projections parameter) referenceProjection (stableClass parameter)
  natural : NaturalProjection projections
  homotopyInvariant : forall parameter, GappedHomotopyInvariant (stableClass parameter)
  stackingAdditive : forall parameter, StackingAdditive (stableClass parameter)

/--
The analytic functional-calculus theorem is represented by a provider.
No provider is installed by this module.
-/
structure ControlledFlatteningTheoremInterface
    (Parameter Hamiltonian Gap Projection StableClass : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (fermiGap : Parameter -> Gap)
    (Bounded SelfAdjoint SymmetryCompatible : Hamiltonian -> Prop)
    (HasFermiGapAtLeast : Hamiltonian -> Gap -> Prop)
    (Flattening : Hamiltonian -> Projection -> Prop)
    (RelativeClass : Projection -> Projection -> StableClass -> Prop)
    (NaturalProjection : (Parameter -> Projection) -> Prop)
    (GappedHomotopyInvariant StackingAdditive : StableClass -> Prop) where
  derive :
    (hypotheses : ControlledFlatteningHypotheses
      Parameter Hamiltonian Gap fermiGap Bounded SelfAdjoint SymmetryCompatible
      HasFermiGapAtLeast) ->
    ControlledFlatteningResult
      Parameter Hamiltonian Projection StableClass
      Flattening RelativeClass NaturalProjection
      GappedHomotopyInvariant StackingAdditive
      hypotheses.family hypotheses.reference

/-- Stable data discussed by the information-loss contract. -/
inductive FlatteningDatum where
  | occupiedEmptyGrading
  | stabilizedGappedComponent
  | encodedSymmetry
  | stackingClass
  | gapMagnitude
  | dispersion
  | fermiVelocity
  | correlationLength
  | localityConstants
  | couplingValues
  | finiteBandUnstableData
  | boundaryConvention
  | interactionVertices
deriving DecidableEq, Repr

/-- The fields guaranteed to survive controlled spectral flattening. -/
def flatteningRetains : FlatteningDatum -> Bool
  | .occupiedEmptyGrading => true
  | .stabilizedGappedComponent => true
  | .encodedSymmetry => true
  | .stackingClass => true
  | _ => false

/-- The microscopic data explicitly outside the reconstruction contract. -/
def flatteningForgets : FlatteningDatum -> Bool
  | .gapMagnitude => true
  | .dispersion => true
  | .fermiVelocity => true
  | .correlationLength => true
  | .localityConstants => true
  | .couplingValues => true
  | .finiteBandUnstableData => true
  | .boundaryConvention => true
  | .interactionVertices => true
  | _ => false

/-- An open microscopic-to-EFT bridge has no supplied general map. -/
def generalMicroscopicToEFTDeclaration : ComparisonArrowDeclaration Nat Nat where
  kind := .microscopicToLowEnergy
  sourceName := "uniformly gapped interacting microscopic systems"
  targetName := "invertible effective field theories"
  status := .openProblem
  suppliedMap := none
  obligations := [
    "state a common domain",
    "construct the scaling or low-energy map",
    "prove homotopy and symmetry compatibility",
    "control the thermodynamic limit"
  ]

/-- A general realization arrow is open and is not an inverse by definition. -/
def generalMicroscopicRealizationDeclaration : ComparisonArrowDeclaration Nat Nat where
  kind := .microscopicRealization
  sourceName := "abstract stable or bordism classes"
  targetName := "local uniformly gapped lattice witnesses"
  status := .openProblem
  suppliedMap := none
  obligations := [
    "construct local degrees of freedom and symmetry",
    "supply a uniformly local interaction",
    "prove a system-size-independent gap",
    "compute the declared comparison class"
  ]

def controlledFlatteningProvenance : Provenance where
  claim := "Controlled bounded free-fermion spectral flattening produces a stable operator K-class"
  status := .established
  sources := [{
    citation := "Continuous functional calculus for gapped self-adjoint C-star algebra elements"
    locator := some "Paper 4, controlled functional-calculus sector"
  }]
  assumptions := [
    "fixed real, complex, graded, or twisted C-star algebra",
    "bounded self-adjoint family",
    "common Fermi gap",
    "fixed symmetry and reference conventions"
  ]

def interactingMicroscopicEFTProvenance : Provenance where
  claim := "General interacting microscopic systems are equivalent to an EFT stack"
  status := .openProblem
  assumptions := [
    "a common comparison domain has not been constructed",
    "no general scaling-limit and completeness theorem is supplied"
  ]

def generalRealizationProvenance : Provenance where
  claim := "Every abstract invertible bordism class has a local uniformly gapped lattice representative"
  status := .openProblem
  assumptions := [
    "requires an explicit interaction, symmetry, uniform gap, and comparison computation"
  ]

def unchangedInteractingBDIProvenance : Provenance where
  claim := "Free integer K-theory classifies all interacting BDI phases without modification"
  status := .obstructed
  sources := [{
    citation := "Fidkowski and Kitaev interaction reduction"
    locator := some "eightfold reduction in one-dimensional BDI"
  }]
  assumptions := ["interactions allowed in the symmetry-preserving phase relation"]

end TopologicalPhases
