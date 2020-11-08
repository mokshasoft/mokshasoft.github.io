{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Country exposing
    ( getCountries
    , getCountry
    )

import DataTypes exposing (..)
import Dict as D
import Gen.Data as Data
import List as L
import ListExtra as LE
import Maybe as M



-- FUNCTIONS


dropTrailingZeros : List Int -> List Int
dropTrailingZeros ls =
    LE.takeWhile (\p -> p /= 0) ls


getCountries : List String
getCountries =
    D.keys countryDict


countryDict : D.Dict String Country
countryDict =
    D.fromList
        (L.map (\c -> ( c.name, c )) Data.countries)


getCountry : String -> Country
getCountry country =
    M.withDefault Data.defaultCountry (D.get country countryDict)
