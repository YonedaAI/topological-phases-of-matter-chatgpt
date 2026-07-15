module Main (main) where

import Realizability
  ( RealizationEntry (entryName, realizationStatus)
  , RelativeInput (..)
  , akltEntry
  , bdiEntry
  , classDEntry
  , entryContractValid
  , openBordismEntry
  , registry
  , relativeCharge
  , validateRegistry
  )

main :: IO ()
main = do
  putStrLn "Physical realizability registry"
  mapM_ printEntry [classDEntry, bdiEntry, akltEntry, openBordismEntry]
  putStrLn ("registry errors: " ++ show (validateRegistry registry))
  putStrLn ("localized relative charge: " ++ show (relativeCharge localizedInput))
  putStrLn ("extension case: " ++ show (relativeCharge extensionInput))
  where
    localizedInput =
      RelativeInput
        { sourceDegree = 1
        , normalCodimension = 2
        , invariantExists = True
        , invariantRestrictsFromBase = False
        , excisionHypothesesHold = True
        , normalBundleIsOriented = True
        }
    extensionInput =
      RelativeInput
        { sourceDegree = 1
        , normalCodimension = 2
        , invariantExists = True
        , invariantRestrictsFromBase = True
        , excisionHypothesesHold = True
        , normalBundleIsOriented = True
        }

printEntry :: RealizationEntry -> IO ()
printEntry entry =
  putStrLn
    ( "- "
        ++ entryName entry
        ++ ": status="
        ++ show (realizationStatus entry)
        ++ ", contract-valid="
        ++ show (entryContractValid entry)
    )
