module ContractChecks
  ( ContractCheck (..)
  , contractChecks
  ) where

import Core
import Properties (validProgram)

data ContractCheck = ContractCheck
  { contractCheckName :: String
  , contractCheckPassed :: Bool
  }
  deriving (Eq, Show)

canonicalPairs :: [(Stage, Stage)]
canonicalPairs =
  [ (LocalQuantumInteractions, CondensedHamiltonianModuli)
  , (CondensedHamiltonianModuli, UniformlyGappedSubstack)
  , (UniformlyGappedSubstack, StabilizedPhaseInfinityGroupoid)
  , (StabilizedPhaseInfinityGroupoid, InvertibleCondensedPhaseSpectrum)
  ]

orientedCharge :: RelativeCharge
orientedCharge =
  RelativeCharge
    { invariantDegree = 4
    , relativeDegree = 5
    , codimension = 3
    , thomDegree = Just 2
    , normalBundleOriented = True
    , usesTwistedTarget = False
    , calledPhysical = False
    , hasMicroscopicComparison = False
    }

twistedCharge :: RelativeCharge
twistedCharge =
  orientedCharge
    { normalBundleOriented = False
    , usesTwistedTarget = True
    }

establishedEquivalence :: ComparisonClaim
establishedEquivalence =
  ComparisonClaim
    "test equivalence with provider"
    Equivalence
    Established
    (Just "explicit comparison theorem")

contractChecks :: [ContractCheck]
contractChecks =
  [ ContractCheck
      "adjacentPairs computes the four arrows of the five-stage sequence"
      (adjacentPairs expectedStages == canonicalPairs)
  , ContractCheck
      "the valid program has no validation errors"
      (null (validateProgram validProgram))
  , ContractCheck
      "a codimension-three Thom shift maps degree five to degree two"
      (null (validateRelativeCharge orientedCharge))
  , ContractCheck
      "an unoriented Thom target is accepted only when marked twisted"
      (null (validateRelativeCharge twistedCharge))
  , ContractCheck
      "an established equivalence is accepted only with a theorem provider"
      (null (validateComparison establishedEquivalence))
  ]
