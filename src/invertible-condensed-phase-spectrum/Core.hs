module Core
  ( Status (..)
  , Stage (..)
  , GapRepresentation (..)
  , ComparisonStrength (..)
  , Arrow (..)
  , ComparisonClaim (..)
  , RelativeCharge (..)
  , Program (..)
  , ValidationError (..)
  , expectedStages
  , adjacentPairs
  , validateProgram
  , validateComparison
  , validateRelativeCharge
  , isValid
  ) where

import Data.Maybe (isNothing)

data Status
  = Established
  | Proposed
  | Conjectural
  | Open
  | Obstructed
  deriving (Eq, Ord, Show)

data Stage
  = LocalQuantumInteractions
  | CondensedHamiltonianModuli
  | UniformlyGappedSubstack
  | StabilizedPhaseInfinityGroupoid
  | InvertibleCondensedPhaseSpectrum
  deriving (Eq, Ord, Show, Enum, Bounded)

data GapRepresentation
  = WitnessFibration
  | PropositionalImage
  deriving (Eq, Show)

data ComparisonStrength
  = InvariantMap
  | Equivalence
  deriving (Eq, Show)

data Arrow = Arrow
  { arrowSource :: Stage
  , arrowTarget :: Stage
  , arrowStatus :: Status
  , arrowProvider :: Maybe String
  }
  deriving (Eq, Show)

data ComparisonClaim = ComparisonClaim
  { comparisonName :: String
  , comparisonStrength :: ComparisonStrength
  , comparisonStatus :: Status
  , comparisonTheorem :: Maybe String
  }
  deriving (Eq, Show)

data RelativeCharge = RelativeCharge
  { invariantDegree :: Int
  , relativeDegree :: Int
  , codimension :: Int
  , thomDegree :: Maybe Int
  , normalBundleOriented :: Bool
  , usesTwistedTarget :: Bool
  , calledPhysical :: Bool
  , hasMicroscopicComparison :: Bool
  }
  deriving (Eq, Show)

data Program = Program
  { programStages :: [Stage]
  , programArrows :: [Arrow]
  , gapRepresentation :: GapRepresentation
  , comparisons :: [ComparisonClaim]
  , relativeCharges :: [RelativeCharge]
  , spatialDimension :: Int
  , spacetimeDimension :: Int
  }
  deriving (Eq, Show)

data ValidationError
  = StageSequenceMismatch [Stage]
  | ArrowListMismatch [(Stage, Stage)]
  | ArrowMissingProvider Stage Stage
  | EstablishedAssemblyArrow Stage Stage
  | QualitativeGapUsesWitnessFibration
  | EquivalenceMissingTheorem String
  | EquivalenceHasUnsupportedStatus String Status
  | RelativeDegreeMismatch Int Int
  | NegativeCodimension Int
  | ThomDegreeMismatch Int Int
  | UnorientedUntwistedThomTarget
  | PhysicalChargeMissingComparison
  | DimensionShiftMismatch Int Int
  deriving (Eq, Show)

expectedStages :: [Stage]
expectedStages =
  [ LocalQuantumInteractions
  , CondensedHamiltonianModuli
  , UniformlyGappedSubstack
  , StabilizedPhaseInfinityGroupoid
  , InvertibleCondensedPhaseSpectrum
  ]

adjacentPairs :: [Stage] -> [(Stage, Stage)]
adjacentPairs stages = zip stages (drop 1 stages)

validateProgram :: Program -> [ValidationError]
validateProgram program =
  stageErrors
    ++ arrowErrors
    ++ gapErrors
    ++ concatMap validateComparison (comparisons program)
    ++ concatMap validateRelativeCharge (relativeCharges program)
    ++ dimensionErrors
  where
    stageErrors =
      [ StageSequenceMismatch (programStages program)
      | programStages program /= expectedStages
      ]
    expectedPairs = adjacentPairs expectedStages
    arrowPairs =
      map
        (\arrow -> (arrowSource arrow, arrowTarget arrow))
        (programArrows program)
    sequenceErrors =
      [ ArrowListMismatch arrowPairs
      | arrowPairs /= expectedPairs
      ]
    providerErrors =
      [ ArrowMissingProvider (arrowSource arrow) (arrowTarget arrow)
      | arrow <- programArrows program
      , isNothing (arrowProvider arrow)
      ]
    statusErrors =
      [ EstablishedAssemblyArrow (arrowSource arrow) (arrowTarget arrow)
      | arrow <- programArrows program
      , arrowStatus arrow == Established
      ]
    arrowErrors = sequenceErrors ++ providerErrors ++ statusErrors
    gapErrors =
      [ QualitativeGapUsesWitnessFibration
      | gapRepresentation program == WitnessFibration
      ]
    dimensionErrors =
      [ DimensionShiftMismatch
          (spatialDimension program)
          (spacetimeDimension program)
      | spacetimeDimension program /= spatialDimension program + 1
      ]

validateComparison :: ComparisonClaim -> [ValidationError]
validateComparison claim = theoremErrors ++ statusErrors
  where
    theoremErrors =
      [ EquivalenceMissingTheorem (comparisonName claim)
      | comparisonStrength claim == Equivalence
      , isNothing (comparisonTheorem claim)
      ]
    statusErrors =
      [ EquivalenceHasUnsupportedStatus
          (comparisonName claim)
          (comparisonStatus claim)
      | comparisonStrength claim == Equivalence
      , comparisonStatus claim `notElem` [Established, Conjectural]
      ]

validateRelativeCharge :: RelativeCharge -> [ValidationError]
validateRelativeCharge charge =
  relativeErrors ++ codimensionErrors ++ thomErrors ++ physicalErrors
  where
    expectedRelative = invariantDegree charge + 1
    relativeErrors =
      [ RelativeDegreeMismatch expectedRelative (relativeDegree charge)
      | relativeDegree charge /= expectedRelative
      ]
    codimensionErrors =
      [ NegativeCodimension (codimension charge)
      | codimension charge < 0
      ]
    expectedThom = relativeDegree charge - codimension charge
    thomErrors =
      case thomDegree charge of
        -- No Thom target is asserted, so orientation is not yet required.
        Nothing -> []
        Just actual ->
          [ ThomDegreeMismatch expectedThom actual
          | actual /= expectedThom
          ]
            ++ [ UnorientedUntwistedThomTarget
               | not (normalBundleOriented charge)
               , not (usesTwistedTarget charge)
               ]
    physicalErrors =
      [ PhysicalChargeMissingComparison
      | calledPhysical charge
      , not (hasMicroscopicComparison charge)
      ]

isValid :: Program -> Bool
isValid = null . validateProgram
