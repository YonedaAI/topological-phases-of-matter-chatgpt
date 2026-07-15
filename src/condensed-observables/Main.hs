{-# OPTIONS_GHC -Wall -Wextra -Werror #-}

module Main
  ( Matrix2 (..)
  , adjoint
  , multiply
  , isHermitian
  , isPositiveSemidefinite
  , stateExpectation
  , hermitianSpectralNorm
  , supNorm
  , binaryValue
  , clopenApproximation
  , clopenErrorBound
  , main
  ) where

import Data.Complex (Complex ((:+)), conjugate, imagPart, magnitude, realPart)
import Text.Printf (printf)

data Matrix2 = Matrix2
  { entry11 :: Complex Double
  , entry12 :: Complex Double
  , entry21 :: Complex Double
  , entry22 :: Complex Double
  }
  deriving (Eq, Show)

epsilon :: Double
epsilon = 1.0e-10

adjoint :: Matrix2 -> Matrix2
adjoint matrix =
  Matrix2
    { entry11 = conjugate (entry11 matrix)
    , entry12 = conjugate (entry21 matrix)
    , entry21 = conjugate (entry12 matrix)
    , entry22 = conjugate (entry22 matrix)
    }

multiply :: Matrix2 -> Matrix2 -> Matrix2
multiply left right =
  Matrix2
    { entry11 = entry11 left * entry11 right + entry12 left * entry21 right
    , entry12 = entry11 left * entry12 right + entry12 left * entry22 right
    , entry21 = entry21 left * entry11 right + entry22 left * entry21 right
    , entry22 = entry21 left * entry12 right + entry22 left * entry22 right
    }

approximatelyEqual :: Complex Double -> Complex Double -> Bool
approximatelyEqual left right = magnitude (left - right) <= epsilon

isHermitian :: Matrix2 -> Bool
isHermitian matrix =
  and
    [ approximatelyEqual (entry11 matrix) (conjugate (entry11 matrix))
    , approximatelyEqual (entry22 matrix) (conjugate (entry22 matrix))
    , approximatelyEqual (entry12 matrix) (conjugate (entry21 matrix))
    ]

determinantReal :: Matrix2 -> Double
determinantReal matrix =
  realPart (entry11 matrix * entry22 matrix - entry12 matrix * entry21 matrix)

isPositiveSemidefinite :: Matrix2 -> Bool
isPositiveSemidefinite matrix =
  isHermitian matrix
    && abs (imagPart (entry11 matrix)) <= epsilon
    && abs (imagPart (entry22 matrix)) <= epsilon
    && realPart (entry11 matrix) >= (-epsilon)
    && realPart (entry22 matrix) >= (-epsilon)
    && determinantReal matrix >= (-epsilon)

traceMatrix :: Matrix2 -> Complex Double
traceMatrix matrix = entry11 matrix + entry22 matrix

stateExpectation :: Matrix2 -> Matrix2 -> Complex Double
stateExpectation density observable = traceMatrix (multiply density observable)

hermitianEigenvalues :: Matrix2 -> (Double, Double)
hermitianEigenvalues matrix =
  let a = realPart (entry11 matrix)
      d = realPart (entry22 matrix)
      bMagnitude = magnitude (entry12 matrix)
      bSquared = bMagnitude * bMagnitude
      center = (a + d) / 2
      halfDifference = (a - d) / 2
      radius = sqrt (halfDifference * halfDifference + bSquared)
   in (center - radius, center + radius)

-- | Return the spectral norm of a Hermitian matrix.
-- Non-Hermitian input is outside this function's domain and raises an error.
hermitianSpectralNorm :: Matrix2 -> Double
hermitianSpectralNorm matrix
  | not (isHermitian matrix) = error "hermitianSpectralNorm requires a Hermitian matrix"
  | otherwise =
      let (lower, upper) = hermitianEigenvalues matrix
       in max (abs lower) (abs upper)

-- | Return the supremum norm of a finite Hermitian family.
-- Every matrix in a nonempty input family must be Hermitian.
supNorm :: [Matrix2] -> Double
supNorm [] = 0
supNorm matrices = maximum (map hermitianSpectralNorm matrices)

-- | Evaluate a finite binary prefix as a real number in the unit interval.
-- This strict sum is intended for finite lists and is not productive on an
-- infinite list.
binaryValue :: [Bool] -> Double
binaryValue bits =
  sum
    [ if bit then 2 ** (negate (fromIntegral index :: Double)) else 0
    | (index, bit) <- zip [1 :: Int ..] bits
    ]

clopenApproximation :: Int -> [Bool] -> Double
clopenApproximation prefixLength = binaryValue . take prefixLength

clopenErrorBound :: Int -> Double
clopenErrorBound prefixLength = 2 ** (negate (fromIntegral prefixLength :: Double))

assertCheck :: String -> Bool -> IO ()
assertCheck label condition =
  if condition
    then putStrLn ("PASS: " ++ label)
    else error ("FAIL: " ++ label)

main :: IO ()
main = do
  let zero = 0 :+ 0
      one = 1 :+ 0
      half = 0.5 :+ 0
      pauliX = Matrix2 zero one one zero
      positive = Matrix2 one half half one
      nonPositive = Matrix2 zero one one zero
      density = Matrix2 (0.75 :+ 0) zero zero (0.25 :+ 0)
      observable = Matrix2 (2 :+ 0) zero zero ((-1) :+ 0)
      family = [pauliX, positive, observable]
      complexMatrix = Matrix2 (1 :+ 2) (3 :+ 4) (5 :+ 6) (7 :+ 8)
      expectedAdjoint = Matrix2 (1 :+ (-2)) (5 :+ (-6)) (3 :+ (-4)) (7 :+ (-8))
      leftFactor = Matrix2 (1 :+ 1) (2 :+ 0) (0 :+ 3) ((-1) :+ 0)
      rightFactor = Matrix2 (2 :+ 0) (0 :+ (-1)) (1 :+ 1) (0.5 :+ 0)
      expectedProduct = Matrix2 (4 :+ 4) (2 :+ (-1)) ((-1) :+ 5) (2.5 :+ 0)
      cantorPoint = cycle [True, False, True, True, False]
      prefixLength = 12
      approximation = clopenApproximation prefixLength cantorPoint
      longerApproximation = clopenApproximation 40 cantorPoint
      errorValue = abs (longerApproximation - approximation)
  assertCheck "adjoint is an involution" (adjoint (adjoint pauliX) == pauliX)
  assertCheck
    "adjoint conjugates and transposes complex entries"
    (adjoint complexMatrix == expectedAdjoint)
  assertCheck
    "matrix multiplication includes off-diagonal cross terms"
    (multiply leftFactor rightFactor == expectedProduct)
  assertCheck "positive test accepts a positive matrix" (isPositiveSemidefinite positive)
  assertCheck "positive test rejects Pauli X" (not (isPositiveSemidefinite nonPositive))
  assertCheck
    "density matrix gives the expected state evaluation"
    (approximatelyEqual (stateExpectation density observable) (1.25 :+ 0))
  assertCheck
    "finite-family sup norm is the maximum fiber norm"
    (abs (supNorm family - 2.0) <= epsilon)
  assertCheck
    "clopen prefix approximation obeys its tail bound"
    (errorValue <= clopenErrorBound prefixLength + epsilon)
  printf "state expectation = %.6f\n" (realPart (stateExpectation density observable))
  printf "finite-family sup norm = %.6f\n" (supNorm family)
  printf "clopen approximation error = %.12f\n" errorValue
