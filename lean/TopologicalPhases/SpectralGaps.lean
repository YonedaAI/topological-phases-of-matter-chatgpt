import TopologicalPhases.Core
import TopologicalPhases.Locality

namespace TopologicalPhases

/-!
This module records the logical shape of finite and thermodynamic gap claims.
Finite spectral certificates are concrete data. Infinite-volume transport and
stability remain theorem-provider interfaces whose analytic implementations
must be supplied separately.
-/

/--
A literal finite gap names the ground energy and the least strictly higher
energy in a finite spectrum. Degenerate copies of the ground energy do not
count as excited levels. A concrete instantiation must supply `separation` as
the genuine spectral distance for its energy model.
-/
structure LiteralFiniteGap
    (Energy Gap : Type)
    [LE Energy] [LT Energy]
    [OfNat Gap 0] [LT Gap]
    (separation : Energy -> Energy -> Gap) where
  spectrum : List Energy
  groundEnergy : Energy
  groundOccurs : groundEnergy ∈ spectrum
  firstExcitedEnergy : Energy
  firstExcitedOccurs : firstExcitedEnergy ∈ spectrum
  groundStrictlyBelow : groundEnergy < firstExcitedEnergy
  groundIsMinimum : forall energy, energy ∈ spectrum -> groundEnergy <= energy
  firstExcitedIsLeast : forall energy,
    energy ∈ spectrum ->
    groundEnergy < energy ->
    firstExcitedEnergy <= energy
  gapPositive : 0 < separation groundEnergy firstExcitedEnergy

namespace LiteralFiniteGap

/-- The numerical gap attached to a certified literal finite spectrum. -/
def gapValue
    {Energy Gap : Type}
    [LE Energy] [LT Energy]
    [OfNat Gap 0] [LT Gap]
    {separation : Energy -> Energy -> Gap}
    (certificate : LiteralFiniteGap Energy Gap separation) : Gap :=
  separation certificate.groundEnergy certificate.firstExcitedEnergy

theorem gapValue_positive
    {Energy Gap : Type}
    [LE Energy] [LT Energy]
    [OfNat Gap 0] [LT Gap]
    {separation : Energy -> Energy -> Gap}
    (certificate : LiteralFiniteGap Energy Gap separation) :
    0 < certificate.gapValue :=
  certificate.gapPositive

end LiteralFiniteGap

/--
A selected-band certificate includes witnesses on both sides of the split.
In particular, `complementWitness` prevents an empty complementary spectrum
from being assigned a spurious gap. Identifying `separation` with the actual
distance between spectral sets remains an obligation of the instantiation.
-/
structure SelectedBandGap
    (Energy Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (separation : Energy -> Energy -> Gap) where
  spectrum : List Energy
  selected : Energy -> Prop
  selectedWitness : Energy
  selectedWitnessOccurs : selectedWitness ∈ spectrum
  selectedWitnessInBand : selected selectedWitness
  complementWitness : Energy
  complementWitnessOccurs : complementWitness ∈ spectrum
  complementWitnessOutsideBand : Not (selected complementWitness)
  lowerBound : Gap
  lowerBoundPositive : 0 < lowerBound
  separated : forall selectedEnergy,
    selectedEnergy ∈ spectrum ->
    selected selectedEnergy ->
    forall complementaryEnergy,
      complementaryEnergy ∈ spectrum ->
      Not (selected complementaryEnergy) ->
      lowerBound <= separation selectedEnergy complementaryEnergy

/--
The elementary order laws needed for weakening and finite-cover minima.
Concrete scalar types supply this record with proofs of their usual minimum.
-/
structure GapOrderLaws
    (Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap] where
  leTransitive : forall {first second third : Gap},
    first <= second -> second <= third -> first <= third
  minimum : Gap -> Gap -> Gap
  minimumPositive : forall {left right : Gap},
    0 < left -> 0 < right -> 0 < minimum left right
  minimumLELeft : forall left right, minimum left right <= left
  minimumLERight : forall left right, minimum left right <= right

/-- One positive number bounds the declared gap function at every index. -/
structure CommonGapWitness
    (Index Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (gap : Index -> Gap) where
  lowerBound : Gap
  lowerBoundPositive : 0 < lowerBound
  uniform : forall index, lowerBound <= gap index

namespace CommonGapWitness

/-- A quantitative witness remains valid after lowering its positive bound. -/
def weaken
    {Index Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Index -> Gap}
    (order : GapOrderLaws Gap)
    (witness : CommonGapWitness Index Gap gap)
    (newBound : Gap)
    (newBoundPositive : 0 < newBound)
    (newBoundBelow : newBound <= witness.lowerBound) :
    CommonGapWitness Index Gap gap where
  lowerBound := newBound
  lowerBoundPositive := newBoundPositive
  uniform := by
    intro index
    exact order.leTransitive newBoundBelow (witness.uniform index)

end CommonGapWitness

/-- Quantitative witnessed families form data over an underlying family. -/
structure WitnessedFamily
    (Family : Type)
    (Witness : Family -> Type) where
  family : Family
  witness : Witness family

/-- Forgetting quantitative data leaves only propositional witness existence. -/
def QualitativelyGapped
    {Family : Type}
    (Witness : Family -> Type)
    (family : Family) : Prop :=
  Nonempty (Witness family)

namespace WitnessedFamily

def forget
    {Family : Type}
    {Witness : Family -> Type}
    (witnessed : WitnessedFamily Family Witness) : Family :=
  witnessed.family

theorem qualitativelyGapped
    {Family : Type}
    {Witness : Family -> Type}
    (witnessed : WitnessedFamily Family Witness) :
    QualitativelyGapped Witness witnessed.family :=
  Nonempty.intro witnessed.witness

end WitnessedFamily

/-- A local quantitative witness is valid only on its declared region. -/
structure LocalGapWitness
    (Parameter Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (gap : Parameter -> Gap) where
  region : Parameter -> Prop
  lowerBound : Gap
  lowerBoundPositive : 0 < lowerBound
  validOn : forall parameter, region parameter -> lowerBound <= gap parameter

/-- The smaller of two values according to explicit quantitative order laws. -/
def smallerBound
    {Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (order : GapOrderLaws Gap)
    (left right : Gap) :
    Gap :=
  order.minimum left right

/--
A nonempty finite cover is represented by a binary tree of local witnesses.
Using one gap function in the type enforces compatibility of the predicate.
-/
inductive FiniteGapCover
    (Parameter Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (gap : Parameter -> Gap) where
  | leaf (piece : LocalGapWitness Parameter Gap gap)
  | branch
      (left : FiniteGapCover Parameter Gap gap)
      (right : FiniteGapCover Parameter Gap gap)

namespace FiniteGapCover

def region
    {Parameter Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Parameter -> Gap} :
    FiniteGapCover Parameter Gap gap -> Parameter -> Prop
  | .leaf piece, parameter => piece.region parameter
  | .branch left right, parameter =>
      left.region parameter \/ right.region parameter

def lowerBound
    {Parameter Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Parameter -> Gap}
    (order : GapOrderLaws Gap) :
    FiniteGapCover Parameter Gap gap -> Gap
  | .leaf piece => piece.lowerBound
  | .branch left right =>
      smallerBound order (lowerBound order left) (lowerBound order right)

theorem lowerBound_positive
    {Parameter Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Parameter -> Gap}
    (order : GapOrderLaws Gap)
    (cover : FiniteGapCover Parameter Gap gap) :
    0 < cover.lowerBound order := by
  induction cover with
  | leaf piece => exact piece.lowerBoundPositive
  | branch left right leftPositive rightPositive =>
      exact order.minimumPositive leftPositive rightPositive

theorem lowerBound_valid
    {Parameter Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Parameter -> Gap}
    (order : GapOrderLaws Gap)
    (cover : FiniteGapCover Parameter Gap gap)
    {parameter : Parameter} :
    cover.region parameter -> cover.lowerBound order <= gap parameter := by
  induction cover with
  | leaf piece =>
      intro inRegion
      exact piece.validOn parameter inRegion
  | branch left right leftValid rightValid =>
      intro inCover
      cases inCover with
      | inl inLeft =>
          exact order.leTransitive
            (order.minimumLELeft (left.lowerBound order) (right.lowerBound order))
            (leftValid inLeft)
      | inr inRight =>
          exact order.leTransitive
            (order.minimumLERight (left.lowerBound order) (right.lowerBound order))
            (rightValid inRight)

/-- A total finite cover yields the minimum of its supplied positive bounds. -/
def toCommonGapWitness
    {Parameter Gap : Type}
    [OfNat Gap 0] [LT Gap] [LE Gap]
    {gap : Parameter -> Gap}
    (order : GapOrderLaws Gap)
    (cover : FiniteGapCover Parameter Gap gap)
    (coversEveryParameter : forall parameter, cover.region parameter) :
    CommonGapWitness Parameter Gap gap where
  lowerBound := cover.lowerBound order
  lowerBoundPositive := cover.lowerBound_positive order
  uniform := by
    intro parameter
    exact cover.lowerBound_valid order (coversEveryParameter parameter)

end FiniteGapCover

/-- A quantitative bulk gap in one selected GNS representation. -/
structure GNSGapWitness
    (System Gap : Type)
    [OfNat Gap 0] [LT Gap]
    (HasBulkGapAtLeast : System -> Gap -> Prop)
    (system : System) where
  lowerBound : Gap
  lowerBoundPositive : 0 < lowerBound
  verified : HasBulkGapAtLeast system lowerBound

/--
A concrete analytic development may provide this interface after proving the
declared GNS hypotheses. There is no default provider and no universal claim
that every selected ground-state representation is gapped.
-/
structure GNSGapTheoremInterface
    (System Gap : Type)
    [OfNat Gap 0] [LT Gap]
    (AnalyticHypotheses : System -> Prop)
    (HasBulkGapAtLeast : System -> Gap -> Prop) where
  derive : forall system,
    AnalyticHypotheses system ->
    GNSGapWitness System Gap HasBulkGapAtLeast system

/--
Inputs required before an analytic spectral-flow theorem can be invoked.
The selected band and boundary convention are included abstractly in `Family`.
-/
structure SpectralFlowHypotheses
    (Parameter Volume Family Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (bandGap : Volume -> Parameter -> Gap)
    (UniformLocality DifferentiablePath ControlledGeometry : Family -> Prop) where
  family : Family
  uniformBandGap :
    CommonGapWitness (Volume × Parameter) Gap
      (fun index => bandGap index.1 index.2)
  uniformLocality : UniformLocality family
  differentiablePath : DifferentiablePath family
  controlledGeometry : ControlledGeometry family

/-- The transport conclusions produced by a spectral-flow theorem. -/
structure SpectralFlowResult
    (Family Flow : Type)
    (StronglyContinuous QuasiLocal GroundStateTransport : Family -> Flow -> Prop)
    (family : Family) where
  flow : Flow
  stronglyContinuous : StronglyContinuous family flow
  quasiLocal : QuasiLocal family flow
  transportsGroundStates : GroundStateTransport family flow

/--
An implementation must connect a cited analytic theorem to the exact hypotheses.
This interface has no global instance and creates no spectral gap by itself.
-/
structure SpectralFlowTheoremInterface
    (Parameter Volume Family Gap Flow : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (bandGap : Volume -> Parameter -> Gap)
    (UniformLocality DifferentiablePath ControlledGeometry : Family -> Prop)
    (StronglyContinuous QuasiLocal GroundStateTransport : Family -> Flow -> Prop) where
  derive :
    (hypotheses : SpectralFlowHypotheses
      Parameter Volume Family Gap bandGap
      UniformLocality DifferentiablePath ControlledGeometry) ->
    SpectralFlowResult Family Flow
      StronglyContinuous QuasiLocal GroundStateTransport hypotheses.family

/--
The full hypothesis package for a controlled frustration-free LTQO theorem.
Every analytic property is an explicit input rather than a derived placeholder.
-/
structure ControlledLTQOStabilityHypotheses
    (Reference Perturbation Gap : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (RegularGeometry FiniteRangePositive FrustrationFree : Reference -> Prop)
    (NondegenerateVacuum : Reference -> Prop)
    (HasBulkGapAtLeast : Reference -> Gap -> Prop)
    (QuantitativeLocalGap LTQO : Reference -> Prop)
    (AnchoredStretchedExponential : Perturbation -> Prop) where
  reference : Reference
  perturbation : Perturbation
  referenceGap : Gap
  referenceGapPositive : 0 < referenceGap
  targetGap : Gap
  targetGapPositive : 0 < targetGap
  targetBelowReference : targetGap < referenceGap
  regularGeometry : RegularGeometry reference
  finiteRangePositive : FiniteRangePositive reference
  frustrationFree : FrustrationFree reference
  nondegenerateVacuum : NondegenerateVacuum reference
  referenceBulkGap : HasBulkGapAtLeast reference referenceGap
  quantitativeLocalGap : QuantitativeLocalGap reference
  ltqo : LTQO reference
  anchoredDecay : AnchoredStretchedExponential perturbation

/-- The threshold and transported conclusions supplied by the stability theorem. -/
structure ControlledLTQOStabilityResult
    (Reference Perturbation Gap Coupling Threshold State : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (RegularGeometry FiniteRangePositive FrustrationFree : Reference -> Prop)
    (NondegenerateVacuum : Reference -> Prop)
    (HasBulkGapAtLeast : Reference -> Gap -> Prop)
    (QuantitativeLocalGap LTQO : Reference -> Prop)
    (AnchoredStretchedExponential : Perturbation -> Prop)
    (PositiveThreshold : Threshold -> Prop)
    (BelowThreshold : Coupling -> Threshold -> Prop)
    (TransportedUniqueGroundState : Reference -> Perturbation -> Coupling -> State -> Prop)
    (PerturbedBulkGapAtLeast : Reference -> Perturbation -> Coupling -> Gap -> Prop)
    (hypotheses : ControlledLTQOStabilityHypotheses
      Reference Perturbation Gap
      RegularGeometry FiniteRangePositive FrustrationFree
      NondegenerateVacuum HasBulkGapAtLeast QuantitativeLocalGap LTQO
      AnchoredStretchedExponential) where
  threshold : Threshold
  thresholdPositive : PositiveThreshold threshold
  transportedState : Coupling -> State
  stable : forall coupling,
    BelowThreshold coupling threshold ->
    TransportedUniqueGroundState
      hypotheses.reference hypotheses.perturbation coupling (transportedState coupling) /\
    PerturbedBulkGapAtLeast
      hypotheses.reference hypotheses.perturbation coupling hypotheses.targetGap

/--
An analytic stability implementation must discharge every LTQO and local-gap
hypothesis before it can produce a perturbation threshold.
-/
structure ControlledLTQOStabilityTheoremInterface
    (Reference Perturbation Gap Coupling Threshold State : Type)
    [OfNat Gap 0] [LT Gap] [LE Gap]
    (RegularGeometry FiniteRangePositive FrustrationFree : Reference -> Prop)
    (NondegenerateVacuum : Reference -> Prop)
    (HasBulkGapAtLeast : Reference -> Gap -> Prop)
    (QuantitativeLocalGap LTQO : Reference -> Prop)
    (AnchoredStretchedExponential : Perturbation -> Prop)
    (PositiveThreshold : Threshold -> Prop)
    (BelowThreshold : Coupling -> Threshold -> Prop)
    (TransportedUniqueGroundState : Reference -> Perturbation -> Coupling -> State -> Prop)
    (PerturbedBulkGapAtLeast : Reference -> Perturbation -> Coupling -> Gap -> Prop) where
  derive :
    (hypotheses : ControlledLTQOStabilityHypotheses
      Reference Perturbation Gap
      RegularGeometry FiniteRangePositive FrustrationFree
      NondegenerateVacuum HasBulkGapAtLeast QuantitativeLocalGap LTQO
      AnchoredStretchedExponential) ->
    ControlledLTQOStabilityResult
      Reference Perturbation Gap Coupling Threshold State
      RegularGeometry FiniteRangePositive FrustrationFree
      NondegenerateVacuum HasBulkGapAtLeast QuantitativeLocalGap LTQO
      AnchoredStretchedExponential PositiveThreshold BelowThreshold
      TransportedUniqueGroundState PerturbedBulkGapAtLeast hypotheses

def spectralFlowProvenance : Provenance where
  claim := "A uniform selected-band gap and locality hypotheses support thermodynamic spectral flow"
  status := .established
  sources := [{
    citation := "Bachmann, Michalakis, Nachtergaele, and Sims, Automorphic equivalence within gapped phases"
    locator := some "arXiv:1102.0842"
  }]
  assumptions := [
    "uniform selected-band gap",
    "uniform locality and differentiability",
    "controlled exhaustion geometry"
  ]

def controlledLTQOStabilityProvenance : Provenance where
  claim := "A frustration-free LTQO class with quantitative local gaps has a controlled bulk-gap stability theorem"
  status := .established
  sources := [{
    citation := "Nachtergaele, Sims, and Young, Stability of the bulk gap for frustration-free topologically ordered quantum lattice systems"
    locator := some "arXiv:2102.07209"
  }]
  assumptions := [
    "pre-existing positive bulk GNS gap",
    "regular geometry and finite-range positive frustration-free interaction",
    "nondegenerate selected GNS vacuum",
    "quantitative local gaps and LTQO",
    "anchored stretched-exponential perturbation"
  ]

end TopologicalPhases
