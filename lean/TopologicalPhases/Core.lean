import Std
import TopologicalPhases.Status

namespace TopologicalPhases

/-- A finite site set with a natural-number-valued metric. -/
structure FiniteMetricSite (siteCount : Nat) where
  distance : Fin siteCount -> Fin siteCount -> Nat
  distance_eq_zero : forall x y, distance x y = 0 <-> x = y
  symmetric : forall x y, distance x y = distance y x
  triangle : forall x y z, distance x z <= distance x y + distance y z

/-- The finite set of sites on which a local term acts. -/
structure LocalSupport (siteCount : Nat) where
  sites : List (Fin siteCount)
  noDuplicates : sites.Nodup
deriving DecidableEq, Repr

namespace LocalSupport

def singleton (site : Fin siteCount) : LocalSupport siteCount :=
  { sites := [site]
    noDuplicates := by simp }

def contains (support : LocalSupport siteCount) (site : Fin siteCount) : Bool :=
  support.sites.contains site

end LocalSupport

/-- One bound that works for every parameter value. -/
def UniformlyBounded [LE Bound]
    (size : Value -> Bound)
    (family : Parameter -> Value)
    (bound : Bound) : Prop :=
  forall parameter, size (family parameter) <= bound

/-- A finite-volume gap function with one positive lower bound for every volume and parameter. -/
structure FiniteVolumeGapWitness
    (Volume Parameter Gap : Type)
    [LT Gap] [LE Gap] [OfNat Gap 0] where
  gap : Volume -> Parameter -> Gap
  lowerBound : Gap
  lowerBoundPositive : 0 < lowerBound
  uniformGap : forall volume parameter, lowerBound <= gap volume parameter

/-- Stacking and the chosen atomic system are structural input, not derived data. -/
class Stacking (System : Type) where
  stack : System -> System -> System
  atomic : System

/-- Stable phase equivalence is supplied together with its equivalence and stacking laws. -/
structure PhaseEquivalence (System : Type) [Stacking System] where
  equivalent : System -> System -> Prop
  reflexive : forall system, equivalent system system
  symmetric : forall {left right}, equivalent left right -> equivalent right left
  transitive : forall {first second third},
    equivalent first second -> equivalent second third -> equivalent first third
  stackCompatible : forall {left left' right right'},
    equivalent left left' ->
    equivalent right right' ->
    equivalent (Stacking.stack left right) (Stacking.stack left' right')

/-- A complete metric on one site, useful for executable interface checks. -/
def oneSiteMetric : FiniteMetricSite 1 where
  distance _ _ := 0
  distance_eq_zero := by
    intro x y
    constructor
    · intro _
      apply Fin.ext
      exact (Fin.val_eq_zero x).trans (Fin.val_eq_zero y).symm
    · intro _
      rfl
  symmetric := by
    intro _ _
    rfl
  triangle := by
    intro _ _ _
    exact Nat.zero_le 0

end TopologicalPhases
