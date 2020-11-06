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


type alias Analysis =
    { lines : List (LineChart.Series ChartInfo)
    }


type alias ChartInfo =
    { x : Float
    , y : Float
    }


type alias Selection =
    { country : String
    , year : Int
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


maxAnalysis : Selection -> Analysis
maxAnalysis s =
    let
        c =
            getCountry s.country

        year =
            selectYear s.year c

        trimYear =
            L.take (L.length year - 4) year

        minYear =
            selectYear 2019 c

        maxYear =
            selectYear 2002 c
    in
    Analysis
        [ LineChart.line Color.black Dots.diamond "2020" trimYear
        , LineChart.line Color.blue Dots.diamond "2019" minYear
        , LineChart.line Color.red Dots.diamond "2002" maxYear
        ]


chart : String -> Html.Html msg
chart country =
    let
        analysis =
            maxAnalysis (Selection country 2020)
    in
    LineChart.view .x .y analysis.lines


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
