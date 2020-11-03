module Lines exposing (chart)

import Color
import Dict as D
import Html
import LineChart
import LineChart.Dots as Dots
import List as L


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
                    d.data.nbr
    in
    L.map (\d -> ChartInfo (toFloat d) (toFloat (d * d))) data


chart : Html.Html msg
chart =
    let
        ctry =
            seCountry

        data =
            selectYear 2000 ctry
    in
    LineChart.view .x
        .y
        [ LineChart.line Color.red Dots.diamond ctry.name data
        ]



-- DATA


type alias YearData =
    { nbr : List Int
    }


type alias Year =
    { total : Int
    , data : YearData
    }


type alias Country =
    { name : String
    , data : D.Dict Int Year
    }


type alias ChartInfo =
    { x : Float
    , y : Float
    }


seYD : YearData
seYD =
    YearData (L.range 1 53)


seY : D.Dict Int Year
seY =
    D.fromList
        [ ( 2000, Year 1234 seYD )
        , ( 2000, Year 2234 seYD )
        , ( 2000, Year 3234 seYD )
        , ( 2000, Year 4234 seYD )
        ]


seCountry : Country
seCountry =
    Country "Sweden" seY
