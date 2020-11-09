{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module ListExtra exposing
    ( dropRight
    , dropWhile
    , takeWhile
    )

import List exposing (..)



-- FUNCTIONS


{-| Drop i elements from the end of the list.
-}
dropRight : Int -> List a -> List a
dropRight i ls =
    take (length ls - i) ls


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


{-| Drop elements from a list until the predicate is true.
-}
dropWhile : (a -> Bool) -> List a -> List a
dropWhile p ls =
    case ls of
        h :: rest ->
            if p h then
                dropWhile p rest

            else
                ls

        [] ->
            []
