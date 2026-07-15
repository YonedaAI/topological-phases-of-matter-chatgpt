import TopologicalPhases

open TopologicalPhases

example : ClaimStatus.established != ClaimStatus.proposed := by decide

example : UniformlyBounded (fun n : Nat => n) (fun flag : Bool => if flag then 2 else 1) 2 := by
  intro flag
  cases flag <;> decide

def testGap : FiniteVolumeGapWitness (Fin 3) Bool Nat where
  gap _ _ := 2
  lowerBound := 1
  lowerBoundPositive := Nat.zero_lt_succ 0
  uniformGap := by
    intro _ _
    exact Nat.succ_le_succ (Nat.zero_le 1)

example (volume : Fin 3) (parameter : Bool) : 1 <= testGap.gap volume parameter :=
  testGap.uniformGap volume parameter

def toyStar : ObjectwiseInvolution Bool Nat where
  star _ value := value
  involutive := by
    intro _ _
    rfl

def toyCone : ObjectwisePositiveCone Bool Nat toyStar where
  positive _ _ := True
  zeroPositive := by
    intro _
    exact True.intro
  addClosed := by
    intro _ _ _ _ _
    exact True.intro
  starSquarePositive := by
    intro _ _
    exact True.intro

example : toyCone.positive true 7 := by trivial

def oneTerm : InteractionTerm 1 Nat where
  support := LocalSupport.singleton 0
  operator := 3

#eval oneTerm.support.sites.length

def forwardSeparation (lower higher : Nat) : Nat :=
  higher - lower

def toyLiteralGap : LiteralFiniteGap Nat Nat forwardSeparation where
  spectrum := [0, 0, 3, 5]
  groundEnergy := 0
  groundOccurs := by simp
  firstExcitedEnergy := 3
  firstExcitedOccurs := by simp
  groundStrictlyBelow := by decide
  groundIsMinimum := by
    intro energy _
    exact Nat.zero_le energy
  firstExcitedIsLeast := by
    intro energy inSpectrum aboveGround
    simp at inSpectrum
    omega
  gapPositive := by decide

example : toyLiteralGap.gapValue = 3 := by decide

def toySelectedBand : SelectedBandGap Nat Nat forwardSeparation where
  spectrum := [0, 1, 4]
  selected := fun energy => energy <= 1
  selectedWitness := 0
  selectedWitnessOccurs := by simp
  selectedWitnessInBand := by decide
  complementWitness := 4
  complementWitnessOccurs := by simp
  complementWitnessOutsideBand := by decide
  lowerBound := 3
  lowerBoundPositive := by decide
  separated := by
    intro selectedEnergy selectedOccurs selectedInBand
    intro complementaryEnergy complementaryOccurs complementaryOutside
    change selectedEnergy <= 1 at selectedInBand
    change Not (complementaryEnergy <= 1) at complementaryOutside
    simp at selectedOccurs complementaryOccurs
    unfold forwardSeparation
    omega

def toyGapFunction (parameter : Bool) : Nat :=
  if parameter then 5 else 3

def toyCommonGap : CommonGapWitness Bool Nat toyGapFunction where
  lowerBound := 3
  lowerBoundPositive := by decide
  uniform := by
    intro parameter
    cases parameter <;> decide

def natGapOrderLaws : GapOrderLaws Nat where
  leTransitive := by
    intro first second third firstBelow secondBelow
    exact Nat.le_trans firstBelow secondBelow
  minimum := fun left right => if left <= right then left else right
  minimumPositive := by
    intro left right leftPositive rightPositive
    split
    · exact leftPositive
    · exact rightPositive
  minimumLELeft := by
    intro left right
    split
    · exact Nat.le_refl left
    · rename_i notLeftBelow
      omega
  minimumLERight := by
    intro left right
    split
    · rename_i leftBelow
      exact leftBelow
    · exact Nat.le_refl right

def toyWeakenedGap : CommonGapWitness Bool Nat toyGapFunction :=
  CommonGapWitness.weaken natGapOrderLaws toyCommonGap 2 (by decide) (by decide)

example (parameter : Bool) : 2 <= toyGapFunction parameter :=
  toyWeakenedGap.uniform parameter

abbrev ToyGapFamily := Bool -> Nat

abbrev ToyGapWitness (family : ToyGapFamily) :=
  CommonGapWitness Bool Nat family

def toyWitnessedFamily : WitnessedFamily ToyGapFamily ToyGapWitness where
  family := toyGapFunction
  witness := toyCommonGap

example : QualitativelyGapped ToyGapWitness toyGapFunction :=
  toyWitnessedFamily.qualitativelyGapped

def trueRegionGap : LocalGapWitness Bool Nat toyGapFunction where
  region := fun parameter => parameter = true
  lowerBound := 5
  lowerBoundPositive := by decide
  validOn := by
    intro parameter inRegion
    subst parameter
    decide

def falseRegionGap : LocalGapWitness Bool Nat toyGapFunction where
  region := fun parameter => parameter = false
  lowerBound := 3
  lowerBoundPositive := by decide
  validOn := by
    intro parameter inRegion
    subst parameter
    decide

def toyFiniteCover : FiniteGapCover Bool Nat toyGapFunction :=
  .branch (.leaf trueRegionGap) (.leaf falseRegionGap)

theorem toyFiniteCover_isTotal : forall parameter, toyFiniteCover.region parameter := by
  intro parameter
  cases parameter <;>
    simp [toyFiniteCover, FiniteGapCover.region, trueRegionGap, falseRegionGap]

def toyCoverCommonGap : CommonGapWitness Bool Nat toyGapFunction :=
  FiniteGapCover.toCommonGapWitness
    natGapOrderLaws toyFiniteCover toyFiniteCover_isTotal

example : FiniteGapCover.lowerBound natGapOrderLaws toyFiniteCover = 3 := by decide

example (parameter : Bool) : 3 <= toyGapFunction parameter :=
  toyCoverCommonGap.uniform parameter

def toyHasBulkGapAtLeast (system lowerBound : Nat) : Prop :=
  lowerBound <= system

def toyGNSGapWitness : GNSGapWitness Nat Nat toyHasBulkGapAtLeast 5 where
  lowerBound := 3
  lowerBoundPositive := by decide
  verified := by
    change 3 <= 5
    decide

example : toyHasBulkGapAtLeast 5 toyGNSGapWitness.lowerBound :=
  toyGNSGapWitness.verified

example : ComparisonArrowKind.microscopicToLowEnergy !=
    ComparisonArrowKind.microscopicRealization := by
  decide

example : Not generalMicroscopicToEFTDeclaration.HasSuppliedMap := by
  simp [ComparisonArrowDeclaration.HasSuppliedMap,
    generalMicroscopicToEFTDeclaration]

example : Not generalMicroscopicRealizationDeclaration.HasSuppliedMap := by
  simp [ComparisonArrowDeclaration.HasSuppliedMap,
    generalMicroscopicRealizationDeclaration]

example : flatteningRetains .encodedSymmetry = true := by decide

example : flatteningForgets .gapMagnitude = true := by decide

example : flatteningForgets .finiteBandUnstableData = true := by decide

def toyFermiGap (parameter : Bool) : Nat :=
  if parameter then 4 else 3

def toyControlledHamiltonian (parameter : Bool) : Nat :=
  if parameter then 7 else 5

def toyHasFermiGapAtLeast (hamiltonian lowerBound : Nat) : Prop :=
  lowerBound <= hamiltonian

def toyFlatteningHypotheses : ControlledFlatteningHypotheses
    Bool Nat Nat toyFermiGap
    (fun _ => True) (fun _ => True) (fun _ => True) toyHasFermiGapAtLeast where
  family := toyControlledHamiltonian
  reference := 6
  familyBounded := by
    intro _
    trivial
  referenceBounded := by trivial
  familySelfAdjoint := by
    intro _
    trivial
  referenceSelfAdjoint := by trivial
  familySymmetry := by
    intro _
    trivial
  referenceSymmetry := by trivial
  commonFermiGap := {
    lowerBound := 3
    lowerBoundPositive := by decide
    uniform := by
      intro parameter
      cases parameter <;> decide
  }
  familyGapValueVerified := by
    intro parameter
    change toyFermiGap parameter <= toyControlledHamiltonian parameter
    cases parameter <;> decide
  familyGapVerified := by
    intro parameter
    change 3 <= toyControlledHamiltonian parameter
    cases parameter <;> decide
  referenceGap := 2
  referenceGapPositive := by decide
  referenceGapVerified := by
    change 2 <= 6
    decide

abbrev ToyRealizabilityRow := RealizabilityRow
  String String String String String String String String String String

def toyComparisonSupported (_ : String) (status : ClaimStatus) : Bool :=
  status == .openProblem

def toyRealizedRow : ToyRealizabilityRow where
  proposedClass := "nontrivial one-dimensional phase"
  spatialDimension := 1
  spacetimeDimension := 2
  kinematics := some "finite local Hilbert space"
  boundaryConvention := some "periodic bulk"
  interaction := some "explicit finite-range interaction"
  symmetry := some "explicit symmetry action"
  uniformGapEvidence := some "uniform gap theorem"
  microscopicInvariant := some "computed microscopic invariant"
  abstractTarget := "fixed abstract target"
  abstractComparison := some "limited effective-theory agreement"
  comparisonStatus := .openProblem
  realizationStatus := .realized
  obstructionEvidence := none

def toyIncompleteRealizedRow : ToyRealizabilityRow :=
  { toyRealizedRow with uniformGapEvidence := none }

def toyInvalidDimensionRow : ToyRealizabilityRow :=
  { toyRealizedRow with spacetimeDimension := 1 }

def toyCompleteCandidateRow : ToyRealizabilityRow :=
  { toyRealizedRow with realizationStatus := .candidate }

def toyOpenRow : ToyRealizabilityRow :=
  { toyRealizedRow with
    kinematics := none
    boundaryConvention := none
    interaction := none
    symmetry := none
    uniformGapEvidence := none
    microscopicInvariant := none
    abstractComparison := none
    realizationStatus := .openProblem }

def toyObstructedRow : ToyRealizabilityRow :=
  { toyRealizedRow with
    realizationStatus := .obstructed
    obstructionEvidence := some "obstruction theorem under fixed rules" }

example : toyRealizedRow.contractHolds toyComparisonSupported = true := by decide

example : toyIncompleteRealizedRow.contractHolds toyComparisonSupported = false := by decide

example : toyInvalidDimensionRow.contractHolds toyComparisonSupported = false := by decide

example : toyCompleteCandidateRow.contractHolds toyComparisonSupported = false := by decide

example : toyOpenRow.contractHolds toyComparisonSupported = true := by decide

example : toyObstructedRow.contractHolds toyComparisonSupported = true := by decide

example : RealizationStatus.openProblem != RealizationStatus.obstructed := by decide

example : relativeChargeDegree 2 = 3 := by decide

example : thomLocalizedDegree 2 3 = 0 := by decide

example : Not kubotaToFreedHopkinsComparison.HasSuppliedMap := by
  simp [PhaseObjectComparison.HasSuppliedMap, kubotaToFreedHopkinsComparison]

example : Not kubotaToCondensedComparison.HasSuppliedMap := by
  simp [PhaseObjectComparison.HasSuppliedMap, kubotaToCondensedComparison]

example : condensedPhaseConstructionFlow = [
    .localQuantumInteractions,
    .condensedHamiltonianModuli,
    .uniformlyGappedPropositionalSubstack,
    .stabilizedPhaseInfinityGroupoid,
    .invertibleCondensedPhaseSpectrum
  ] := by
  rfl

example : condensedPhaseConstructionFlow.length = 5 := by decide

example : condensedPhaseConstructionSteps.all
    (fun step => step.status == .proposed) = true := by decide

example : mainCondensedCategoricalArrows.map
    (fun arrow => (arrow.source, arrow.target)) = [
      (.localInteractions, .hamiltonianModuli),
      (.propositionalGappedLocus, .hamiltonianModuli),
      (.propositionalGappedLocus, .stabilizedPhases),
      (.stabilizedPhases, .condensedPhaseSpectrum)
    ] := by
  decide

example : mainCondensedCategoricalArrows.all
    (fun arrow => arrow.status == .proposed) = true := by decide

example : mainCondensedCategoricalArrows.map (fun arrow => arrow.kind) = [
    .analyticPackaging,
    .gappedSubobjectInclusion,
    .phaseLocalizationAndStabilization,
    .invertibleSectorAndSpectrification
  ] := by
  decide

example : PropositionalGappedImage ToyGapWitness toyGapFunction :=
  quantitativeGapFibration_toPropositionalImage toyWitnessedFamily

example : conditionalAssemblyAssumptions.length = 8 := by decide

example : defectCodimensionOfBasedFamily 0 = 1 := by decide

example : defectCodimensionOfBasedFamily 2 = 3 := by decide

example : everyRelativeClassIsPhysicalProvenance.status = .obstructed := by
  decide

def runCheck (label : String) (condition : Bool) : IO Unit :=
  if condition then
    IO.println ("PASS: " ++ label)
  else
    throw (IO.userError ("FAIL: " ++ label))

def main : IO Unit := do
  runCheck "literal finite gap" (toyLiteralGap.gapValue == 3)
  runCheck "selected band has a nonempty complement" (toySelectedBand.complementWitness == 4)
  runCheck "selected-band lower bound" (toySelectedBand.lowerBound == 3)
  runCheck "witness weakening" (toyWeakenedGap.lowerBound == 2)
  runCheck "finite-cover minimum"
    (FiniteGapCover.lowerBound natGapOrderLaws toyFiniteCover == 3)
  runCheck "finite-cover witness is uniform"
    (decide (3 <= toyGapFunction true) && decide (3 <= toyGapFunction false))
  runCheck "GNS witness is tied to its selected system"
    (toyGNSGapWitness.lowerBound == 3)
  runCheck "comparison arrow kinds remain distinct"
    (decide (ComparisonArrowKind.microscopicToLowEnergy !=
      ComparisonArrowKind.microscopicRealization))
  runCheck "flattening retains encoded symmetry"
    (flatteningRetains .encodedSymmetry)
  runCheck "flattening forgets gap magnitude"
    (flatteningForgets .gapMagnitude)
  runCheck "flattening forgets unstable finite-band data"
    (flatteningForgets .finiteBandUnstableData)
  runCheck "controlled flattening hypotheses carry a common gap"
    (toyFlatteningHypotheses.commonFermiGap.lowerBound == 3)
  runCheck "realizability matrix accepts a complete realized row"
    (toyRealizedRow.contractHolds toyComparisonSupported)
  runCheck "realizability matrix rejects a missing gap witness"
    (not (toyIncompleteRealizedRow.contractHolds toyComparisonSupported))
  runCheck "realizability matrix rejects an invalid dimension shift"
    (not (toyInvalidDimensionRow.contractHolds toyComparisonSupported))
  runCheck "candidate status requires a genuinely missing witness"
    (not (toyCompleteCandidateRow.contractHolds toyComparisonSupported))
  runCheck "open status is distinct from obstruction"
    (toyOpenRow.contractHolds toyComparisonSupported)
  runCheck "obstructed status requires supplied evidence"
    (toyObstructedRow.contractHolds toyComparisonSupported)
  runCheck "relative charge raises degree by one"
    (relativeChargeDegree 2 == 3)
  runCheck "oriented Thom localization applies the codimension shift"
    (thomLocalizedDegree 2 3 == 0)
  runCheck "open comparison declarations supply no maps"
    (generalMicroscopicRealizationDeclaration.suppliedMap.isNone &&
      kubotaToCondensedComparison.suppliedMap.isNone)
  runCheck "five-stage synthesis flow is exact"
    (condensedPhaseConstructionFlow == [
      .localQuantumInteractions,
      .condensedHamiltonianModuli,
      .uniformlyGappedPropositionalSubstack,
      .stabilizedPhaseInfinityGroupoid,
      .invertibleCondensedPhaseSpectrum
    ])
  runCheck "construction arrows remain proposed"
    (condensedPhaseConstructionSteps.all
      (fun step => step.status == .proposed))
  runCheck "categorical variance points the gapped locus into Hamiltonian moduli"
    (mainCondensedCategoricalArrows.map
      (fun arrow => (arrow.source, arrow.target)) == [
        (.localInteractions, .hamiltonianModuli),
        (.propositionalGappedLocus, .hamiltonianModuli),
        (.propositionalGappedLocus, .stabilizedPhases),
        (.stabilizedPhases, .condensedPhaseSpectrum)
      ])
  runCheck "stage five records invertible-sector restriction before spectrification"
    (mainCondensedCategoricalArrows.map (fun arrow => arrow.kind) == [
      .analyticPackaging,
      .gappedSubobjectInclusion,
      .phaseLocalizationAndStabilization,
      .invertibleSectorAndSpectrification
    ])
  runCheck "the conditional assembly lists eight obligations"
    (conditionalAssemblyAssumptions.length == 8)
  runCheck "a based two-sphere family targets codimension three"
    (defectCodimensionOfBasedFamily 2 == 3)
  runCheck "a universal physical interpretation of relative classes is obstructed"
    (everyRelativeClassIsPhysicalProvenance.status == .obstructed)

#print axioms testGap
#print axioms toyStar
#print axioms toyCone
#print axioms oneSiteMetric
#print axioms LiebRobinsonTheoremInterface
#print axioms AokiConnectiveComparisonInterface
#print axioms LiteralFiniteGap
#print axioms SelectedBandGap
#print axioms CommonGapWitness.weaken
#print axioms FiniteGapCover.toCommonGapWitness
#print axioms toyGNSGapWitness
#print axioms GNSGapTheoremInterface
#print axioms SpectralFlowTheoremInterface
#print axioms ControlledLTQOStabilityTheoremInterface
#print axioms MicroscopicToLowEnergyComparisonInterface
#print axioms InvariantExtractionInterface
#print axioms MicroscopicRealizationInterface
#print axioms ControlledFlatteningTheoremInterface
#print axioms toyFlatteningHypotheses
#print axioms RealizabilityRow.contractHolds
#print axioms toyRealizedRow
#print axioms RelativeChargeTheoremInterface
#print axioms ExcisionTheoremInterface
#print axioms ThomLocalizationTheoremInterface
#print axioms MicroscopicChargeComparisonInterface
#print axioms ConditionalPhysicalChargeInterface
#print axioms relativeChargeDegree_eq
#print axioms thomLocalizedDegree_eq
#print axioms condensedPhaseConstructionFlow
#print axioms mainCondensedCategoricalArrows
#print axioms quantitativeGapFibration_toPropositionalImage
#print axioms PhaseLocalizationInterface
#print axioms AtomicStabilizationInterface
#print axioms StackingDescentInterface
#print axioms InvertibleSectorInterface
#print axioms InternalConnectiveSpectrificationInterface
#print axioms ConditionalCondensedSpectrumAssemblyInterface
#print axioms AdiabaticPumpTransportInterface
#print axioms FamilyToDefectInterface
#print axioms PhaseSpectrumHomotopyInterpretationInterface
#print axioms defectCodimensionOfBasedFamily
#print axioms everyRelativeClassIsPhysicalProvenance
