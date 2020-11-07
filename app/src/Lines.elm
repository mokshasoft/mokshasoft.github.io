{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lines exposing (chart)

import Analysis as A
import Html
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line



-- DATA TYPES


type alias Selection =
    { country : String
    , year : Int
    }



-- FUNCTIONS


chart : String -> Html.Html msg
chart country =
    let
        analysis : A.Analysis
        analysis =
            A.maxAnalysis (Selection country 2020)
    in
    LineChart.viewCustom
        { x = Axis.full 1000 "Week" .x
        , y = Axis.full 500 "Mortality" .y
        , container = Container.default "line-chart-1"
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        analysis.lines
