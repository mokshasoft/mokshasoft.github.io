{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Analysis exposing
    ( Analysis
    , ChartInfo
    , maxAnalysis
    )

import Color
import Country as C
import DataTypes exposing (..)
import Dict as D
import Gen.Data as Data
import Gen.Population as Pop
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



-- FUNCTIONS


mortality : List ChartInfo -> Int -> List ChartInfo
mortality cs population =
    L.map (\ct -> { ct | y = 1000 * toFloat 52 * ct.y / toFloat population }) cs


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
            C.getCountry s.country

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
        [ LineChart.line Color.black Dots.diamond "2020" <| mortality trimYear 10327589
        , LineChart.line Color.red Dots.diamond "2002" <| mortality maxYear 8940788
        ]
