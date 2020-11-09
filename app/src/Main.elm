{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Main exposing (..)

import Analysis as A
import Bootstrap.Accordion as Accordion
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
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
    , likeItVisibility : Modal.Visibility
    , likeItAccordionState : Accordion.State
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = defaultSelection
      , likeItVisibility = Modal.hidden
      , likeItAccordionState = Accordion.initialState
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SetCountry String
    | SetAnalysis String
    | CloseLikeIt
    | ShowLikeIt
    | LikeItAccordionMsg Accordion.State


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

        CloseLikeIt ->
            ( { model
                | likeItVisibility = Modal.hidden
              }
            , Cmd.none
            )

        ShowLikeIt ->
            ( { model
                | likeItVisibility = Modal.shown
              }
            , Cmd.none
            )

        LikeItAccordionMsg state ->
            ( { model | likeItAccordionState = state }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Accordion.subscriptions model.likeItAccordionState LikeItAccordionMsg



-- VIEW


viewHeader : Html Msg
viewHeader =
    div [ class "jumbotron jumbotron-fluid text-center" ]
        [ div [ class "cointainer" ]
            [ h1 [] [ text "Interactive Graph of EU Mortality 2000-2020" ] ]
        ]


viewLikeItOptions : Model -> Html Msg
viewLikeItOptions model =
    Accordion.config LikeItAccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards
            [ Accordion.card
                { id = "option1"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Option 1" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "Lorem ipsum etc" ] ]
                    ]
                }
            , Accordion.card
                { id = "option2"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Option 2" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "Lorem ipsum etc" ] ]
                    ]
                }
            ]
        |> Accordion.view model.likeItAccordionState


viewLikeIt : Model -> Html Msg
viewLikeIt model =
    Grid.container []
        [ Button.button
            [ Button.attrs [ onClick ShowLikeIt ] ]
            [ text "Like It?" ]
        , Modal.config CloseLikeIt
            |> Modal.large
            |> Modal.h5 [] [ text "Did you like this?" ]
            |> Modal.body []
                [ Grid.containerFluid []
                    [ Grid.row []
                        [ Grid.col
                            [ Col.xs12 ]
                            [ viewLikeItOptions model ]
                        ]
                    ]
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick CloseLikeIt ]
                    ]
                    [ text "Close" ]
                ]
            |> Modal.view model.likeItVisibility
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


viewFooter : Model -> Html Msg
viewFooter model =
    div [ class "jumbotron jumbotron-fluid px-3" ]
        [ div [ class "cointainer" ]
            [ p []
                [ footerButton "Open-Source" "Link to Source Code" "https://github.com/mokshasoft/mokshasoft.github.io"
                , footerButton "Eurostat" "Eurostat total deaths" "https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en"
                , footerButton "UN Data" "UN Population Data" "https://population.un.org/wpp/DataQuery/"
                , footerButton "Mortality Rate?" "The Mortality Rate shown in the graphs, is the number of people that die in a population of 1000 individual in a year." "https://en.wikipedia.org/wiki/Mortality_rate"
                , span [ class "float-right" ] [ viewLikeIt model ]
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
            , class "custom-select"
            ]
            optListCountry
        , select
            [ Extra.onChange SetAnalysis
            , class "custom-select"
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
                [ viewFooter model
                ]
            ]
        ]
