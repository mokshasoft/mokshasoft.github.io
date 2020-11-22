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
    , getAllAnalysis
    , getAnalysis
    )

import Country as C
import DataTypes exposing (..)
import Dict as D
import Gen.Population as Pop
import LineChart
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import List as L
import ListExtra as LE
import Maybe as M
import String as S
import Tuple as T



-- DATA TYPES


type Analysis
    = MaxYear
    | MaxWeekly
    | AllYears
    | AllWeeks
    | Yearly


type alias GraphData =
    { captionX : String
    , description : String
    , warning : Bool
    , lines : List (LineChart.Series ChartInfo)
    }


type alias ChartInfo =
    { x : Float
    , y : Float
    }



-- HELPER FUNCTIONS


getAllAnalysis : List String
getAllAnalysis =
    [ "Year with highest mortality rate compared to 2020"
    , "Year with highest weekly mortality rate compared to 2020"
    , "Show data for all available years 2000-2020"
    , "Show data for all available weeks 2000-2020"
    , "Show how mortality has changed from 2000-2020"
    ]


getAnalysis : String -> Analysis
getAnalysis a =
    case a of
        "Year with highest mortality rate compared to 2020" ->
            MaxYear

        "Year with highest weekly mortality rate compared to 2020" ->
            MaxWeekly

        "Show data for all available years 2000-2020" ->
            AllYears

        "Show data for all available weeks 2000-2020" ->
            AllWeeks

        "Show how mortality has changed from 2000-2020" ->
            Yearly

        _ ->
            MaxYear


analysis : String -> Analysis -> GraphData
analysis country analysisType =
    case analysisType of
        MaxYear ->
            maxAnalysis country

        MaxWeekly ->
            maxWeeklyAnalysis country

        AllYears ->
            allYearsAnalysis country

        AllWeeks ->
            allWeeksAnalysis country

        Yearly ->
            yearlyAnalysis country


{-| Mortality rate expressed in a population of 1000 individuals.

The input List should contain deaths/week.

-}
mortalityWeekly : Int -> List ChartInfo -> List ChartInfo
mortalityWeekly population cs =
    L.map (\ct -> { ct | y = 1000 * 52.143 * ct.y / toFloat population }) cs


mortalityYearly : List Int -> List ChartInfo -> List ChartInfo
mortalityYearly ps cs =
    L.map2 (\p c -> { c | y = 1000 * c.y / toFloat p }) ps cs


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
    mortalityWeekly pop (toChartInfo data)


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


getDeadliestPeakYear : Country -> Int
getDeadliestPeakYear country =
    let
        cmp : ( Int, Year ) -> ( Int, Int ) -> ( Int, Int )
        cmp ( year, yearData ) ( prevYear, prevMax ) =
            let
                max : Int
                max =
                    M.withDefault 0 <| L.maximum yearData.data
            in
            if max > prevMax then
                ( year, max )

            else
                ( prevYear, prevMax )

        list : List ( Int, Year )
        list =
            D.toList <| D.remove 2020 country.data

        folded : ( Int, Int )
        folded =
            L.foldl cmp ( 0, 0 ) list
    in
    T.first folded


getYearlyData : Country -> List ChartInfo
getYearlyData country =
    let
        transform : ( Int, Year ) -> ChartInfo
        transform ( year, yearData ) =
            ChartInfo (toFloat year) (toFloat yearData.total)

        pop : List Int
        pop =
            Pop.getPopulationList country.name

        year2020 : Year
        year2020 =
            M.withDefault (Year 0 []) <| D.get 2020 country.data

        chart : List ChartInfo
        chart =
            L.map transform <| D.toList country.data

        last : ChartInfo
        last =
            M.withDefault (ChartInfo 0 0) <| L.head <| L.reverse chart
    in
    mortalityYearly pop <| L.append (LE.dropRight 1 chart) [ ChartInfo last.x (estimate2020 year2020) ]


estimate2020 : Year -> Float
estimate2020 year =
    let
        len : Int
        len =
            L.length year.data

        l20 : List Int
        l20 =
            L.take (len - 20) year.data

        avg20 : Float
        avg20 =
            toFloat (L.sum l20) / toFloat (L.length l20)
    in
    toFloat year.total + toFloat (52 - len) * avg20



-- ANALYSIS


warnAboutDataSize : Country -> ( String, Bool )
warnAboutDataSize c =
    let
        samples : Int
        samples =
            L.length <| LE.dropWhile (\ci -> ci.y == 0) <| getYearlyData c
    in
    if samples < 10 then
        ( "Warning: the dataset only contains data from " ++ S.fromInt samples ++ " years!"
        , True
        )

    else
        ( "The dataset contains data from " ++ S.fromInt samples ++ " years."
        , False
        )


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

        ( caption, warning ) =
            warnAboutDataSize c
    in
    GraphData "Week number"
        caption
        warning
        [ LineChart.line Colors.blue Dots.circle "2020" year
        , LineChart.line Colors.rust Dots.circle (S.fromInt deadliestYear) deadliestYearData
        ]


maxWeeklyAnalysis : String -> GraphData
maxWeeklyAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        year : List ChartInfo
        year =
            getYearData 2020 c

        deadliestPeakYear : Int
        deadliestPeakYear =
            getDeadliestPeakYear c

        comparedYearData : List ChartInfo
        comparedYearData =
            getYearData deadliestPeakYear c

        ( caption, warning ) =
            warnAboutDataSize c
    in
    GraphData "Week number"
        caption
        warning
        [ LineChart.line Colors.blue Dots.circle "2020" year
        , LineChart.line Colors.gold Dots.circle (S.fromInt deadliestPeakYear) comparedYearData
        ]


allYearsAnalysis : String -> GraphData
allYearsAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        year : List ChartInfo
        year =
            getYearData 2020 c

        allBut2020 : Country
        allBut2020 =
            Country c.name <| D.remove 2020 c.data

        allYearsData : List (List ChartInfo)
        allYearsData =
            L.map (\y -> getYearData y allBut2020) <| D.keys allBut2020.data

        ( caption, warning ) =
            warnAboutDataSize c
    in
    GraphData "Week number"
        (caption ++ " (2020 is the blue line)")
        warning
    <|
        L.append
            (L.map (\d -> LineChart.line Colors.gold Dots.circle "" d) allYearsData)
            [ LineChart.line Colors.blue Dots.circle "2020" year ]


allWeeksAnalysis : String -> GraphData
allWeeksAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        allYearsData : List ChartInfo
        allYearsData =
            L.concat <| L.map (\y -> getYearData y c) <| D.keys c.data

        earliestYear : Float
        earliestYear =
            toFloat <| M.withDefault 2000 <| L.head <| D.keys c.data

        allWeeksData : List ChartInfo
        allWeeksData =
            L.map2 (\ci idx -> ChartInfo (earliestYear + toFloat idx / 52.143) ci.y) allYearsData (L.range 1 (L.length allYearsData))

        ( caption, warning ) =
            warnAboutDataSize c
    in
    GraphData "Year"
        caption
        warning
        [ LineChart.line Colors.gold Dots.circle "" allWeeksData ]


yearlyAnalysis : String -> GraphData
yearlyAnalysis country =
    let
        c : Country
        c =
            C.getCountry country

        yearly : List ChartInfo
        yearly =
            getYearlyData c

        ( caption, warning ) =
            warnAboutDataSize c
    in
    GraphData "Year"
        (caption ++ " The numbers for 2020 is an estimation using the average of the 20 last weeks.")
        warning
        [ LineChart.line Colors.cyan Dots.circle "2020" <| LE.dropWhile (\ci -> ci.y == 0) yearly
        ]
