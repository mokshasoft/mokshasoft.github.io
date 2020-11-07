{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Gen.Population exposing (getPopulation)

import Dict as D
import Maybe as M


getPopulation : Int -> String -> Int
getPopulation year country =
    let
        countryData : D.Dict Int Int
        countryData =
            case country of
                "Sweden" ->
                    popSweden

                _ ->
                    D.empty
    in
    M.withDefault 0 <| D.get year countryData


popSweden : D.Dict Int Int
popSweden =
    D.fromList
        [ ( 2000, 8882792 )
        , ( 2001, 8909128 )
        , ( 2002, 8940788 )
        , ( 2003, 8975670 )
        , ( 2004, 9011392 )
        , ( 2005, 9047752 )
        , ( 2006, 9113257 )
        , ( 2007, 9182927 )
        , ( 2008, 9256347 )
        , ( 2009, 9340682 )
        , ( 2010, 9415570 )
        , ( 2011, 9482855 )
        , ( 2012, 9555893 )
        , ( 2013, 9644864 )
        , ( 2014, 9747355 )
        , ( 2015, 9851017 )
        , ( 2016, 9995153 )
        , ( 2017, 10120242 )
        , ( 2018, 10230185 )
        , ( 2019, 10327589 )
        , ( 2020, 10327589 ) -- from 2019, but probably a bit higher
        ]
