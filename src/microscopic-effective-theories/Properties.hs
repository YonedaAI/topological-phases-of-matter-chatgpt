module Properties
  ( PropertyResult(..)
  , properties
  , runProperties
  ) where

import Core
import Proofs (ProofCheck(..), proofChecks)

data PropertyResult = PropertyResult
  { propertyName :: String
  , propertyPassed :: Bool
  } deriving (Eq, Show)

approx :: Double -> Double -> Bool
approx left right = abs (left - right) < 1.0e-9

rightEquals :: Eq value => value -> Either String value -> Bool
rightEquals expected actual = actual == Right expected

topologicalModel :: SSHModel
topologicalModel = SSHModel 0.5 1.0 0.0

trivialModel :: SSHModel
trivialModel = SSHModel 1.5 1.0 0.0

criticalModel :: SSHModel
criticalModel = SSHModel 1.0 1.0 0.0

negativeHoppingModel :: SSHModel
negativeHoppingModel = SSHModel (-0.4) 1.2 0.0

nearCriticalModel :: SSHModel
nearCriticalModel = SSHModel 0.99 1.0 0.0

scaledTopologicalModel :: SSHModel
scaledTopologicalModel = scaleModel 3.0 topologicalModel

detourHasConstantGap :: Bool
detourHasConstantGap =
  case symmetryBreakingDetour 64 1.0 0.5 of
    Left _ -> False
    Right path -> maybe False (approx 1.0) (minimumBandGap path)

flatteningHasUnitLength :: Bool
flatteningHasUnitLength =
  case flattenAt 1.0e-12 topologicalModel 0.7 of
    Left _ -> False
    Right (xCoord, yCoord, zCoord) ->
      approx 1.0 (sqrt (xCoord * xCoord + yCoord * yCoord + zCoord * zCoord))

informationContractPartitionsData :: Bool
informationContractPartitionsData =
  let contract = spectralFlatteningContract
      retained = retainedData contract
      discarded = discardedData contract
      excluded = outsideDomain contract
      disjoint left right = all (`notElem` right) left
  in all (not . null) [retained, discarded, excluded]
      && disjoint retained discarded
      && disjoint retained excluded
      && disjoint discarded excluded

isLeft :: Either String value -> Bool
isLeft (Left _) = True
isLeft (Right _) = False

arrowAuditKeepsMapsSeparate :: Bool
arrowAuditKeepsMapsSeparate =
  map arrowStatus comparisonAudit
    == [ControlledSector, InvariantOnly, OpenProblem]

properties :: [PropertyResult]
properties =
  [ PropertyResult "SSH bands are symmetric around zero"
      (let (lower, upper) = energies topologicalModel 0.31
       in approx lower (-upper))
  , PropertyResult "analytic bulk gap detects the topological sample"
      (approx 1.0 (bandGap topologicalModel))
  , PropertyResult "critical SSH model has zero bulk gap"
      (approx 0.0 (bandGap criticalModel))
  , PropertyResult "spectral flattening has unit Bloch vector"
      flatteningHasUnitLength
  , PropertyResult "flattened energies are plus and minus one"
      (flattenedEnergies == (-1.0, 1.0))
  , PropertyResult "analytic winding distinguishes the two chiral phases"
      (rightEquals 1 (winding 1.0e-12 topologicalModel)
        && rightEquals 0 (winding 1.0e-12 trivialModel))
  , PropertyResult "numeric winding agrees with analytic winding"
      (numericWinding 4096 1.0e-12 topologicalModel
        == winding 1.0e-12 topologicalModel)
  , PropertyResult "numeric winding also recognizes the trivial phase"
      (rightEquals 0 (numericWinding 4096 1.0e-12 trivialModel))
  , PropertyResult "negative hoppings preserve the analytic and numeric class"
      (rightEquals 1 (winding 1.0e-12 negativeHoppingModel)
        && numericWinding 4096 1.0e-12 negativeHoppingModel
          == winding 1.0e-12 negativeHoppingModel)
  , PropertyResult "near-critical winding rejects an undersampled mesh"
      (isLeft (numericWinding 4 1.0e-12 nearCriticalModel))
  , PropertyResult "winding rejects broken symmetry and invalid meshes"
      (isLeft (numericWinding 4096 1.0e-12 (SSHModel 0.5 1.0 0.2))
        && isLeft (numericWinding 3 1.0e-12 topologicalModel)
        && isLeft (numericWinding 4096 1.0e-12 criticalModel))
  , PropertyResult "classifiers reject non-finite model parameters"
      (isLeft (winding 1.0e-12 (SSHModel (0.0 / 0.0) 1.0 0.0))
        && isLeft (numericWinding 4096 1.0e-12
          (SSHModel (1.0 / 0.0) 1.0 0.0))
        && isLeft (flattenAt 1.0e-12 topologicalModel (0.0 / 0.0))
        && not (isGapped 1.0e-12 (SSHModel (1.0 / 0.0) 1.0 0.0)))
  , PropertyResult "relative class is target minus reference"
      (rightEquals 1 (relativeWinding 1.0e-12 topologicalModel trivialModel))
  , PropertyResult "critical model has no winding class"
      (case winding 1.0e-12 criticalModel of
        Left _ -> True
        Right _ -> False)
  , PropertyResult "local SSH transition charge has degree minus one"
      (rightEquals (-1) (localTransitionCharge 4096))
  , PropertyResult "symmetry-breaking detour keeps a constant gap"
      detourHasConstantGap
  , PropertyResult "positive rescaling preserves class but changes gap"
      (winding 1.0e-12 topologicalModel == winding 1.0e-12 scaledTopologicalModel
        && not (approx (bandGap topologicalModel) (bandGap scaledTopologicalModel)))
  , PropertyResult "information-loss categories are nonempty and disjoint"
      informationContractPartitionsData
  , PropertyResult "comparison audit does not collapse the three arrows"
      arrowAuditKeepsMapsSeparate
  , PropertyResult "equational proof checks pass on their stated finite domains"
      (all proofPassed proofChecks)
  ]

runProperties :: IO Bool
runProperties = do
  mapM_ printResult properties
  let passed = length (filter propertyPassed properties)
      total = length properties
  putStrLn (show passed ++ "/" ++ show total ++ " properties passed")
  pure (passed == total)
  where
    printResult result =
      putStrLn
        ((if propertyPassed result then "PASS " else "FAIL ")
          ++ propertyName result)
