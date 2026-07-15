module Properties
  ( PropertyCheck (..)
  , propertyChecks
  , validProgram
  ) where

import Core

data PropertyCheck = PropertyCheck
  { propertyName :: String
  , propertyPassed :: Bool
  }
  deriving (Eq, Show)

assemblyArrows :: [Arrow]
assemblyArrows =
  [ Arrow
      LocalQuantumInteractions
      CondensedHamiltonianModuli
      Proposed
      (Just "family stack construction")
  , Arrow
      CondensedHamiltonianModuli
      UniformlyGappedSubstack
      Proposed
      (Just "pullback-stable propositional image")
  , Arrow
      UniformlyGappedSubstack
      StabilizedPhaseInfinityGroupoid
      Proposed
      (Just "controlled localization and stabilization")
  , Arrow
      StabilizedPhaseInfinityGroupoid
      InvertibleCondensedPhaseSpectrum
      Proposed
      (Just "Picard object and internal spectrification")
  ]

controlledKMap :: ComparisonClaim
controlledKMap =
  ComparisonClaim
    "controlled free functional calculus"
    InvariantMap
    Established
    (Just "continuous functional calculus with a common Fermi gap")

kubotaComparison :: ComparisonClaim
kubotaComparison =
  ComparisonClaim
    "Kubota spectrum to condensed spectrum"
    InvariantMap
    Open
    Nothing

qualifiedCharge :: RelativeCharge
qualifiedCharge =
  RelativeCharge
    { invariantDegree = 2
    , relativeDegree = 3
    , codimension = 1
    , thomDegree = Just 2
    , normalBundleOriented = True
    , usesTwistedTarget = False
    , calledPhysical = True
    , hasMicroscopicComparison = True
    }

validProgram :: Program
validProgram =
  Program
    { programStages = expectedStages
    , programArrows = assemblyArrows
    , gapRepresentation = PropositionalImage
    , comparisons = [controlledKMap, kubotaComparison]
    , relativeCharges = [qualifiedCharge]
    , spatialDimension = 2
    , spacetimeDimension = 3
    }

replaceGapRepresentation :: GapRepresentation -> Program -> Program
replaceGapRepresentation representation program =
  program {gapRepresentation = representation}

replaceStages :: [Stage] -> Program -> Program
replaceStages stages program = program {programStages = stages}

replaceComparisons :: [ComparisonClaim] -> Program -> Program
replaceComparisons claims program = program {comparisons = claims}

replaceCharges :: [RelativeCharge] -> Program -> Program
replaceCharges charges program = program {relativeCharges = charges}

replaceArrows :: [Arrow] -> Program -> Program
replaceArrows arrows program = program {programArrows = arrows}

unsupportedEquivalence :: ComparisonClaim
unsupportedEquivalence =
  ComparisonClaim
    "equivalence missing theorem"
    Equivalence
    Conjectural
    Nothing

unsupportedEquivalenceStatus :: ComparisonClaim
unsupportedEquivalenceStatus =
  ComparisonClaim
    "open claim presented as equivalence"
    Equivalence
    Open
    (Just "candidate comparison construction")

badDegreeCharge :: RelativeCharge
badDegreeCharge =
  qualifiedCharge
    { relativeDegree = 2
    , thomDegree = Just 1
    }

badThomDegreeCharge :: RelativeCharge
badThomDegreeCharge = qualifiedCharge {thomDegree = Just 99}

negativeCodimensionCharge :: RelativeCharge
negativeCodimensionCharge =
  qualifiedCharge
    { codimension = -1
    , thomDegree = Nothing
    }

badOrientationCharge :: RelativeCharge
badOrientationCharge =
  qualifiedCharge
    { normalBundleOriented = False
    , usesTwistedTarget = False
    }

badPhysicalCharge :: RelativeCharge
badPhysicalCharge = qualifiedCharge {hasMicroscopicComparison = False}

badDimensionProgram :: Program
badDimensionProgram = validProgram {spacetimeDimension = 4}

missingArrowProgram :: Program
missingArrowProgram = replaceArrows (drop 1 assemblyArrows) validProgram

duplicateArrowProgram :: Program
duplicateArrowProgram =
  replaceArrows (headArrow : assemblyArrows) validProgram
  where
    headArrow =
      Arrow
        LocalQuantumInteractions
        CondensedHamiltonianModuli
        Proposed
        (Just "duplicate family stack construction")

missingProviderProgram :: Program
missingProviderProgram =
  replaceArrows (badArrow : drop 1 assemblyArrows) validProgram
  where
    badArrow =
      Arrow
        LocalQuantumInteractions
        CondensedHamiltonianModuli
        Proposed
        Nothing

establishedArrowProgram :: Program
establishedArrowProgram =
  replaceArrows (badArrow : drop 1 assemblyArrows) validProgram
  where
    badArrow =
      Arrow
        LocalQuantumInteractions
        CondensedHamiltonianModuli
        Established
        (Just "incorrectly promoted assembly arrow")

onlyError :: ValidationError -> Program -> Bool
onlyError expected program = validateProgram program == [expected]

arrowPairsOf :: Program -> [(Stage, Stage)]
arrowPairsOf program =
  map
    (\arrow -> (arrowSource arrow, arrowTarget arrow))
    (programArrows program)

propertyChecks :: [PropertyCheck]
propertyChecks =
  [ PropertyCheck
      "the canonical five-stage program validates"
      (isValid validProgram)
  , PropertyCheck
      "removing a stage is rejected"
      ( not
          ( isValid
              (replaceStages (drop 1 expectedStages) validProgram)
          )
      )
  , PropertyCheck
      "a witness fibration cannot stand for the qualitative gapped locus"
      ( not
          ( isValid
              (replaceGapRepresentation WitnessFibration validProgram)
          )
      )
  , PropertyCheck
      "an unsupported spectrum equivalence is rejected"
      ( onlyError
          (EquivalenceMissingTheorem "equivalence missing theorem")
          (replaceComparisons [unsupportedEquivalence] validProgram)
      )
  , PropertyCheck
      "an equivalence with a theorem but open status is rejected"
      ( onlyError
          ( EquivalenceHasUnsupportedStatus
              "open claim presented as equivalence"
              Open
          )
          ( replaceComparisons
              [unsupportedEquivalenceStatus]
              validProgram
          )
      )
  , PropertyCheck
      "the relative connecting map raises degree by one"
      ( onlyError
          (RelativeDegreeMismatch 3 2)
          (replaceCharges [badDegreeCharge] validProgram)
      )
  , PropertyCheck
      "an incorrect Thom degree is rejected"
      ( onlyError
          (ThomDegreeMismatch 2 99)
          (replaceCharges [badThomDegreeCharge] validProgram)
      )
  , PropertyCheck
      "a negative codimension is rejected"
      ( onlyError
          (NegativeCodimension (-1))
          (replaceCharges [negativeCodimensionCharge] validProgram)
      )
  , PropertyCheck
      "an untwisted Thom target requires orientation"
      ( not
          ( isValid
              (replaceCharges [badOrientationCharge] validProgram)
          )
      )
  , PropertyCheck
      "a physical charge requires a microscopic comparison"
      ( not
          ( isValid
              (replaceCharges [badPhysicalCharge] validProgram)
          )
      )
  , PropertyCheck
      "spacetime dimension must equal spatial dimension plus one"
      (not (isValid badDimensionProgram))
  , PropertyCheck
      "a missing assembly arrow is rejected"
      ( onlyError
          (ArrowListMismatch (arrowPairsOf missingArrowProgram))
          missingArrowProgram
      )
  , PropertyCheck
      "a duplicate assembly arrow is rejected"
      ( onlyError
          (ArrowListMismatch (arrowPairsOf duplicateArrowProgram))
          duplicateArrowProgram
      )
  , PropertyCheck
      "an assembly arrow without a provider is rejected"
      ( onlyError
          ( ArrowMissingProvider
              LocalQuantumInteractions
              CondensedHamiltonianModuli
          )
          missingProviderProgram
      )
  , PropertyCheck
      "an assembly arrow cannot be promoted to established"
      ( onlyError
          ( EstablishedAssemblyArrow
              LocalQuantumInteractions
              CondensedHamiltonianModuli
          )
          establishedArrowProgram
      )
  ]
