module About exposing ( main )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Index.Metadata exposing (Metadata)
import Index.Index
import Components.Components exposing (link, navLinks, footerView)


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
  = { index : List ( Metadata )
  , search : String
  }

init : () -> ( Model, Cmd Msg )
init flags  =
  ( Model (Index.Index.sortIndex "") "", Cmd.none )


-- UPDATE


type Msg
  = Change String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Change search ->
      ( { model | search = search, index = Index.Index.sortIndex search}, Cmd.none )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- VIEW


view : Model -> Browser.Document Msg
view model =
  let
    aboutStyle : List (Attribute msg)
    aboutStyle = [ 
            style "background-color" "#222"
          , style "margin" "0"
          , style "padding" "1em"
          , style "flex-grow" "1"
          , style "display" "flex"
          , style "flex-wrap" "wrap"
          , style "align-content" "flex-start"
          , style "color" "#EEE"
      ]

    mainDiv : List (Html msg) -> Html msg
    mainDiv = div [
              style "display" "flex"
            , style "background-color" "#333"
            , style "flex-direction" "column"
            , style "margin" "0"
            , style "padding" "0em 0"
            , style "width" "100%"
            , style "height" "100%"
            , style "position" "absolute"
        ]
  in
  { title = "Onkrul About" 
  , body = [
    mainDiv [ 
      navLinks [link "Home" "Home", link "Github" "https://github.com/"]
    , p aboutStyle [text "about"]
    , footerView
      ]
    ]
  }


