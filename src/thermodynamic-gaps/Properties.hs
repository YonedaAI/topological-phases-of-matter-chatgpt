{-|
Module      : Properties
Description : Deterministic properties for the finite spectral-gap examples.
License     : MIT
-}
module Properties
  ( PropertyResult(..)
  , runProperties
  ) where

import Core

-- | A named deterministic check.
data PropertyResult = PropertyResult
  { propertyName :: String
  , propertyPassed :: Bool
  } deriving (Eq, Show)

gapValue :: Maybe Gap -> Maybe Double
gapValue = fmap unGap

approximatelyEqual :: Double -> Double -> Bool
approximatelyEqual left right = abs (left - right) <= 1.0e-12

lastMaybe :: [value] -> Maybe value
lastMaybe [] = Nothing
lastMaybe [value] = Just value
lastMaybe (_ : rest) = lastMaybe rest

literalDegeneracyProperty :: PropertyResult
literalDegeneracyProperty =
  PropertyResult
    "literal gap groups exact ground-state degeneracy"
    (maybe False (`approximatelyEqual` 0.25) (gapValue (literalGroundGap [0, 0, 0.25, 1])))

bandSeparationProperty :: PropertyResult
bandSeparationProperty =
  PropertyResult
    "selected band ignores internal low-energy splitting"
    (maybe False (`approximatelyEqual` 0.79) (gapValue (selectedBandGap 0.1 [0, 0.01, 0.8, 1])))

matrixCollapseProperty :: PropertyResult
matrixCollapseProperty =
  let samples = matrixCollapseGaps 100
      finitePrefixPositive = pointwisePositive samples
      noFixedTenth = maybe False (\gap -> not (uniformAtLeast gap samples)) (mkGap 0.1)
  in PropertyResult
       "pointwise matrix gaps need not satisfy a proposed common bound"
       (finitePrefixPositive && noFixedTenth)

twoLevelProperty :: PropertyResult
twoLevelProperty =
  let samplePoints = [-1, -0.75 .. 1]
      gaps = [value | Just value <- map (fmap unGap . twoLevelGap) samplePoints]
  in PropertyResult
       "constant-rank two-level family has common gap two"
       (length gaps == length samplePoints && all (>= 2) gaps)

ferromagnetScalingProperty :: PropertyResult
ferromagnetScalingProperty =
  let sizes = [8, 16, 32, 64, 128]
      gaps = [value | Just value <- map (fmap unGap . ferromagnetUpperBound) sizes]
      decreasing = and (zipWith (>) gaps (drop 1 gaps))
      scaled = zipWith (\size gap -> fromIntegral (size * size) * gap) sizes gaps
      target = pi * pi / 2
  in PropertyResult
       "ferromagnetic upper bound decreases with L and scales as L^-2"
       (decreasing && maybe False (\value -> abs (value - target) < 0.001) (lastMaybe scaled))

movingDefectProperty :: PropertyResult
movingDefectProperty =
  let indices = [1 .. 200]
      gaps = [value | Just value <- map (fmap unGap . movingDefectGap) indices]
  in PropertyResult
       "moving weak-defect gaps approach zero"
       ( length gaps == length indices
         && maybe False (< 0.01) (lastMaybe gaps)
         && pointwisePositive gaps
       )

witnessMonotonicityProperty :: PropertyResult
witnessMonotonicityProperty =
  let original = do
        bound <- mkGap 0.5
        pure
          ( GapWitness
              BulkGNS
              bound
              (CitedTheorem "controlled theorem fixture")
              Conditional
          )
      weaker = original >>= (`weakenWitness` 0.25)
      invalid = original >>= (`weakenWitness` 0.75)
  in PropertyResult
       "witness can be weakened but not strengthened without evidence"
       ( maybe False (`approximatelyEqual` 0.25) (fmap (unGap . witnessLowerBound) weaker)
         && invalid == Nothing
       )

finiteMinimumProperty :: PropertyResult
finiteMinimumProperty =
  PropertyResult
    "finite positive samples have their minimum as a common lower bound"
    ( maybe
        False
        (\bound -> uniformAtLeast bound [0.5, 0.25, 0.75])
        (commonFiniteLowerBound [0.5, 0.25, 0.75])
    )

invalidSpectrumProperty :: PropertyResult
invalidSpectrumProperty =
  PropertyResult
    "invalid floating-point spectra are rejected"
    ( literalGroundGap [0, 1, 0 / 0] == Nothing
      && selectedBandGap 0.5 [0, 1 / 0] == Nothing
      && not (pointwisePositive [1 / 0])
      && commonFiniteLowerBound [1 / 0] == Nothing
    )

-- | All deterministic checks corresponding to finite examples in the paper.
runProperties :: [PropertyResult]
runProperties =
  [ literalDegeneracyProperty
  , bandSeparationProperty
  , matrixCollapseProperty
  , twoLevelProperty
  , ferromagnetScalingProperty
  , movingDefectProperty
  , witnessMonotonicityProperty
  , finiteMinimumProperty
  , invalidSpectrumProperty
  ]
