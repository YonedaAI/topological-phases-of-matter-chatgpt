module Main (main) where

import Locality
  ( Fiber (LimitFiber, MovingDefect)
  , FiniteLine (FiniteLine)
  , defectGap
  , finiteConvolutionConstant
  , finiteSummability
  , firstNGapMinimum
  , interactionSupremum
  , liebRobinsonEnvelope
  , limitGap
  , locallyAgreesWithLimit
  , pairDecaySum
  , pointwisePositive
  , uniformlyAbove
  )
import Text.Printf (printf)

main :: IO ()
main = do
  let line = FiniteLine 41
      power = 3.0
      summability = finiteSummability line power
      convolution = finiteConvolutionConstant line power
      spatial = pairDecaySum line power [4, 5] [33, 34]
      envelope = liebRobinsonEnvelope convolution 1.0 0.4 1.0 1.0 spatial
      indices = [1 .. 12]
      sampledGaps = map defectGap indices
  putStrLn "Finite locality diagnostics on a 41-site line"
  printf "sup_x sum_y F(d(x,y)) = %.8f\n" summability
  printf "finite convolution constant = %.8f\n" convolution
  printf "finite Lieb-Robinson envelope = %.8e\n" envelope
  printf "interaction supremum, defect fiber 12 = %.8f\n"
    (interactionSupremum line (MovingDefect 12))
  printf "interaction supremum, limit fiber = %.8f\n"
    (interactionSupremum line LimitFiber)
  printf "minimum of first 12 defect gaps = %s\n" (show (firstNGapMinimum 12))
  printf "limit-fiber gap = %.8f\n" limitGap
  printf "all sampled fibers are pointwise gapped = %s\n"
    (show (pointwisePositive sampledGaps))
  printf "sampled family uniformly above 0.05 = %s\n"
    (show (uniformlyAbove 0.05 sampledGaps))
  printf "sampled family uniformly above 0.10 = %s\n"
    (show (uniformlyAbove 0.10 sampledGaps))
  printf "defect 12 is invisible in radius 5 = %s\n"
    (show (locallyAgreesWithLimit 5 12))
