{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lines exposing (chart)

import Analysis as A
import Html exposing (..)
import Html.Attributes exposing (..)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import List as L



-- FUNCTIONS


specialRange : Coordinate.Range -> Coordinate.Range
specialRange { min, max } =
    { min = 0, max = max * 1.1 }


chart : String -> A.Analysis -> Bool -> Html.Html msg
chart country analysisType fullRange =
    let
        analysis : A.GraphData
        analysis =
            A.analysis country analysisType

        legendConfig : Legends.Config A.ChartInfo msg
        legendConfig =
            if L.length analysis.lines > 7 then
                Legends.none

            else
                Legends.default
    in
    div []
        [ p [ class "mt-3" ]
            [ text "General mortality rate per year per 1000 individuals" ]
        , LineChart.viewCustom
            { x = Axis.full 1000 analysis.captionX .x
            , y =
                Axis.custom
                    { title = Title.default "Mort. rate"
                    , variable = Just << .y
                    , pixels = 500
                    , range =
                        if fullRange then
                            Range.custom specialRange

                        else
                            Range.default
                    , axisLine = AxisLine.default
                    , ticks = Ticks.float 1
                    }
            , container = Container.responsive "line-chart-1"
            , interpolation = Interpolation.monotone
            , intersection = Intersection.default
            , legends = legendConfig
            , events = Events.default
            , junk = Junk.default
            , grid = Grid.default
            , area = Area.default
            , line = Line.wider 2
            , dots = Dots.custom (Dots.empty 5 1)
            }
            analysis.lines
        , p
            [ class "text-center"
            , if analysis.warning then
                style "color" "#cc3300"

              else
                style "color" "black"
            ]
            [ text analysis.description ]
        ]
