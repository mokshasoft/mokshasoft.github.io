{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lines exposing (chart, getCountries)

import Color
import DataTypes exposing (..)
import Dict as D
import Gen.Data as Data
import Html
import LineChart
import LineChart.Dots as Dots
import List as L
import Maybe as M



-- DATA TYPES


type alias ChartInfo =
    { x : Float
    , y : Float
    }



-- FUNCTIONS


selectYear : Int -> Country -> List ChartInfo
selectYear year country =
    let
        yearDataM =
            D.get year country.data

        data =
            case yearDataM of
                Nothing ->
                    []

                Just d ->
                    d.data
    in
    L.map2 (\i d -> ChartInfo (toFloat i) (toFloat d)) (L.range 1 (L.length data)) data


chart : String -> Html.Html msg
chart country =
    let
        c =
            getCountry country

        data =
            selectYear 2020 c
    in
    LineChart.view .x
        .y
        [ LineChart.line Color.red Dots.diamond c.name data
        ]


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
