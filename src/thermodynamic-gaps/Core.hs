{-|
Module      : Core
Description : Finite computations illustrating spectral-gap conventions.
License     : MIT

The functions in this module check finite spectra and explicit sequences from
the accompanying paper. They provide computational evidence only. They do not
prove a thermodynamic spectral gap.
-}
module Core
  ( Gap
  , unGap
  , GapPredicate(..)
  , ClaimStatus(..)
  , WitnessProvider(..)
  , GapWitness(..)
  , mkGap
  , literalGroundGap
  , selectedBandGap
  , pointwisePositive
  , uniformAtLeast
  , commonFiniteLowerBound
  , matrixCollapseGaps
  , movingDefectGap
  , ferromagnetUpperBound
  , twoLevelGap
  , weakenWitness
  ) where

import Data.List (sort)

-- | A strictly positive finite lower bound.
--
-- The constructor is intentionally private.  Keep this as a non-record
-- newtype so clients cannot bypass 'mkGap' with record-update syntax.
newtype Gap = Gap Double
  deriving (Eq, Ord, Show)

-- | Extract the certified numerical lower bound.
unGap :: Gap -> Double
unGap (Gap value) = value

-- | The spectral predicate certified by a witness.
data GapPredicate
  = SelectedGroundBand
  | BulkGNS
  deriving (Eq, Show)

-- | Honest status of the evidence carried by a witness.
data ClaimStatus
  = Proved
  | Conditional
  | Computational
  | Obstructed
  | Open
  deriving (Eq, Show)

-- | Provenance for the lower bound in a witness.
data WitnessProvider
  = FiniteComputation String
  | CitedTheorem String
  | FormalProof String
  deriving (Eq, Show)

-- | A computational representation of a quantitative gap witness.
data GapWitness = GapWitness
  { witnessPredicate :: GapPredicate
  , witnessLowerBound :: Gap
  , witnessProvider :: WitnessProvider
  , witnessStatus :: ClaimStatus
  } deriving (Eq, Show)

-- | Construct a valid positive finite gap.
mkGap :: Double -> Maybe Gap
mkGap x
  | isNaN x = Nothing
  | isInfinite x = Nothing
  | x > 0 = Just (Gap x)
  | otherwise = Nothing

-- | Gap above the exactly degenerate minimum of a finite spectrum.
literalGroundGap :: [Double] -> Maybe Gap
literalGroundGap values
  | not (validSpectrum values) = Nothing
  | otherwise =
      case sort values of
        [] -> Nothing
        ground : rest ->
          case dropWhile (== ground) rest of
            [] -> Nothing
            excited : _ -> mkGap (excited - ground)

-- | Separation between spectrum at or below a cutoff and spectrum above it.
selectedBandGap :: Double -> [Double] -> Maybe Gap
selectedBandGap cutoff values
  | isNaN cutoff = Nothing
  | isInfinite cutoff = Nothing
  | not (validSpectrum values) = Nothing
  | otherwise =
      let ordered = sort values
          low = takeWhile (<= cutoff) ordered
          high = dropWhile (<= cutoff) ordered
      in case (reverse low, high) of
           (topLow : _, bottomHigh : _) -> mkGap (bottomHigh - topLow)
           _ -> Nothing

validValue :: Double -> Bool
validValue value = not (isNaN value) && not (isInfinite value)

validSpectrum :: [Double] -> Bool
validSpectrum = all validValue

-- | Check the weak claim that every sampled number is positive.
pointwisePositive :: [Double] -> Bool
pointwisePositive = all (\value -> validValue value && value > 0)

-- | Check one declared lower bound against every sampled gap.
uniformAtLeast :: Gap -> [Double] -> Bool
uniformAtLeast (Gap gamma) = all (>= gamma)

-- | A finite nonempty positive list has a positive minimum.
--
-- This function does not extrapolate beyond the supplied finite list.
commonFiniteLowerBound :: [Double] -> Maybe Gap
commonFiniteLowerBound [] = Nothing
commonFiniteLowerBound values
  | pointwisePositive values = mkGap (minimum values)
  | otherwise = Nothing

-- | Literal gaps for diag(0, 1/n, 1), followed by the rank-changing limit.
matrixCollapseGaps :: Int -> [Double]
matrixCollapseGaps count
  | count <= 0 = [1]
  | otherwise = [1 / fromIntegral n | n <- [2 .. count + 1]] ++ [1]

-- | Exact gap of the moving weak defect model at parameter n.
movingDefectGap :: Int -> Maybe Gap
movingDefectGap n
  | n > 0 = mkGap (1 / fromIntegral n)
  | otherwise = Nothing

-- | One-magnon upper bound for an open ferromagnetic chain of length L.
ferromagnetUpperBound :: Int -> Maybe Gap
ferromagnetUpperBound lengthL
  | lengthL >= 2 =
      let halfAngle = pi / (2 * fromIntegral lengthL)
      in mkGap (2 * sin halfAngle * sin halfAngle)
  | otherwise = Nothing

-- | Eigenvalue separation for the two-level family [[-1,s],[s,1]].
twoLevelGap :: Double -> Maybe Gap
twoLevelGap s
  | isNaN s = Nothing
  | isInfinite s = Nothing
  | abs s <= 1 = mkGap (2 * sqrt (1 + s * s))
  | otherwise =
      let magnitude = abs s
      in mkGap (2 * magnitude * sqrt (1 + (1 / magnitude) * (1 / magnitude)))

-- | Any smaller positive number is also certified by a gap witness.
weakenWitness :: GapWitness -> Double -> Maybe GapWitness
weakenWitness witness candidate = do
  smaller <- mkGap candidate
  if smaller <= witnessLowerBound witness
    then Just witness { witnessLowerBound = smaller }
    else Nothing
