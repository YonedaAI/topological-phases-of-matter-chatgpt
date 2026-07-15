{-|
Module      : Core
Description : Finite SSH calculations and comparison contracts for Paper 4
Copyright   : (c) Matthew Long, 2026
License     : MIT
Maintainer  : matthew@yonedaai.com
Stability   : experimental

These functions check finite Bloch-model statements from the paper. They do
not prove an interacting thermodynamic theorem or a lattice to field-theory
equivalence.
-}
module Core
  ( SSHModel(..)
  , InformationLossContract(..)
  , ArrowStatus(..)
  , ArrowAssessment(..)
  , blochVector
  , energies
  , halfGap
  , bandGap
  , isGapped
  , flattenAt
  , flattenedEnergies
  , winding
  , numericWinding
  , relativeWinding
  , localTransitionCharge
  , symmetryBreakingDetour
  , minimumBandGap
  , scaleModel
  , spectralFlatteningContract
  , comparisonAudit
  ) where

import Data.Complex (Complex((:+)), phase)

-- | Whether a floating-point input is a finite real number.
isFiniteDouble :: Double -> Bool
isFiniteDouble value = not (isNaN value || isInfinite value)

-- | Validate the public numerical representation before classification.
validateModel :: SSHModel -> Either String ()
validateModel model
  | all isFiniteDouble
      [intraCell model, interCell model, staggeredMass model] = Right ()
  | otherwise = Left "SSH model parameters must be finite"

-- | A numerical tolerance is finite and nonnegative.
validateTolerance :: Double -> Either String ()
validateTolerance tolerance
  | not (isFiniteDouble tolerance) = Left "the tolerance must be finite"
  | tolerance < 0.0 = Left "the tolerance must be nonnegative"
  | otherwise = Right ()

-- | Minimum norm of the off-diagonal chiral symbol q(k).
chiralHalfGap :: SSHModel -> Double
chiralHalfGap model = abs (abs (intraCell model) - abs (interCell model))

-- | Couplings for the two-band SSH Bloch Hamiltonian.
data SSHModel = SSHModel
  { intraCell :: Double
  , interCell :: Double
  , staggeredMass :: Double
  } deriving (Eq, Show)

-- | Data retained, discarded, or excluded by spectral flattening.
data InformationLossContract = InformationLossContract
  { retainedData :: [String]
  , discardedData :: [String]
  , outsideDomain :: [String]
  } deriving (Eq, Show)

-- | Status of one of the three comparison arrows in the paper.
data ArrowStatus
  = ControlledSector
  | InvariantOnly
  | OpenProblem
  deriving (Eq, Show)

-- | A compact audit record for a comparison arrow.
data ArrowAssessment = ArrowAssessment
  { arrowName :: String
  , arrowStatus :: ArrowStatus
  , arrowAssumptions :: [String]
  } deriving (Eq, Show)

-- | Bloch vector (d_x,d_y,d_z) at momentum k.
blochVector :: SSHModel -> Double -> (Double, Double, Double)
blochVector model momentum =
  ( intraCell model + interCell model * cos momentum
  , interCell model * sin momentum
  , staggeredMass model
  )

-- | The two single-particle energies at momentum k.
energies :: SSHModel -> Double -> (Double, Double)
energies model momentum =
  let (xCoord, yCoord, zCoord) = blochVector model momentum
      energy = sqrt (xCoord * xCoord + yCoord * yCoord + zCoord * zCoord)
  in (-energy, energy)

-- | Distance from the Fermi level zero to the spectrum.
halfGap :: SSHModel -> Double
halfGap model =
  sqrt
    ( (abs (intraCell model) - abs (interCell model)) ^ (2 :: Int)
      + staggeredMass model ^ (2 :: Int)
    )

-- | Separation between the occupied and empty bands.
bandGap :: SSHModel -> Double
bandGap model = 2.0 * halfGap model

-- | Whether the Fermi-level gap is larger than a numerical tolerance.
isGapped :: Double -> SSHModel -> Bool
isGapped tolerance model =
  isFiniteDouble tolerance
    && tolerance >= 0.0
    && either (const False) (const True) (validateModel model)
    && isFiniteDouble (halfGap model)
    && halfGap model > tolerance

-- | Normalize the Bloch vector, which is spectral flattening in this model.
flattenAt :: Double -> SSHModel -> Double -> Either String (Double, Double, Double)
flattenAt tolerance model momentum = do
  validateTolerance tolerance
  validateModel model
  if not (isFiniteDouble momentum)
    then Left "the momentum must be finite"
    else
      let (xCoord, yCoord, zCoord) = blochVector model momentum
          vectorNorm = sqrt (xCoord * xCoord + yCoord * yCoord + zCoord * zCoord)
      in if not (isFiniteDouble vectorNorm)
           then Left "the Bloch-vector norm is not finite"
           else if vectorNorm <= tolerance
             then Left "spectral flattening is undefined at a gap closing"
             else Right
               ( xCoord / vectorNorm
               , yCoord / vectorNorm
               , zCoord / vectorNorm
               )

-- | Every flattened two-band Hamiltonian has these eigenvalues.
flattenedEnergies :: (Double, Double)
flattenedEnergies = (-1.0, 1.0)

-- | Analytic AIII winding for a gapped chiral SSH model.
winding :: Double -> SSHModel -> Either String Int
winding tolerance model = do
  validateTolerance tolerance
  validateModel model
  if abs (staggeredMass model) > tolerance
    then Left "the staggered mass breaks chiral symmetry"
    else if chiralHalfGap model <= tolerance
      then Left "the winding is undefined at the gapless discriminant"
      else if abs (intraCell model) < abs (interCell model)
        then Right 1
        else Right 0

-- | Numerically integrate the phase increment of q(k)=t1+t2 exp(ik).
numericWinding :: Int -> Double -> SSHModel -> Either String Int
numericWinding samples tolerance model = do
  validateTolerance tolerance
  validateModel model
  if samples < 4
    then Left "at least four samples are required"
    else if abs (staggeredMass model) > tolerance
      then Left "the staggered mass breaks chiral symmetry"
      else if chiralHalfGap model <= tolerance
        then Left "the winding is undefined at the gapless discriminant"
        else if angularStepBound >= pi
          then Left "the momentum mesh is too coarse for the spectral gap"
          else if any ((>= pi) . abs) increments
            then Left "a phase increment reaches the branch-cut ambiguity"
            else Right (round (sum increments / (2.0 * pi)))
  where
    momenta = [2.0 * pi * fromIntegral index / fromIntegral samples
      | index <- [0 .. samples]]
    qValues = map qValue momenta
    qValue momentum =
      (intraCell model + interCell model * cos momentum)
        :+ (interCell model * sin momentum)
    increments = zipWith phaseIncrement qValues (drop 1 qValues)
    phaseIncrement left right = phase (right / left)
    angularStepBound =
      2.0 * pi * abs (interCell model)
        / (fromIntegral samples * chiralHalfGap model)

-- | Relative class with target first and reference second:
-- target winding minus reference winding.
relativeWinding :: Double -> SSHModel -> SSHModel -> Either String Int
relativeWinding tolerance target reference = do
  targetClass <- winding tolerance target
  referenceClass <- winding tolerance reference
  pure (targetClass - referenceClass)

-- | Degree of q(theta)=cos(theta)-i sin(theta) around the SSH critical point.
localTransitionCharge :: Int -> Either String Int
localTransitionCharge samples
  | samples < 4 = Left "at least four samples are required"
  | any ((>= pi) . abs) increments =
      Left "a phase increment reaches the branch-cut ambiguity"
  | otherwise = Right (round (sum increments / (2.0 * pi)))
  where
    angles :: [Double]
    angles = [2.0 * pi * fromIntegral index / fromIntegral samples
      | index <- [0 .. samples]]
    qValues :: [Complex Double]
    qValues = map (\angle -> cos angle :+ (-sin angle)) angles
    increments :: [Double]
    increments = zipWith phaseIncrement qValues (drop 1 qValues)
    phaseIncrement :: Complex Double -> Complex Double -> Double
    phaseIncrement left right = phase (right / left)

-- | A semicircle in the mass plane that breaks chiral symmetry in its interior.
symmetryBreakingDetour :: Int -> Double -> Double -> Either String [SSHModel]
symmetryBreakingDetour samples hopping radius
  | samples < 1 = Left "at least one path segment is required"
  | not (isFiniteDouble hopping && isFiniteDouble radius) =
      Left "the detour parameters must be finite"
  | hopping <= 0.0 = Left "the reference hopping must be positive"
  | radius <= 0.0 = Left "the detour radius must be positive"
  | radius >= hopping = Left "the detour radius must be smaller than the hopping"
  | otherwise = Right (map modelAt [0 .. samples])
  where
    modelAt index =
      let angle = pi * fromIntegral index / fromIntegral samples
      in SSHModel
        { intraCell = hopping + radius * cos angle
        , interCell = hopping
        , staggeredMass = radius * sin angle
        }

-- | Smallest full band gap along a nonempty sampled path.
minimumBandGap :: [SSHModel] -> Maybe Double
minimumBandGap [] = Nothing
minimumBandGap models = Just (minimum (map bandGap models))

-- | Rescale all microscopic energy parameters.
scaleModel :: Double -> SSHModel -> SSHModel
scaleModel factor model = SSHModel
  { intraCell = factor * intraCell model
  , interCell = factor * interCell model
  , staggeredMass = factor * staggeredMass model
  }

-- | Contract for the controlled spectral-flattening map in the paper.
spectralFlatteningContract :: InformationLossContract
spectralFlatteningContract = InformationLossContract
  { retainedData =
      [ "relative operator K-class"
      , "occupied versus empty grading"
      , "symmetry constraints included in the class"
      , "stable direct-sum law"
      ]
  , discardedData =
      [ "gap magnitude"
      , "dispersion"
      , "correlation length"
      , "locality constants"
      , "microscopic coupling scale"
      , "finite-band unstable data"
      ]
  , outsideDomain =
      [ "interaction data"
      , "a general many-body scaling limit"
      , "an explicit inverse lattice realization"
      ]
  }

-- | The paper's three arrows, kept as distinct claims.
comparisonAudit :: [ArrowAssessment]
comparisonAudit =
  [ ArrowAssessment
      "microscopic Hamiltonian to low-energy theory"
      ControlledSector
      ["quadratic model", "isolated Fermi level", "specified scaling regime"]
  , ArrowAssessment
      "low-energy theory to homotopy or bordism class"
      InvariantOnly
      ["fixed symmetry type", "fixed dimension", "stable equivalence convention"]
  , ArrowAssessment
      "abstract class to explicit lattice representative"
      OpenProblem
      ["locality", "uniform thermodynamic gap", "matching symmetry action"]
  ]
