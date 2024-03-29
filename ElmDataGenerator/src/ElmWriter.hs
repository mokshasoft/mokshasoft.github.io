{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module ElmWriter
    ( record2ElmData
    ) where

import           Data.Foldable       as F
import           Data.HashMap.Strict as Map
import           Data.List           as L
import           Data.List.Extra     as LE
import           Data.Maybe          as M
import           Parser              as R

defaultCountry :: String
defaultCountry =
  "Sweden"

type Weeks = Map.HashMap Int Int
type Years = Map.HashMap Int Weeks
type Countries = Map.HashMap String Years

year2String :: (Int, Weeks) -> String
year2String (y, w) =
  let
    nbrs = L.map snd $ L.sortOn fst $ Map.toList w
    nbrsStr = L.concat $ L.intersperse ", " $ L.map show nbrs
    total = L.sum nbrs
  in if total /= 0
    then "( " ++ show y ++ ", Year " ++ show total ++ " [ " ++ nbrsStr ++ " ] )"
    else ""

countryNameVariable :: String -> String
countryNameVariable name =
  L.takeWhile (/= '(') $ "data" ++ (L.filter (/= ' ') name)

country2String :: (String, Years) -> String
country2String (name, y) =
  let
    funcName = countryNameVariable name
    list = L.concat $ L.intersperse "\n            , " $ L.filter (/= "") $ L.map year2String $ L.sortOn fst $ Map.toList y
  in
  funcName ++ " : Country\n" ++
  funcName ++ " =\n" ++
  "    Country \"" ++ (LE.trim $ L.takeWhile (/= '(') name) ++ "\" <|\n" ++
  "        D.fromList\n" ++
  "            [ " ++ list ++ "\n" ++
  "            ]"

countries2String :: Countries -> String
countries2String c =
  L.concat $ L.intersperse "\n\n\n" $ L.map country2String $ Map.toList c

genHeader :: String
genHeader =
  "{-\n\
  \   Copyright 2020, Mokshasoft AB (mokshasoft.com)\n\
  \\n\
  \   This software may be distributed and modified according to the terms of\n\
  \   the GNU General Public License v3.0. Note that NO WARRANTY is provided.\n\
  \   See \"LICENSE\" for details.\n\
  \-}\n\
  \\n\
  \\n\
  \module Gen.Data exposing (countries, defaultCountry)\n\
  \\n\
  \import DataTypes exposing (..)\n\
  \import Dict as D\n\n\n"

genCountryList :: [String] -> String
genCountryList countries =
  "    [ " ++  (L.concat $ L.intersperse "\n    , " countries) ++ "\n" ++
  "    ]\n\n\n"

genCountriesFunctions :: String -> [String] -> String
genCountriesFunctions def countries =
  "defaultCountry : Country\n\
  \defaultCountry =\n    " ++ def ++ "\n\n\n" ++
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

insertRecordCountry :: Countries -> R.Record -> Countries
insertRecordCountry c r =
  let
    rCountry = R.country r
    rYear = R.year r
    year = M.fromMaybe Map.empty $ Map.lookup rCountry c
    newYear = insertRecordYear year r
  in Map.insert rCountry newYear c

records2Countries :: [R.Record] -> Countries
records2Countries rs =
  L.foldl insertRecordCountry Map.empty rs

record2String :: [R.Record] -> String
record2String rs =
  let
    countries = records2Countries rs
  in genHeader ++
     (genCountriesFunctions "dataGermany" $ L.map (\c -> countryNameVariable c) $ Map.keys countries) ++
     countries2String countries

record2ElmData :: FilePath -> [R.Record] -> IO ()
record2ElmData file rs =
  writeFile file $ record2String rs

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
