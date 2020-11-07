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
import Gen.Population as Pop
import LineChart
import LineChart.Dots as Dots
import List as L



-- DATA TYPES


type alias Analysis =
    { lines : List (LineChart.Series ChartInfo)
    }


type alias ChartInfo =
    { x : Float
    , y : Float
    }



-- HELPER FUNCTIONS


{-| Mortality rate expressed in a population of 1000 individuals.

The input List should contain deaths/week.

-}
mortality : Int -> List ChartInfo -> List ChartInfo
mortality population cs =
    L.map (\ct -> { ct | y = 1000 * toFloat 52 * ct.y / toFloat population }) cs


{-| Transform data to ChartInfo
-}
toChartInfo : List Int -> List ChartInfo
toChartInfo ls =
    L.map2 (\i d -> ChartInfo (toFloat i) (toFloat d)) (L.range 1 (L.length ls)) ls


{-| Select a year from country data.
-}
getYearData : Int -> Country -> List ChartInfo
getYearData year country =
    let
        data : List Int
        data =
            case D.get year country.data of
                Nothing ->
                    []

                Just d ->
                    d.data

        pop : Int
        pop =
            Pop.getPopulation year country.name
    in
    mortality pop (toChartInfo data)


{-| Trim of i elements and the end of the ChartInfo.
-}
trimData : Int -> List ChartInfo -> List ChartInfo
trimData i ls =
    L.take (L.length ls - i) ls



-- ANALYSIS


{-| Display mortality in 2020 with highest mortality of 2000-2019.
-}
maxAnalysis : Selection -> Analysis
maxAnalysis s =
    let
        c : Country
        c =
            C.getCountry s.country

        year : List ChartInfo
        year =
            getYearData s.year c

        maxYear : List ChartInfo
        maxYear =
            getYearData 2002 c
    in
    Analysis
        [ LineChart.line Color.black Dots.diamond "2020" <| trimData 4 year
        , LineChart.line Color.red Dots.diamond "2002" maxYear
        ]
