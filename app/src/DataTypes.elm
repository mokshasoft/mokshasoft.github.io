{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module DataTypes exposing (..)

import Dict as D


type alias Year =
    { total : Int
    , data : List Int
    }


type alias Country =
    { name : String
    , data : D.Dict Int Year
    }


type alias Selection =
    { country : String
    , year : Int
    }
