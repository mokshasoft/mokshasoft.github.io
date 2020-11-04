{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Gen.Data exposing (countries, defaultCountry)

import DataTypes exposing (..)
import Dict as D
import List as L


defaultCountry : Country
defaultCountry =
    seCountry


countries : List Country
countries =
    [ seCountry
    , dkCountry
    ]


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
