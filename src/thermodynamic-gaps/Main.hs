{-|
Module      : Main
Description : Executable demonstrations for thermodynamic gap conventions.
License     : MIT
-}
module Main (main) where

import Core
import Properties
import System.Exit (exitFailure, exitSuccess)

showGap :: Maybe Gap -> String
showGap Nothing = "undefined"
showGap (Just gap) = show (unGap gap)

printProperty :: PropertyResult -> IO ()
printProperty result =
  putStrLn
    ( (if propertyPassed result then "PASS: " else "FAIL: ")
      ++ propertyName result
    )

main :: IO ()
main = do
  putStrLn "Thermodynamic spectral-gap demonstrations"
  putStrLn ""
  putStrLn ("Literal gap of [0,0,0.25,1]: " ++ showGap (literalGroundGap [0, 0, 0.25, 1]))
  putStrLn ("Band gap below cutoff 0.1: " ++ showGap (selectedBandGap 0.1 [0, 0.01, 0.8, 1]))
  putStrLn ("Two-level gap at s=0.5: " ++ showGap (twoLevelGap 0.5))
  putStrLn ("Ferromagnetic upper bound at L=64: " ++ showGap (ferromagnetUpperBound 64))
  putStrLn ""
  mapM_ printProperty runProperties
  let passed = all propertyPassed runProperties
  putStrLn ""
  if passed
    then putStrLn "All finite computational checks passed." >> exitSuccess
    else putStrLn "At least one computational check failed." >> exitFailure
