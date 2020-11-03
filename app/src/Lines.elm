{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lines exposing (Country, chart, getCountries)

import Color
import Dict as D
import Html
import LineChart
import LineChart.Dots as Dots
import List as L
import Maybe as M


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


chart : String -> Html.Html msg
chart country =
    let
        c =
            getCountry country

        data =
            selectYear 2000 c
    in
    LineChart.view .x
        .y
        [ LineChart.line Color.red Dots.diamond c.name data
        ]



-- DATA TYPES


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



-- DATA


getCountries : List String
getCountries =
    D.keys countryDict


countryDict : D.Dict String Country
countryDict =
    D.fromList
        (L.map (\c -> ( c.name, c ))
            [ seCountry
            , dkCountry
            ]
        )


getCountry : String -> Country
getCountry country =
    M.withDefault seCountry (D.get country countryDict)



-- TEST DATA


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


dkYD : YearData
dkYD =
    YearData <| L.map (\v -> 100 + v) (L.range 1 53)


dkY : D.Dict Int Year
dkY =
    D.fromList
        [ ( 2000, Year 1234 dkYD )
        , ( 2000, Year 2234 dkYD )
        , ( 2000, Year 3234 dkYD )
        , ( 2000, Year 4234 dkYD )
        ]


dkCountry : Country
dkCountry =
    Country "Denmark" dkY
