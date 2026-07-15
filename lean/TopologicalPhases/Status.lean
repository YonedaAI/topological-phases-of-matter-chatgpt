import Std

namespace TopologicalPhases

/-- The claim labels used throughout the paper series. -/
inductive ClaimStatus where
  | established
  | proposed
  | conjectural
  | openProblem
  | obstructed
deriving DecidableEq, Repr

/-- A source can name a paper and, when useful, a precise locator. -/
structure SourceRef where
  citation : String
  locator : Option String := none
deriving DecidableEq, Repr

/-- Provenance keeps a formal declaration tied to its stated research status. -/
structure Provenance where
  claim : String
  status : ClaimStatus
  sources : List SourceRef := []
  assumptions : List String := []
deriving DecidableEq, Repr

def Provenance.isEstablished (entry : Provenance) : Bool :=
  entry.status == .established

end TopologicalPhases
