{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Main exposing (..)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, onClick, onFocus, onInput, preventDefaultOn)
import Lines as Lines
import List as L
import Maybe as M



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Selection =
    { country : String
    }


type alias Model =
    { countries : List String
    , selection : Selection
    , text : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        countries =
            Lines.getCountries
    in
    ( { text = ""
      , countries = countries
      , selection = Selection <| M.withDefault "Sweden" (L.head countries)
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Change String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change txt ->
            ( { model
                | text = txt
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewCountrySelection : Model -> Html Msg
viewCountrySelection model =
    let
        optList =
            L.map (\t -> option [ value t ] [ text t ]) model.countries
    in
    div []
        [ select [] optList
        ]


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ viewCountrySelection model
                , div [ class "container" ] [ Lines.chart model.selection.country ]
                , input [ placeholder "Dummy", value model.text, onInput Change ] []
                ]
            ]
        ]
