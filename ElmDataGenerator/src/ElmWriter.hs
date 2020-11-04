{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module ElmWriter
    ( record2ElmData
    ) where

import Data.Array as A
import Data.HashMap.Strict as Map
import Data.List as L
import Parser as R

data YearData = YearData
  { total :: Int
  , week  :: Array Int Int
  }

data Country = Country
  { country :: String
  , year    :: Map.HashMap Int YearData
  }

instance Show YearData where
  show (YearData t w) = show t

instance Show Country where
  show (Country c y) = c ++ " " ++ show y

{-
type alias YearData =
    { nbr : List Int
    }


type alias Year =
    { total : Int
    , data : YearData
    }


type alias Country =
    { name : String
    , data : D.Dict Int Year
    }
-}

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

-- Sweden 2000 1 111
-- Sweden 2000 2 112
-- Sweden 2000 3 113
toSwedishData :: [R.Record] -> Country
toSwedishData rs = undefined

-- Extract only Swedish data for now
records2Countries :: [R.Record] -> [Country]
records2Countries rs =
  let
    se = L.filter (\r -> R.country r == "Sweden") rs
  in [toSwedishData se]

record2ElmData :: [R.Record] -> IO ()
record2ElmData rs = do
  putStrLn genHeader
  putStrLn $ genCountriesFunctions "seCountry" ["seContry", "dkCountry"]
  putStrLn $ show $ records2Countries rs
