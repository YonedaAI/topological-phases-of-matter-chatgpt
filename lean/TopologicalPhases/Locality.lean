import TopologicalPhases.Core

namespace TopologicalPhases

/-- A finite interaction term records both its support and its operator data. -/
structure InteractionTerm (siteCount : Nat) (Operator : Type) where
  support : LocalSupport siteCount
  operator : Operator
deriving Repr

abbrev FiniteInteraction (siteCount : Nat) (Operator : Type) :=
  List (InteractionTerm siteCount Operator)

/-- Every pair of sites in a support lies within the stated radius. -/
def SupportHasDiameterAtMost
    (metric : FiniteMetricSite siteCount)
    (support : LocalSupport siteCount)
    (radius : Nat) : Prop :=
  forall x, x ∈ support.sites ->
    forall y, y ∈ support.sites ->
      metric.distance x y <= radius

/-- One operator-size bound works for every term in every parameter fiber. -/
def InteractionTermsUniformlyBounded [LE Bound]
    (operatorSize : Operator -> Bound)
    (family : Parameter -> FiniteInteraction siteCount Operator)
    (bound : Bound) : Prop :=
  forall parameter term,
    term ∈ family parameter -> operatorSize term.operator <= bound

/-- One finite interaction radius works for every parameter fiber. -/
def InteractionFamilyHasFiniteRange
    (metric : FiniteMetricSite siteCount)
    (family : Parameter -> FiniteInteraction siteCount Operator)
    (radius : Nat) : Prop :=
  forall parameter term,
    term ∈ family parameter ->
      SupportHasDiameterAtMost metric term.support radius

/--
The finite data and proof obligations needed before invoking a Lieb-Robinson theorem.
The continuity predicate is a parameter because its analytic meaning depends on the
chosen topology and operator space.
-/
structure LiebRobinsonHypotheses
    (Parameter Operator Bound : Type)
    [LE Bound]
    (siteCount : Nat)
    (ParameterContinuous :
      (Parameter -> FiniteInteraction siteCount Operator) -> Prop) where
  metric : FiniteMetricSite siteCount
  interactions : Parameter -> FiniteInteraction siteCount Operator
  operatorSize : Operator -> Bound
  uniformSizeBound : Bound
  uniformlyBounded :
    InteractionTermsUniformlyBounded operatorSize interactions uniformSizeBound
  interactionRadius : Nat
  finiteRange :
    InteractionFamilyHasFiniteRange metric interactions interactionRadius
  locallyContinuous : ParameterContinuous interactions

abbrev ParameterizedDynamics (Parameter Time Observable : Type) :=
  Parameter -> Time -> Observable -> Observable

/--
The three conclusions expected from the analytic theorem. Each predicate is kept
explicit so an imported theorem must prove the exact statement used by a paper.
-/
structure LiebRobinsonResult
    (Parameter Time Observable : Type)
    (ThermodynamicDynamics UniformPropagation ParameterContinuity :
      ParameterizedDynamics Parameter Time Observable -> Prop) where
  dynamics : ParameterizedDynamics Parameter Time Observable
  thermodynamicDynamics : ThermodynamicDynamics dynamics
  uniformPropagation : UniformPropagation dynamics
  continuousInParameter : ParameterContinuity dynamics

/--
An analytic implementation must construct this provider from a cited theorem.
Declaring the interface does not prove a thermodynamic limit or propagation bound.
-/
structure LiebRobinsonTheoremInterface
    (Parameter Operator Bound Observable Time : Type)
    [LE Bound]
    (siteCount : Nat)
    (InteractionContinuity :
      (Parameter -> FiniteInteraction siteCount Operator) -> Prop)
    (ThermodynamicDynamics UniformPropagation DynamicsContinuity :
      ParameterizedDynamics Parameter Time Observable -> Prop) where
  derive :
    LiebRobinsonHypotheses
      Parameter Operator Bound siteCount InteractionContinuity ->
    LiebRobinsonResult
      Parameter Time Observable
      ThermodynamicDynamics UniformPropagation DynamicsContinuity

def liebRobinsonInterfaceProvenance : Provenance where
  claim := "Uniform locality and continuity support parameterized Lieb-Robinson dynamics"
  status := .established
  sources := [{
    citation := "Nachtergaele and Sims, Lieb-Robinson Bounds in Quantum Many-Body Physics"
    locator := some "arXiv:1004.2086"
  }]
  assumptions := [
    "uniformly locally finite geometry",
    "an admissible decay function",
    "a uniform interaction bound",
    "local parameter continuity"
  ]

end TopologicalPhases
