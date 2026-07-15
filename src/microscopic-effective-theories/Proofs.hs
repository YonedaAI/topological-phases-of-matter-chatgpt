{-|
Module      : Proofs
Description : Executable finite checks for derivations used in Paper 4
Copyright   : (c) Matthew Long, 2026
License     : MIT
Maintainer  : matthew@yonedaai.com
Stability   : experimental

The checks cover finite samples and exact formulas implemented in Core. They
are regression checks, not proofs of general operator-algebraic theorems.
-}
module Proofs
  ( ProofCheck(..)
  , proofChecks
  , runProofs
  ) where

import Core

data ProofCheck = ProofCheck
  { proofName :: String
  , proofPassed :: Bool
  , proofDetail :: String
  } deriving (Eq, Show)

approx :: Double -> Double -> Bool
approx left right = abs (left - right) < 1.0e-9

tupleApprox :: (Double, Double, Double) -> (Double, Double, Double) -> Bool
tupleApprox (x1, y1, z1) (x2, y2, z2) =
  approx x1 x2 && approx y1 y2 && approx z1 z2

sampleMomenta :: Int -> [Double]
sampleMomenta samples
  | samples < 1 = []
  | otherwise =
      [2.0 * pi * fromIntegral index / fromIntegral samples
        | index <- [0 .. samples]]

sampledBandGap :: Int -> SSHModel -> Maybe Double
sampledBandGap samples model =
  case [2.0 * upper | momentum <- sampleMomenta samples
          , let (_, upper) = energies model momentum] of
    [] -> Nothing
    gaps -> Just (minimum gaps)

gapFormulaCheck :: ProofCheck
gapFormulaCheck =
  let models =
        [ SSHModel 0.5 1.0 0.0
        , SSHModel 1.5 1.0 0.0
        , SSHModel 0.7 1.0 0.3
        , SSHModel (-0.4) 1.2 0.2
        ]
      passed = all
        (\model -> maybe False (approx (bandGap model)) (sampledBandGap 4096 model))
        models
  in ProofCheck
      "Proposition: analytic SSH gap equals the sampled spectral minimum"
      passed
      "Checked four models on a 4096-segment momentum mesh containing k=pi."

scaleFlatteningCheck :: ProofCheck
scaleFlatteningCheck =
  let model = SSHModel 0.5 1.0 0.0
      scaled = scaleModel 7.0 model
      compareAt momentum =
        case (flattenAt 1.0e-12 model momentum, flattenAt 1.0e-12 scaled momentum) of
          (Right original, Right rescaled) -> tupleApprox original rescaled
          _ -> False
      passed = all compareAt (sampleMomenta 256)
  in ProofCheck
      "Theorem: positive energy rescaling leaves spectral flattening unchanged"
      passed
      "Checked 257 momenta for a factor-seven rescaling."

detourGapCheck :: ProofCheck
detourGapCheck =
  let result = do
        path <- symmetryBreakingDetour 256 1.0 0.5
        smallest <- maybe (Left "empty detour") Right (minimumBandGap path)
        pure (approx smallest 1.0 && all (approx 1.0 . bandGap) path)
      passed = result == Right True
  in ProofCheck
      "Example: the chiral-symmetry-breaking semicircle keeps gap one"
      passed
      "Checked all 257 points of the prescribed mass-plane detour."

relativeAdditivityCheck :: ProofCheck
relativeAdditivityCheck =
  let tolerance = 1.0e-12
      first = SSHModel 1.5 1.0 0.0
      second = SSHModel 0.5 1.0 0.0
      third = SSHModel 2.0 1.0 0.0
      result = do
        secondFromFirst <- relativeWinding tolerance second first
        thirdFromSecond <- relativeWinding tolerance third second
        thirdFromFirst <- relativeWinding tolerance third first
        pure (thirdFromFirst == secondFromFirst + thirdFromSecond)
  in ProofCheck
      "Corollary: relative winding differences are additive"
      (result == Right True)
      "Checked a trivial, topological, trivial triple."

transitionBoundaryCheck :: ProofCheck
transitionBoundaryCheck =
  let tolerance = 1.0e-12
      trivial = SSHModel 1.5 1.0 0.0
      topological = SSHModel 0.5 1.0 0.0
      result = do
        charge <- localTransitionCharge 4096
        jump <- relativeWinding tolerance topological trivial
        pure (charge == negate jump)
  in ProofCheck
      "Example: local linking degree matches the SSH winding jump up to orientation"
      (result == Right True)
      "The local coordinate q=m-ip has degree -1 in the chosen orientation."

proofChecks :: [ProofCheck]
proofChecks =
  [ gapFormulaCheck
  , scaleFlatteningCheck
  , detourGapCheck
  , relativeAdditivityCheck
  , transitionBoundaryCheck
  ]

runProofs :: IO Bool
runProofs = do
  mapM_ printCheck proofChecks
  let passed = length (filter proofPassed proofChecks)
      total = length proofChecks
  putStrLn (show passed ++ "/" ++ show total ++ " proof checks passed")
  pure (passed == total)
  where
    printCheck check = do
      putStrLn
        ((if proofPassed check then "PASS " else "FAIL ") ++ proofName check)
      putStrLn ("  " ++ proofDetail check)
