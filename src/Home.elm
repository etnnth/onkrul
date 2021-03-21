module Home exposing (main)


import Html exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)



-- MAIN


main : Program () Model Msg
main =
  Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model
  = { examples : List ( Example )
  }




init : () -> ( Model, Cmd Msg )
init flags  =
  ( Model [example1], Cmd.none )

example1 = {title = "q", link = "d", description = "f"}

-- UPDATE


type alias Msg
  = {}

type alias Example
  = {   title : String
      , link : String
      , description : String
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  { title = "WebGL examples with elm" 
  , body = [
      div 
        [
          style "display" "flex"
        , style "flex-direction" "column"
        , style "margin" "0"
        , style "padding" "0em 0"
        , style "width" "100%"
        , style "height" "100%"
        , style "position" "absolute"
    ] 
    [ navLinks
    , nav examplesStyle examples
    , footer [
        style "background-color" "#333"
      , style "margin" "0"
      , style "padding" "1em 1em"
      , style "color" "#EEE"
      ][
        text "My footer"
        ]
      ]
      ]
  }

examplesStyle : List (Attribute msg)
examplesStyle = [ 
        style "background-color" "#222"
      , style "margin" "0"
      , style "padding" "1em 0"
      , style "flex-grow" "1"
      , style "display" "flex"
      , style "flex-wrap" "wrap"
      , style "align-content" "flex-start"
  ]

examples : List (Html msg)
examples = [
      p [] [viewLink "asdf" "google.com", text "sdfg"]
    , p [] [viewLink "bsdf" "google.com", text "sdafg"]
    ]

navLinks : Html msg
navLinks =
  nav [ 
        style "background-color" "#333"
      , style "margin" "0"
      , style "padding" "1em 0"
  ] [  
      viewLink "About" "/about"
    , viewLink "Github" "https://github.com/"
    ]

viewLink : String -> String -> Html msg
viewLink name path =
  a [ 
      href path
    , style "color" "#EEE"
    , style "margin" "1em"
    ] [ text name ] 
