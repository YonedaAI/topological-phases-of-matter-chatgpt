module Realizability
  ( Status (..)
  , Dimensions (..)
  , SymmetryWitness (..)
  , GapWitness (..)
  , ComparisonEvidence (..)
  , RealizationEntry (..)
  , RelativeInput (..)
  , RelativeResult (..)
  , validDimensions
  , hasExplicitInteraction
  , hasSymmetryWitness
  , hasGapWitness
  , hasMicroscopicInvariant
  , comparisonIsScoped
  , validateEntry
  , entryContractValid
  , validateRegistry
  , connectingDegree
  , thomLocalizedDegree
  , relativeCharge
  , classDEntry
  , bdiEntry
  , akltEntry
  , openBordismEntry
  , registry
  ) where

import Data.Char (isSpace)

data Status
  = Realized
  | Candidate
  | Open
  | Obstructed
  deriving (Eq, Show)

data Dimensions = Dimensions
  { spatialDimension :: Int
  , spacetimeDimension :: Int
  }
  deriving (Eq, Show)

data SymmetryWitness = SymmetryWitness
  { symmetryGroup :: String
  , symmetryLaw :: String
  }
  deriving (Eq, Show)

data GapWitness
  = ExactGap Double String
  | PublishedGapTheorem String
  deriving (Eq, Show)

data ComparisonEvidence
  = MicroscopicOnly
  | EffectiveAgreement String
  | ProvenComparison String
  | ComparisonOpen String
  | UnprovedSpectrumEquivalence String
  deriving (Eq, Show)

data RealizationEntry = RealizationEntry
  { entryName :: String
  , entryDimensions :: Dimensions
  , interactionWitness :: Maybe String
  , symmetryWitness :: Maybe SymmetryWitness
  , gapWitnesses :: [GapWitness]
  , microscopicInvariant :: Maybe String
  , comparisonEvidence :: ComparisonEvidence
  , realizationStatus :: Status
  }
  deriving (Eq, Show)

data RelativeInput = RelativeInput
  { sourceDegree :: Int
  , normalCodimension :: Int
  , invariantExists :: Bool
  , invariantRestrictsFromBase :: Bool
  , excisionHypothesesHold :: Bool
  , normalBundleIsOriented :: Bool
  }
  deriving (Eq, Show)

data RelativeResult
  = InvalidRelativeInput [String]
  | NoInvariantClass
  | ZeroByExtension Int
  | RelativeClass Int (Maybe Int)
  deriving (Eq, Show)

validDimensions :: Dimensions -> Bool
validDimensions dimensions =
  spatialDimension dimensions >= 0
    && spacetimeDimension dimensions == spatialDimension dimensions + 1

hasExplicitInteraction :: RealizationEntry -> Bool
hasExplicitInteraction entry =
  maybe False nonBlank (interactionWitness entry)

hasSymmetryWitness :: RealizationEntry -> Bool
hasSymmetryWitness entry =
  case symmetryWitness entry of
    Nothing -> False
    Just witness ->
      nonBlank (symmetryGroup witness) && nonBlank (symmetryLaw witness)

hasGapWitness :: RealizationEntry -> Bool
hasGapWitness entry =
  not (null (gapWitnesses entry)) && all validGapWitness (gapWitnesses entry)

hasMicroscopicInvariant :: RealizationEntry -> Bool
hasMicroscopicInvariant entry =
  maybe False nonBlank (microscopicInvariant entry)

comparisonIsScoped :: ComparisonEvidence -> Bool
comparisonIsScoped evidence =
  case evidence of
    MicroscopicOnly -> True
    EffectiveAgreement explanation -> nonBlank explanation
    ProvenComparison theoremName -> nonBlank theoremName
    ComparisonOpen explanation -> nonBlank explanation
    UnprovedSpectrumEquivalence _ -> False

validateEntry :: RealizationEntry -> [String]
validateEntry entry =
  dimensionErrors
    ++ nameErrors
    ++ comparisonErrors
    ++ realizedErrors
  where
    dimensionErrors =
      ["spacetime dimension must equal spatial dimension plus one"
      | not (validDimensions (entryDimensions entry))
      ]
    nameErrors = ["entry name must be nonblank" | not (nonBlank (entryName entry))]
    comparisonErrors =
      ["comparison evidence overclaims an unproved spectrum equivalence"
      | not (comparisonIsScoped (comparisonEvidence entry))
      ]
    realizedErrors
      | realizationStatus entry /= Realized = []
      | otherwise =
          ["realized row lacks an explicit interaction" | not (hasExplicitInteraction entry)]
            ++ ["realized row lacks complete symmetry data" | not (hasSymmetryWitness entry)]
            ++ ["realized row lacks valid uniform-gap evidence" | not (hasGapWitness entry)]
            ++ ["realized row lacks a microscopic invariant" | not (hasMicroscopicInvariant entry)]

entryContractValid :: RealizationEntry -> Bool
entryContractValid = null . validateEntry

validateRegistry :: [RealizationEntry] -> [(String, [String])]
validateRegistry entries =
  [ (entryName entry, errors)
  | entry <- entries
  , let errors = validateEntry entry
  , not (null errors)
  ]

connectingDegree :: Int -> Int
connectingDegree degree = degree + 1

thomLocalizedDegree :: Int -> Int -> Maybe Int
thomLocalizedDegree degree codimension
  | codimension <= 0 = Nothing
  | otherwise = Just (connectingDegree degree - codimension)

relativeCharge :: RelativeInput -> RelativeResult
relativeCharge input
  | not (null inputErrors) = InvalidRelativeInput inputErrors
  | not (invariantExists input) = NoInvariantClass
  | invariantRestrictsFromBase input = ZeroByExtension targetDegree
  | otherwise = RelativeClass targetDegree localDegree
  where
    targetDegree = connectingDegree (sourceDegree input)
    inputErrors =
      ["normal codimension must be positive"
      | normalCodimension input <= 0
      ]
    localDegree
      | excisionHypothesesHold input && normalBundleIsOriented input =
          thomLocalizedDegree (sourceDegree input) (normalCodimension input)
      | otherwise = Nothing

classDEntry :: RealizationEntry
classDEntry =
  RealizationEntry
    { entryName = "class-D Kitaev chain"
    , entryDimensions = Dimensions 1 2
    , interactionWitness = Just "nearest-neighbor hopping and p-wave pairing at mu=0, Delta=t"
    , symmetryWitness =
        Just
          SymmetryWitness
            { symmetryGroup = "fermion parity with BdG particle-hole structure"
            , symmetryLaw = "C squared equals +1"
            }
    , gapWitnesses = [ExactGap 2.0 "flat periodic BdG spectrum in units t=1"]
    , microscopicInvariant = Just "nontrivial Pfaffian parity and one Majorana per open end"
    , comparisonEvidence =
        EffectiveAgreement "nontrivial spin/Arf Z2 class in spacetime dimension two"
    , realizationStatus = Realized
    }

bdiEntry :: RealizationEntry
bdiEntry =
  RealizationEntry
    { entryName = "BDI interaction reduction"
    , entryDimensions = Dimensions 1 2
    , interactionWitness = Just "real Kitaev stacks with local Fidkowski-Kitaev interactions"
    , symmetryWitness =
        Just
          SymmetryWitness
            { symmetryGroup = "BDI time reversal and fermion parity"
            , symmetryLaw = "antiunitary T squared equals +1"
            }
    , gapWitnesses =
        [ ExactGap 2.0 "flat free bulk spectrum in units t=1"
        , PublishedGapTheorem "Fidkowski-Kitaev eight-copy gapped interpolation"
        ]
    , microscopicInvariant = Just "free integer index reduced to residue modulo eight"
    , comparisonEvidence =
        EffectiveAgreement "Pin-minus Arf-Brown-Kervaire Z8 agreement in spacetime dimension two"
    , realizationStatus = Realized
    }

akltEntry :: RealizationEntry
akltEntry =
  RealizationEntry
    { entryName = "SO(3)-protected AKLT chain"
    , entryDimensions = Dimensions 1 2
    , interactionWitness = Just "nearest-neighbor total-spin-two projectors"
    , symmetryWitness =
        Just
          SymmetryWitness
            { symmetryGroup = "SO(3)"
            , symmetryLaw = "linear on-site spin-one action"
            }
    , gapWitnesses =
        [PublishedGapTheorem "Affleck-Kennedy-Lieb-Tasaki one-dimensional bulk-gap theorem"]
    , microscopicInvariant = Just "nontrivial projective spin-one-half edge representation"
    , comparisonEvidence =
        EffectiveAgreement "nontrivial H^2(SO(3),U(1)) Z2 sector"
    , realizationStatus = Realized
    }

openBordismEntry :: RealizationEntry
openBordismEntry =
  RealizationEntry
    { entryName = "arbitrary Freed-Hopkins torsion class"
    , entryDimensions = Dimensions 3 4
    , interactionWitness = Nothing
    , symmetryWitness = Nothing
    , gapWitnesses = []
    , microscopicInvariant = Nothing
    , comparisonEvidence =
        ComparisonOpen "no general microscopic realization or obstruction theorem supplied"
    , realizationStatus = Open
    }

registry :: [RealizationEntry]
registry = [classDEntry, bdiEntry, akltEntry, openBordismEntry]

validGapWitness :: GapWitness -> Bool
validGapWitness witness =
  case witness of
    ExactGap lowerBound reason -> lowerBound > 0 && nonBlank reason
    PublishedGapTheorem citation -> nonBlank citation

nonBlank :: String -> Bool
nonBlank = any (not . isSpace)
