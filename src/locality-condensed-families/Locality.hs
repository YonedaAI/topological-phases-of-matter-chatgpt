module Locality
  ( Site
  , FiniteLine (..)
  , Fiber (..)
  , sites
  , distance
  , polynomialF
  , finiteSummability
  , finiteConvolutionConstant
  , pairDecaySum
  , liebRobinsonEnvelope
  , onsiteStrength
  , interactionSupremum
  , defectGap
  , limitGap
  , firstNGapMinimum
  , pointwisePositive
  , uniformlyAbove
  , locallyAgreesWithLimit
  ) where

type Site = Int

newtype FiniteLine = FiniteLine
  { lineSize :: Int
  }
  deriving (Eq, Show)

data Fiber
  = MovingDefect Int
  | LimitFiber
  deriving (Eq, Show)

sites :: FiniteLine -> [Site]
sites (FiniteLine size) = [0 .. size - 1]

distance :: Site -> Site -> Int
distance x y = abs (x - y)

polynomialF :: Double -> Int -> Double
polynomialF power radius
  | power <= 0 = 0
  | otherwise = (1 + fromIntegral (max 0 radius)) ** (-power)

finiteSummability :: FiniteLine -> Double -> Double
finiteSummability line power =
  maximumOrZero
    [ sum [polynomialF power (distance x y) | y <- sites line]
    | x <- sites line
    ]

finiteConvolutionConstant :: FiniteLine -> Double -> Double
finiteConvolutionConstant line power =
  maximumOrZero
    [ ratio x y
    | x <- sites line
    , y <- sites line
    ]
  where
    ratio :: Site -> Site -> Double
    ratio x y =
      let denominator = polynomialF power (distance x y)
          numerator =
            sum
              [ polynomialF power (distance x z)
                  * polynomialF power (distance z y)
              | z <- sites line
              ]
       in if denominator > 0 then numerator / denominator else 0

pairDecaySum :: FiniteLine -> Double -> [Site] -> [Site] -> Double
pairDecaySum line power supportA supportB =
  sum
    [ polynomialF power (distance x y)
    | x <- supportA
    , x `elem` sites line
    , y <- supportB
    , y `elem` sites line
    ]

liebRobinsonEnvelope :: Double -> Double -> Double -> Double -> Double -> Double -> Double
liebRobinsonEnvelope convolutionConstant interactionNorm time normA normB spatialSum
  | convolutionConstant <= 0 = 0
  | interactionNorm < 0 = 0
  | normA < 0 || normB < 0 || spatialSum < 0 = 0
  | otherwise =
      (2 / convolutionConstant)
        * (exp (2 * convolutionConstant * interactionNorm * abs time) - 1)
        * normA
        * normB
        * spatialSum

onsiteStrength :: Fiber -> Site -> Double
onsiteStrength LimitFiber _ = 1
onsiteStrength (MovingDefect index) site
  | index <= 0 = 0
  | site == index = 1 / fromIntegral index
  | otherwise = 1

interactionSupremum :: FiniteLine -> Fiber -> Double
interactionSupremum line fiber =
  maximumOrZero [onsiteStrength fiber site | site <- sites line]

defectGap :: Int -> Double
defectGap index
  | index <= 0 = 0
  | otherwise = 1 / fromIntegral index

limitGap :: Double
limitGap = 1

firstNGapMinimum :: Int -> Maybe Double
firstNGapMinimum count
  | count <= 0 = Nothing
  | otherwise = Just (minimum [defectGap index | index <- [1 .. count]])

pointwisePositive :: [Double] -> Bool
pointwisePositive = all (> 0)

uniformlyAbove :: Double -> [Double] -> Bool
uniformlyAbove lowerBound values =
  lowerBound > 0 && all (>= lowerBound) values

locallyAgreesWithLimit :: Int -> Int -> Bool
locallyAgreesWithLimit observationRadius defectIndex =
  observationRadius >= 0 && defectIndex > observationRadius

maximumOrZero :: [Double] -> Double
maximumOrZero [] = 0
maximumOrZero values = maximum values
