{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module ElmWriter
    ( record2ElmData
    ) where

import Data.Foldable as F
import Data.HashMap.Strict as Map
import Data.List as L
import Data.Maybe as M
import Parser as R

defaultCountry :: String
defaultCountry =
  "Sweden"

type Weeks = Map.HashMap Int Int
type Years = Map.HashMap Int Weeks
type Countries = Map.HashMap String Years

genHeader :: String
genHeader =
  "{-\n\
  \    Copyright 2020, Mokshasoft AB (mokshasoft.com)\n\
  \\n\
  \    This software may be distributed and modified according to the terms of\n\
  \    the GNU General Public License v3.0. Note that NO WARRANTY is provided.\n\
  \    See \"LICENSE\" for details.\n\
  \-}\n\
  \\n\
  \\n\
  \module Gen.Data exposing (countries, defaultCountry)\n\
  \\n\
  \import DataTypes exposing (..)\n\
  \import Dict as D\n\
  \import List as L\n"

genCountryList :: [String] -> String
genCountryList countries = 
  "[ seCountry\n\
   \, dkCountry\n\
   \]\n\n\n"

genCountriesFunctions :: String -> [String] -> String
genCountriesFunctions def countries =
  "defaultCountry : Country\n\
  \defaultCountry =\n" ++ def ++ "\n\n\n" ++
  "countries : List Country\n\
  \countries =\n" ++ genCountryList countries

sumYear :: Weeks -> Int
sumYear ws =
  F.sum ws

insertRecordYear :: Years -> R.Record -> Years
insertRecordYear y r =
  let
    rYear = R.year r
    rWeek = R.week r
    nbr = R.nbr r
    newWeek = M.fromMaybe Map.empty $ Map.lookup rYear y
  in Map.insert rYear (Map.insert rWeek nbr newWeek) y

records2Years :: [R.Record] -> Years
records2Years rs =
  L.foldl insertRecordYear Map.empty rs

records2Countries :: [R.Record] -> Countries
records2Countries rs =
  let
    -- Extract only Swedish data for now
    se = L.filter (\r -> R.country r == defaultCountry) rs
    years = records2Years se
  in Map.insert defaultCountry years Map.empty

record2ElmData :: [R.Record] -> IO ()
record2ElmData rs = do
  putStrLn genHeader
  putStrLn $ genCountriesFunctions "seCountry" ["seContry", "dkCountry"]
  putStrLn $ show $ records2Countries rs

-- Test data
testData :: [R.Record]
testData =
  [ R.Record "Sweden" 2000 1 100 ""
  , R.Record "Sweden" 2000 2 101 ""
  , R.Record "Sweden" 2000 3 102 ""
  , R.Record "Sweden" 2000 4 103 ""
  , R.Record "Sweden" 2001 1 200 ""
  , R.Record "Sweden" 2001 2 201 ""
  , R.Record "Sweden" 2001 3 202 ""
  , R.Record "Sweden" 2001 4 203 ""
  , R.Record "Denmark" 2000 1 100 ""
  , R.Record "Denmark" 2000 2 101 ""
  , R.Record "Denmark" 2000 3 102 ""
  , R.Record "Denmark" 2000 4 103 ""
  , R.Record "Denmark" 2001 1 200 ""
  , R.Record "Denmark" 2001 2 201 ""
  , R.Record "Denmark" 2001 3 202 ""
  , R.Record "Denmark" 2001 4 203 ""
  ]
