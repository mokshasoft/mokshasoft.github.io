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
import Parser as R

defaultCountry :: String
defaultCountry =
  "Sweden"

data YearData = YearData
  { total :: Int
  , week  :: Map.HashMap Int Int
  }

data Country = Country
  { country :: String
  , year    :: Map.HashMap Int YearData
  }

instance Show YearData where
  show (YearData t w) = show t

instance Show Country where
  show (Country c y) = c ++ " " ++ show y

initYearData :: YearData
initYearData =
  YearData 0 Map.empty

initCountry :: String -> Country
initCountry name =
  Country name Map.empty

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

countYear :: YearData -> YearData
countYear yd =
  let
    m = (ElmWriter.week yd)
    count = F.sum m
  in YearData count m

-- Sweden 2000 1 111
-- Sweden 2000 2 112
-- Sweden 2000 3 113
toSwedishData' :: [R.Record] -> Country -> Country
toSwedishData' [] c = c
toSwedishData' (r:rs) c =
  let
    y = R.year r
    w = R.week r
    n = R.nbr r
    mNewW = Map.lookup y (ElmWriter.year c)
  in case mNewW of
        Nothing -> Country (ElmWriter.country c) (Map.insert y initYearData Map.empty)
        Just newW ->
          let
            yearData = YearData 0 (Map.insert w n (ElmWriter.week newW))
          in Country (ElmWriter.country c) (Map.insert y yearData (ElmWriter.year c))

toSwedishData :: [R.Record] -> Country
toSwedishData rs =
  toSwedishData' rs (initCountry defaultCountry)

-- Extract only Swedish data for now
records2Countries :: [R.Record] -> [Country]
records2Countries rs =
  let
    se = L.filter (\r -> R.country r == defaultCountry) rs
  in [toSwedishData se]

record2ElmData :: [R.Record] -> IO ()
record2ElmData rs = do
  putStrLn genHeader
  putStrLn $ genCountriesFunctions "seCountry" ["seContry", "dkCountry"]
  putStrLn $ show $ records2Countries rs
