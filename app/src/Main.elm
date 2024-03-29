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
    , fullRange : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = defaultSelection
      , likeItVisibility = Modal.hidden
      , likeItAccordionState = Accordion.initialState
      , faqVisibility = Modal.hidden
      , faqAccordionState = Accordion.initialState
      , fullRange = True
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
    div [ class "jumbotron text-centerl" ]
        [ div []
            [ h1 [] [ text "Interactive Graph of EU Mortality 2000-2020" ]
            , hr []
                []
            , p []
                [ text "All data on this site is from official EU and UN sources."
                , a
                    [ href "https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en"
                    , target "_blank"
                    ]
                    [ text " EU data on deaths" ]
                , a
                    [ href "https://population.un.org/wpp/DataQuery/"
                    , target "_blank"
                    ]
                    [ text " UN population data" ]
                ]
            , p []
                [ text " All source code that shows these graphs are publicly available (open-source)"
                , a
                    [ href "https://github.com/mokshasoft/mokshasoft.github.io"
                    , target "_blank"
                    ]
                    [ text " Source code" ]
                ]
            ]
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


snCode : List Int
snCode =
    [ 1412, 1449, 1448, 1435, 1453, 1370, 1405, 1446, 1435, 1439, 1453, 1453, 1449, 1448, 1382, 1370, 1381, 1390, 1392, 1370, 1393, 1386, 1393, 1383, 1389, 1387, 1370, 1386, 1392, 1370, 1388, 1393 ]


toCode : List Int -> String
toCode ls =
    String.fromList <| List.map (\c -> Char.fromCode (c - 1338)) ls


viewLikeItOptions : Accordion.State -> Html Msg
viewLikeItOptions accordionState =
    div []
        [ p []
            [ text "This website intentionally lacks ads and trackers. There are a few donation options if you like this website and the data it presents, and you feel like supporting independent efforts." ]
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
                        Accordion.header [] <| Accordion.toggle [] [ text "Swish (Sweden only)" ]
                    , blocks =
                        [ Accordion.block []
                            [ Block.text []
                                [ text <| "Skicka en Swish betalning till " ++ toCode snCode ++ " -> "
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
                            [ text "Mortality rate is the total number of individuals that die during a year in a population. This website shows the general mortality, that is all causes of deaths are included. The mortality on this site is calculated on a population of 1000 individuals."
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
                        [ Block.text [] [ text "I think that general mortality rate is the only trustworthy measurement that sets the events of 2020 in a bigger perspective. It also increases the comparability of data from different countries and years since it takes population numbers into account. This bigger perspective is a very important tool to understand and analyze data." ] ]
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
                    Accordion.header [] <| Accordion.toggle [] [ text "Why is there data missing for 2020?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "The data is from Eurostat and different countries seem to report data at different rates, so this data is always lagging a bit and the lag differ between countries. The last weeks of data does not seem to be reliable since it shows very low numbers, so the last weeks are filtered out. The data on this website also needs to be updated manually, and I will try to do that twice-a-month." ] ]
                    ]
                }
            , Accordion.card
                { id = "option5"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "What is open-source?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "Open source is a big area, but one important point is that you can see the inner workings of a program. You can for instance follow the link in the footer and inspect the code that runs this web site yourself, or let someone else that you trust do it. In that way you can have a greater trust that what you see is correct." ] ]
                    ]
                }
            , Accordion.card
                { id = "option6"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Why is my country not on the web site?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "I live in Sweden and have therefore focused on Europe. It has also been easy to find data from Eurostat. Do you know a data source for deaths/week for a country you wish to see added? Send the link to me, jonas.cl@protonmail.com, and I might add it (I have a full-time job so it will be depending on time). I need to be able to verify that it is from an official source, possibly UN or similar." ] ]
                    ]
                }
            , Accordion.card
                { id = "option7"
                , options = []
                , header =
                    Accordion.header [] <| Accordion.toggle [] [ text "Can I download this website and send to my friends?" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.text [] [ text "I encourage you to download and save this website. The website has been developed for easy to downloading and watching off-line. Just press File -> Save Page as... and you'll have everything you need in index.html to view offline and email to friends, etc." ] ]
                    ]
                }
            , Accordion.card
                { id = "option8"
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
        option : Html Msg
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
                    class "btn btn-lg m-1"

                  else
                    class "btn btn-lg btn-success m-1"
                , if closeMsg == CloseFaq then
                    style "background-color" blue

                  else
                    style "" ""
                ]
            ]
            [ text titleButton ]
        , Modal.config closeMsg
            |> Modal.attrs [ style "max-width" "100%" ]
            |> Modal.large
            |> Modal.h5 [ class "mx-auto" ] [ text titleModal ]
            |> Modal.scrollableBody True
            |> Modal.body []
                [ container []
                    [ option
                    ]
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs
                        [ onClick closeMsg
                        , class "btn-lg"
                        ]
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
        [ class "btn btn-lg m-1"
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
    div [ class "jumbotron" ]
        [ div []
            [ p []
                [ text "Click on the Open-Source, Eurostat, UN Data, FAQ or Donate button below!" ]
            , span []
                [ footerButton "Open-Source" "Link to Source Code" "https://github.com/mokshasoft/mokshasoft.github.io"
                , footerButton "Eurostat" "Eurostat total deaths" "https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en"
                , footerButton "UN Data" "UN Population Data" "https://population.un.org/wpp/DataQuery/"
                , span [] [ viewModal "FAQ" "Frequently Asked Questions" model.faqVisibility model.faqAccordionState ShowFaq CloseFaq ]
                , span [] [ viewModal "Donate" "Did you like this and want to make a donation?" model.likeItVisibility model.likeItAccordionState ShowLikeIt CloseLikeIt ]
                ]
            , p [ class "text-center m-1" ]
                [ text "e-mail: "
                , a
                    [ href "mailto:jonas.cl@protonmail.com"
                    ]
                    [ text "jonas.cl@protonmail.com" ]
                , text ", mobile: "
                , a
                    [ href "tel:+46707310627"
                    ]
                    [ text " +46 707 31 06 27" ]
                ]
            , p [ class "text-center m-1" ]
                [ text "This website is built as charity and I have another day job. I will try to get back to you as soon as possible, but due to those circumstances it might take a while." ]
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
            , class "custom-select m-1"
            ]
            optListCountry
        , select
            [ Extra.onChange SetAnalysis
            , class "custom-select m-1"
            ]
            optListAnalysis
        ]


stylesheet : Html msg
stylesheet =
    node "link"
        [ rel "stylesheet"
        , href "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
        ]
        []


container : List (Attribute msg) -> List (Html msg) -> Html msg
container attributes children =
    div ([ class "container-xl" ] ++ attributes) children


view : Model -> Html Msg
view model =
    container []
        [ stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ viewHeader
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ p [ class "lead" ]
                    [ text "Select Your country right below, and the type of graph you want to see!" ]
                , viewSelection model
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ div [] [ Lines.chart model.selection.country model.selection.analysis model.fullRange ]
                ]
            ]
        , Grid.row []
            [ Grid.col []
                [ viewFooter model
                ]
            ]
        ]
