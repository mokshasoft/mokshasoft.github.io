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

import Color
import DataTypes exposing (..)
import Dict as D
import Gen.Data as Data
import Html
import LineChart
import LineChart.Dots as Dots
import List as L
import Maybe as M



-- FUNCTIONS


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
