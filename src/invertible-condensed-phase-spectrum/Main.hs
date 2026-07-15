module Main (main) where

import ContractChecks
import Properties
import System.Exit (exitFailure, exitSuccess)

renderResult :: String -> Bool -> String
renderResult name passed =
  (if passed then "PASS: " else "FAIL: ") ++ name

runProperties :: IO [Bool]
runProperties =
  mapM run propertyChecks
  where
    run check = do
      putStrLn (renderResult (propertyName check) (propertyPassed check))
      pure (propertyPassed check)

runContractChecks :: IO [Bool]
runContractChecks =
  mapM run contractChecks
  where
    run check = do
      putStrLn
        ( renderResult
            (contractCheckName check)
            (contractCheckPassed check)
        )
      pure (contractCheckPassed check)

main :: IO ()
main = do
  putStrLn "Synthesis status validator"
  propertyResults <- runProperties
  contractResults <- runContractChecks
  let results = propertyResults ++ contractResults
  let passed = length (filter id results)
  let total = length results
  putStrLn ("Checks passed: " ++ show passed ++ "/" ++ show total)
  if and results then exitSuccess else exitFailure
