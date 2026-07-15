{-|
Module      : Main
Description : Runnable SSH and information-loss demonstrations for Paper 4
Copyright   : (c) Matthew Long, 2026
License     : MIT
Maintainer  : matthew@yonedaai.com
Stability   : experimental
-}
module Main (main) where

import Core
import Properties (runProperties)
import Proofs (runProofs)
import System.Exit (exitFailure, exitSuccess)

topologicalModel :: SSHModel
topologicalModel = SSHModel 0.5 1.0 0.0

trivialModel :: SSHModel
trivialModel = SSHModel 1.5 1.0 0.0

printEither :: Show value => Either String value -> IO ()
printEither result =
  case result of
    Left message -> putStrLn ("undefined: " ++ message)
    Right value -> print value

showModel :: String -> SSHModel -> IO ()
showModel label model = do
  putStrLn label
  putStrLn ("  k=0 spectrum: " ++ show (energies model 0.0))
  putStrLn ("  k=pi spectrum: " ++ show (energies model pi))
  putStrLn ("  full band gap: " ++ show (bandGap model))
  putStr "  analytic winding: "
  printEither (winding 1.0e-12 model)
  putStr "  numerical winding: "
  printEither (numericWinding 4096 1.0e-12 model)

showFlattening :: IO ()
showFlattening = do
  putStrLn "Spectral flattening at k=pi/2"
  printEither (flattenAt 1.0e-12 topologicalModel (pi / 2.0))
  putStrLn ("  flattened eigenvalues: " ++ show flattenedEnergies)

showRelativeClass :: IO ()
showRelativeClass = do
  putStrLn "Relative operator-class proxy"
  putStr "  topological minus trivial winding: "
  printEither (relativeWinding 1.0e-12 topologicalModel trivialModel)
  putStr "  local transition charge in the chosen orientation: "
  printEither (localTransitionCharge 4096)

showDetour :: IO ()
showDetour = do
  putStrLn "Chiral-symmetry-breaking detour"
  case symmetryBreakingDetour 64 1.0 0.5 of
    Left message -> putStrLn ("  undefined: " ++ message)
    Right path -> do
      putStrLn ("  sampled points: " ++ show (length path))
      putStrLn ("  minimum full gap: " ++ show (minimumBandGap path))
      putStrLn "  endpoints preserve chiral symmetry; interior points break it."

showInformationContract :: IO ()
showInformationContract = do
  let contract = spectralFlatteningContract
  putStrLn "Information-loss contract"
  putStrLn ("  retained: " ++ show (retainedData contract))
  putStrLn ("  discarded: " ++ show (discardedData contract))
  putStrLn ("  outside domain: " ++ show (outsideDomain contract))

showArrowAudit :: IO ()
showArrowAudit = do
  putStrLn "Three-arrow audit"
  mapM_ printArrow comparisonAudit
  where
    printArrow assessment =
      putStrLn
        ("  " ++ arrowName assessment ++ ": " ++ show (arrowStatus assessment)
          ++ "; assumptions=" ++ show (arrowAssumptions assessment))

main :: IO ()
main = do
  putStrLn "Microscopic lattice systems and effective-theory contracts"
  putStrLn ""
  showModel "Topological SSH sample" topologicalModel
  showModel "Trivial SSH sample" trivialModel
  putStrLn ""
  showFlattening
  putStrLn ""
  showRelativeClass
  putStrLn ""
  showDetour
  putStrLn ""
  showInformationContract
  putStrLn ""
  showArrowAudit
  putStrLn ""
  propertiesOk <- runProperties
  putStrLn ""
  proofsOk <- runProofs
  if propertiesOk && proofsOk
    then do
      putStrLn "All finite demonstrations and contract checks passed."
      exitSuccess
    else do
      putStrLn "A finite demonstration or contract check failed."
      exitFailure
