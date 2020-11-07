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
import Country as C
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, onClick, onFocus, onInput, preventDefaultOn)
import Html.Events.Extra as Extra
import Lines
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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        countries =
            C.getCountries
    in
    ( { countries = countries
      , selection = Selection "Sweden"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SetCountry String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetCountry c ->
            ( { model
                | selection = Selection c
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewHeader : Html Msg
viewHeader =
    div [ class "jumbotron jumbotron-fluid text-center" ]
        [ div [ class "cointainer" ]
            [ h1 [] [ text "Interactive Graph of EU Mortality 2000-2020" ] ]
        ]


viewFooter : Html Msg
viewFooter =
    div [ class "jumbotron jumbotron-fluid" ]
        [ div [ class "cointainer" ]
            [ p []
                [ a [ href "https://github.com/mokshasoft/mr" ]
                    [ text " GitHub" ]
                , a [ href "https://https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en" ]
                    [ text " Eurostat" ]

                -- https://package.elm-lang.org/packages/rundis/elm-bootstrap/latest/Bootstrap-Popover
                ]
            ]
        ]


viewCountrySelection : Model -> Html Msg
viewCountrySelection model =
    let
        optList =
            L.map (\t -> option [ selected (t == model.selection.country), value t ] [ text t ]) model.countries
    in
    div []
        [ select [ Extra.onChange SetCountry ] optList
        ]


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ viewHeader
                , viewCountrySelection model
                , div [ class "container" ] [ Lines.chart model.selection.country ]
                , viewFooter
                ]
            ]
        ]
