{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Analysis exposing
    ( Analysis(..)
    , ChartInfo
    , GraphData
    , analysis
    )

import Color
import Country as C
import DataTypes exposing (..)
import Dict as D
import Gen.Population as Pop
import LineChart
import LineChart.Dots as Dots
import List as L
import String as S
import Tuple as T



-- DATA TYPES


type Analysis
    = MaxYear
    | MaxWeekly
    | Yearly


type alias GraphData =
    { lines : List (LineChart.Series ChartInfo)
    }


type alias ChartInfo =
    { x : Float
    , y : Float
    }



-- HELPER FUNCTIONS


analysis : String -> Analysis -> GraphData
analysis country analysisType =
    case analysisType of
        MaxYear ->
            maxAnalysis country

        MaxWeekly ->
            maxWeeklyAnalysis country

        Yearly ->
            yearlyAnalysis country


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


getDeadliestYear : Country -> Int
getDeadliestYear country =
    let
        cmp : Int -> Year -> ( Int, Int ) -> ( Int, Int )
        cmp year yearData ( y, maxTotal ) =
            if yearData.total > maxTotal then
                ( year, yearData.total )

            else
                ( y, maxTotal )
    in
    T.first <| D.foldl cmp ( 0, 0 ) country.data


getYearlyData : Country -> List ChartInfo
getYearlyData country =
    let
        transform : ( Int, Year ) -> ChartInfo
        transform ( year, yearData ) =
            ChartInfo (toFloat year) (toFloat yearData.total)
    in
    L.map transform <| D.toList country.data


{-| Trim of i elements and the end of the ChartInfo.
-}
trimData : Int -> List ChartInfo -> List ChartInfo
trimData i ls =
    L.take (L.length ls - i) ls


{-| Take elements from a list until the predicate is true.
-}
takeWhile : (a -> Bool) -> List a -> List a
takeWhile p ls =
    case ls of
        h :: rest ->
            if p h then
                h :: takeWhile p rest

            else
                []

        [] ->
            []


dropTrailingZeros : List ChartInfo -> List ChartInfo
dropTrailingZeros ls =
    takeWhile (\p -> p.y /= 0) ls



-- ANALYSIS


{-| Display mortality in 2020 with highest mortality of 2000-2019.
-}
maxAnalysis : String -> GraphData
maxAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        year : List ChartInfo
        year =
            getYearData 2020 c

        deadliestYear : Int
        deadliestYear =
            getDeadliestYear c

        deadliestYearData : List ChartInfo
        deadliestYearData =
            getYearData deadliestYear c
    in
    GraphData
        [ LineChart.line Color.black Dots.diamond "2020" <| trimData 4 <| L.take 52 year
        , LineChart.line Color.red Dots.diamond (S.fromInt deadliestYear) <| L.take 52 deadliestYearData
        ]


maxWeeklyAnalysis : String -> GraphData
maxWeeklyAnalysis country =
    GraphData []


yearlyAnalysis : String -> GraphData
yearlyAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        yearly : List ChartInfo
        yearly =
            getYearlyData c
    in
    GraphData
        [ LineChart.line Color.black Dots.diamond "2020" yearly
        ]
