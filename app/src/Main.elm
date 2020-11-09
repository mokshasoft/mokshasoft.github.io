{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Main exposing (..)

import Analysis as A
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


main : Program () Model Msg
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
    , analysis : A.Analysis
    }


defaultSelection : Selection
defaultSelection =
    Selection "Sweden" A.MaxYear


type alias Model =
    { selection : Selection
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = defaultSelection
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SetCountry String
    | SetAnalysis String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetCountry c ->
            ( { model
                | selection = Selection c model.selection.analysis
              }
            , Cmd.none
            )

        SetAnalysis c ->
            ( { model
                | selection = Selection model.selection.country <| A.getAnalysis c
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


footerButton : String -> String -> String -> Html Msg
footerButton txt tooltip link =
    a
        [ class "btn btn-secondary mx-1"
        , href link
        , attribute "data-toggle" "tooltip"
        , attribute "data-placement" "top"
        , attribute "title" tooltip
        ]
        [ text txt ]


viewFooter : Html Msg
viewFooter =
    div [ class "jumbotron jumbotron-fluid" ]
        [ div [ class "cointainer" ]
            [ p []
                [ footerButton "Open-Source" "Link to Source Code" "https://github.com/mokshasoft/mokshasoft.github.io"
                , footerButton "Eurostat" "Eurostat total deaths" "https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en"
                , footerButton "UN Data" "UN Population Data" "https://population.un.org/wpp/DataQuery/"
                , footerButton "Mortality Rate?" "What is mortality rate?" "https://en.wikipedia.org/wiki/Mortality_rate"

                -- https://package.elm-lang.org/packages/rundis/elm-bootstrap/latest/Bootstrap-Popover
                ]
            ]
        ]


viewSelection : Model -> Html Msg
viewSelection model =
    let
        optListCountry : List (Html Msg)
        optListCountry =
            L.map (\t -> option [ selected (t == model.selection.country), value t ] [ text t ]) C.getCountries

        optListAnalysis : List (Html Msg)
        optListAnalysis =
            L.map (\t -> option [ selected (t == model.selection.country), value t ] [ text t ]) A.getAllAnalysis
    in
    div []
        [ select
            [ Extra.onChange SetCountry
            , class "mx-2"
            ]
            optListCountry
        , select
            [ Extra.onChange SetAnalysis
            , class "mx-2"
            ]
            optListAnalysis
        ]


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ viewHeader
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ viewSelection model
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ div [ class "container" ] [ Lines.chart model.selection.country model.selection.analysis ]
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ viewFooter
                ]
            ]
        ]
