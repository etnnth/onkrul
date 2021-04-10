module Components.Components exposing (mainDiv, footerView, navLinks, infosView, link, fpsViewer)


import Html.Attributes exposing (..)
import Html exposing (..)
import Index.Metadata
import String



fpsViewer : Float -> Html msg
fpsViewer fps =
  let
      value = "fps:" ++ String.fromInt (round fps)
  in
  div [ 
    style "position" "absolute"
  , style "right" "0"  
  , style "top" "0"
  , style "background-color" "#333"
  , style "padding" "0.5em"
  , style "font-size" "1em"
  , style "color" "red"
  ] [text value]


mainDiv : List (Html msg) -> Html msg
mainDiv = div [
          style "display" "flex"
        , style "flex-direction" "column"
        , style "margin" "0"
        , style "padding" "0em 0"
        , style "width" "100%"
        , style "height" "100%"
        , style "position" "absolute"
    ]

footerView : Html msg
footerView =
  let
    footerStyle : List (Attribute msg)
    footerStyle = [
            style "margin" "0"
          , style "padding" "1em 1em"
          , style "color" "#EEE"
          , style "width" "min-content"
          , style "background-color" "#333"
          ]
  in
  footer footerStyle [text "footer"]

navLinks : List(Html msg) -> Html msg
navLinks links =
  nav [ style "margin" "0"
      , style "padding" "1em 1em"
      , style "width" "min-content"
      , style "background-color" "#333"
  ] links

link : String -> String -> Html msg
link name path =
  a [ 
      href path
    , style "color" "#EEE"
    , style "margin" "1em 0.3em 1em 1em"
    ] [ text name ] 

title : Index.Metadata.Metadata -> Html msg
title metadata = h2
    [ style "color" "#EEE"
    , style "margin" "0"
    , style "padding" "1em"
    , style "width" "min-content"
    , style "background-color" "#333"
    ] [text metadata.title]

infosView : Index.Metadata.Metadata -> List ( Html msg )
infosView metadata = 
  [ title metadata 
  , link "Home" "Home"
  , link "About" "About"
  , link "Code" metadata.code
  ]



