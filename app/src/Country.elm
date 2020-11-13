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


{-| Make yearly data max 52 weeks long and remove everything after a zero value
-}
filterCountryData : Country -> Country
filterCountryData country =
    let
        transformer : Int -> Year -> D.Dict Int Year -> D.Dict Int Year
        transformer year yearData dict =
            let
                d : List Int
                d =
                    L.take 52 <| dropTrailingZeros yearData.data

                dd : List Int
                dd =
                    if L.length d < 52 then
                        -- The last samples in 2020 is probably not correct enough, drop two
                        LE.dropRight 2 d

                    else
                        d
            in
            D.insert year (Year yearData.total dd) dict

        dataDict : D.Dict Int Year
        dataDict =
            D.foldl transformer D.empty country.data
    in
    Country country.name dataDict


getCountry : String -> Country
getCountry country =
    filterCountryData <| M.withDefault Data.defaultCountry (D.get country countryDict)
