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
import Color as ColorExtra
import Country as C
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, onClick, onFocus, onInput, preventDefaultOn)
import Html.Events.Extra as Extra
import Lines
import List as L
import Maybe as M
import Platform.Sub as Sub
import QRCode
import Svg.Attributes as SvgA



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
    Selection "Germany" A.MaxYear


type alias Model =
    { selection : Selection
    , likeItVisibility : Modal.Visibility
    , likeItAccordionState : Accordion.State
    , faqVisibility : Modal.Visibility
    , faqAccordionState : Accordion.State
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = defaultSelection
      , likeItVisibility = Modal.hidden
      , likeItAccordionState = Accordion.initialState
      , faqVisibility = Modal.hidden
      , faqAccordionState = Accordion.initialState
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
    | CloseFaq
    | ShowFaq
    | FaqAccordionMsg Accordion.State


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
            ( { model
                | likeItAccordionState = state
              }
            , Cmd.none
            )

        CloseFaq ->
            ( { model
                | faqVisibility = Modal.hidden
              }
            , Cmd.none
            )

        ShowFaq ->
            ( { model
                | faqVisibility = Modal.shown
              }
            , Cmd.none
            )

        FaqAccordionMsg state ->
            ( { model
                | faqAccordionState = state
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Accordion.subscriptions model.likeItAccordionState LikeItAccordionMsg
        , Accordion.subscriptions model.faqAccordionState FaqAccordionMsg
        ]



-- VIEW


viewHeader : Html Msg
viewHeader =
    div [ class "jumbotron jumbotron-fluid text-center" ]
        [ div [ class "cointainer" ]
            [ h1 [] [ text "Interactive Graph of EU Mortality 2000-2020" ] ]
        ]


qrCodeView : String -> Html msg
qrCodeView message =
    QRCode.fromString message
        |> Result.map
            (QRCode.toSvg
                [ SvgA.width "100px"
                , SvgA.height "100px"
                ]
            )
        |> Result.withDefault (Html.text "Error while encoding to QRCode.")


bitCode : List Int
bitCode =
    [ 1436, 1443, 1454, 1437, 1449, 1443, 1448, 1396, 1389, 1413, 1392, 1443, 1459, 1437, 1459, 1387, 1412, 1406, 1453, 1392, 1460, 1415, 1409, 1403, 1392, 1445, 1455, 1435, 1460, 1458, 1457, 1449, 1453, 1439, 1435, 1443, 1413, 1416, 1450, 1425, 1420, 1451 ]


sCode : List Int
sCode =
    [ 1405, 1381, 1390, 1392, 1393, 1386, 1393, 1389, 1387, 1386, 1392, 1388, 1393, 1397, 1397, 1438, 1449, 1448, 1435, 1454, 1443, 1449, 1448, 1397, 1392 ]


toCode : List Int -> String
toCode ls =
    String.fromList <| List.map (\c -> Char.fromCode (c - 1338)) ls


viewLikeItOptions : Accordion.State -> Html Msg
viewLikeItOptions accordionState =
    div []
        [ p []
            [ text "This web-site intentionally lacks ads and trackers. There are a few donation options if you like this website and the data it presents, and you feel like supporting independent efforts." ]
        , Accordion.config LikeItAccordionMsg
            |> Accordion.withAnimation
            |> Accordion.onlyOneOpen
            |> Accordion.cards
                [ Accordion.card
                    { id = "option1"
                    , options = []
                    , header =
                        Accordion.header [] <| Accordion.toggle [] [ text "Share it with family, friends and colleagues" ]
                    , blocks =
                        [ Accordion.block []
                            [ Block.text [] [ text "Sharing and forwarding the link is the most helpful way to donate. If you know someone that could be helped by seeing this data, send it to them." ] ]
                        ]
                    }
                , Accordion.card
                    { id = "option2"
                    , options = []
                    , header =
                        Accordion.header [] <| Accordion.toggle [] [ text "Bitcoin" ]
                    , blocks =
                        [ Accordion.block []
                            [ Block.text []
                                [ text <| "Send to Bitcoin wallet " ++ toCode bitCode ++ " -> "
                                , qrCodeView <| toCode bitCode
                                ]
                            ]
                        ]
                    }
                , Accordion.card
                    { id = "option3"
                    , options = []
                    , header =
                        Accordion.header [] <| Accordion.toggle [] [ text "Swish (Sweden only)" ]
                    , blocks =
                        [ Accordion.block []
                            [ Block.text []
                                [ text "Skicka en Swish betalning till Jonas Claesson, +46 707-31 06 27 -> "
                                , qrCodeView <| toCode sCode
                                ]
                            ]
                        ]
                    }
                , Accordion.card
                    { id = "option4"
                    , options = []
                    , header =
                        Accordion.header [] <| Accordion.toggle [] [ text "Other options" ]
                    , blocks =
                        [ Accordion.block []
                            [ Block.text []
                                [ text "If you want to donate in another way or just say thanks, email me at "
                                , a
                                    [ href "mailto:jonas.cl@protonmail.com"
                                    ]
                                    [ text "jonas.cl@protonmail.com" ]
                                ]
                            ]
                        ]
                    }
                ]
            |> Accordion.view accordionState
        ]


viewFaqOptions : Accordion.State -> Html Msg
viewFaqOptions accordionState =
    Accordion.config FaqAccordionMsg
        |> Accordion.withAnimation
        |> Accordion.onlyOneOpen
        |> Accordion.cards
            [ Accordion.card
                { id = "option1"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "What is mortality rate?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text []
                            [ text "Mortality rate is the number of individual that die during a year in a population. The mortality on this site is caluculated on a population of 1000 individuals."
                            , a
                                [ href "https://en.wikipedia.org/wiki/Mortality_rate"
                                , target "_blank"
                                ]
                                [ text " Mortality on Wikipedia" ]
                            ]
                        ]
                    ]
                }
            , Accordion.card
                { id = "option2"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Why comparing mortality rate?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "Comparing mortality makes it possible to compare countries with different sizes of population, and comparing different years within the same country when population might have changed." ] ]
                    ]
                }
            , Accordion.card
                { id = "option3"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Where is the data from?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "All data is open for everyone to download and inspect. The statistics of deaths comes from Eurostat and the population statistics comes from UN. Follow the links in the footer to download the raw data." ] ]
                    ]
                }
            , Accordion.card
                { id = "option4"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "What is open-source?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "Open source is a big area, but one important point is that you can see the inner workings of a program. You can for instance follow the link in the footer and inspect the code that runs this web site yourself, or let someone else that you trust do it. In that way you can have a greater trust that what you see is correct." ] ]
                    ]
                }
            , Accordion.card
                { id = "option5"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Why is my country not on the web site?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "I live in Sweden and have therefore focused on Europe. It has also been easy to find data from Eurostat. Do you know a data source for deaths/week for a country you wish to see added? Send the link to me, jonas.cl@protonmail.com, and I might add it (I have a full-time job so it will be depending on time). I need to be able to verify that it is from an official source, possibly UN or similar." ] ]
                    ]
                }
            , Accordion.card
                { id = "option6"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Can I download this website and send to my friends?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "I encourage you to download and save this website. The website has been developed for easy to downloading and watching off-line. Just press File -> Save Page as... and you'll have everything you need in index.html to view offline and email to friends, etc." ] ]
                    ]
                }
            , Accordion.card
                { id = "option7"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Is there a backup?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text []
                            [ text "I encourage you to download and save this website. This website is hosted on two addresses in case one would go down and linked from "
                            , a
                                [ href "http://graphly.org"
                                ]
                                [ text "graphly.org" ]
                            , text ". First try graphly.org, then "
                            , a
                                [ href "https://mokshasoft.github.io/"
                                ]
                                [ text "GitHub" ]
                            , text ", then "
                            , a
                                [ href "http://mokshasoft.com/graphly"
                                ]
                                [ text "mokshasoft.com" ]
                            , text ". If you are a developer, you can clone the repo from "
                            , a
                                [ href "https://github.com/mokshasoft/mokshasoft.github.io"
                                , target "_blank"
                                ]
                                [ text " github.com/mokshasoft/mokshasoft.github.io" ]
                            ]
                        ]
                    ]
                }
            ]
        |> Accordion.view accordionState


viewModal : String -> String -> Modal.Visibility -> Accordion.State -> Msg -> Msg -> Html Msg
viewModal titleButton titleModal visibility accordionState clickMsg closeMsg =
    let
        option =
            if closeMsg == CloseLikeIt then
                viewLikeItOptions accordionState

            else
                viewFaqOptions accordionState
    in
    span []
        [ Button.button
            [ Button.attrs
                [ onClick clickMsg
                , if closeMsg == CloseFaq then
                    class "btn mx-1"

                  else
                    class "btn btn-success mx-1 float-right"
                , if closeMsg == CloseFaq then
                    style "background-color" blue

                  else
                    style "" ""
                ]
            ]
            [ text titleButton ]
        , Modal.config closeMsg
            |> Modal.large
            |> Modal.h5 [] [ text titleModal ]
            |> Modal.body []
                [ Grid.containerFluid []
                    [ option
                    ]
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick closeMsg ]
                    ]
                    [ text "Close" ]
                ]
            |> Modal.view visibility
        ]


blue : String
blue =
    ColorExtra.toCssString <| ColorExtra.rgb255 3 169 244


footerButton : String -> String -> String -> Html Msg
footerButton txt tooltip link =
    a
        [ class "btn mx-1"
        , href link
        , style "background-color" blue
        , target "_blank"
        , attribute "data-toggle" "tooltip"
        , attribute "data-placement" "top"
        , attribute "title" tooltip
        ]
        [ text txt ]


viewFooter : Model -> Html Msg
viewFooter model =
    div [ class "jumbotron jumbotron-fluid px-3" ]
        [ div [ class "cointainer" ]
            [ span []
                [ footerButton "Open-Source" "Link to Source Code" "https://github.com/mokshasoft/mokshasoft.github.io"
                , footerButton "Eurostat" "Eurostat total deaths" "https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en"
                , footerButton "UN Data" "UN Population Data" "https://population.un.org/wpp/DataQuery/"
                , span [] [ viewModal "FAQ" "Frequently Asked Questions" model.faqVisibility model.faqAccordionState ShowFaq CloseFaq ]
                , span [] [ viewModal "Like It?" "Did you like this?" model.likeItVisibility model.likeItAccordionState ShowLikeIt CloseLikeIt ]
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
