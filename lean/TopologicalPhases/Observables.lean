import TopologicalPhases.Core

namespace TopologicalPhases

/-- An involution is provided separately in every parameter fiber. -/
structure ObjectwiseInvolution (Parameter Algebra : Type) where
  star : Parameter -> Algebra -> Algebra
  involutive : forall parameter value,
    star parameter (star parameter value) = value

/--
A positive cone is fiberwise, closed under addition, and contains star-squares.
Further analytic closure properties belong in a concrete C-star algebra instance.
-/
structure ObjectwisePositiveCone
    (Parameter Algebra : Type)
    [Zero Algebra] [Add Algebra] [Mul Algebra]
    (involution : ObjectwiseInvolution Parameter Algebra) where
  positive : Parameter -> Algebra -> Prop
  zeroPositive : forall parameter, positive parameter 0
  addClosed : forall parameter {left right},
    positive parameter left ->
    positive parameter right ->
    positive parameter (left + right)
  starSquarePositive : forall parameter value,
    positive parameter (involution.star parameter value * value)

/--
The norm laws needed from each fiber. The scalar type is abstract so the interface
does not pretend that Lean's standard library supplies real C-star analysis.
-/
structure ObjectwiseCStarNormConditions
    (Parameter Algebra NormValue : Type)
    [Zero Algebra] [Add Algebra] [Mul Algebra]
    [OfNat NormValue 0] [LE NormValue] [Add NormValue] [Mul NormValue]
    (involution : ObjectwiseInvolution Parameter Algebra) where
  norm : Parameter -> Algebra -> NormValue
  nonnegative : forall parameter value, 0 <= norm parameter value
  definite : forall parameter value, norm parameter value = 0 <-> value = 0
  triangle : forall parameter left right,
    norm parameter (left + right) <= norm parameter left + norm parameter right
  submultiplicative : forall parameter left right,
    norm parameter (left * right) <= norm parameter left * norm parameter right
  cstarIdentity : forall parameter value,
    norm parameter (involution.star parameter value * value) =
      norm parameter value * norm parameter value

/--
This provider records the exact scope of Aoki's connective comparison. A concrete
implementation must encode the real or complex Banach-algebra hypothesis and the
solidification equivalence. Bott inversion is a separate qualification.
-/
structure AokiConnectiveComparisonInterface
    (Algebra AlgebraicK TopologicalK : Type)
    (EligibleBanachAlgebra : Algebra -> Prop)
    (SolidificationComparison : Algebra -> AlgebraicK -> TopologicalK -> Prop) where
  algebraicK : Algebra -> AlgebraicK
  connectiveTopologicalK : Algebra -> TopologicalK
  compare : forall algebra,
    EligibleBanachAlgebra algebra ->
    SolidificationComparison algebra
      (algebraicK algebra) (connectiveTopologicalK algebra)

def aokiComparisonProvenance : Provenance where
  claim := "Solidified connective algebraic K-theory compares with connective topological K-theory"
  status := .established
  sources := [{
    citation := "Aoki, (Semi)topological K-theory via solidification"
    locator := some "arXiv:2409.01462"
  }]
  assumptions := [
    "real or complex Banach algebra",
    "connective comparison before Bott inversion"
  ]

end TopologicalPhases
