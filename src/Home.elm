module Home exposing (main)


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
    keywordView : String -> Html msg
    keywordView kw = i [style "margin-left" "1em"] [text kw]

    indexView : Metadata -> Html msg
    indexView e = p [style "margin" "1em", style "color" "#AAA"] (List.concat [
      [link e.title e.link
      , text ": "
      , text e.description
      , br [] []
      ], (List.map keywordView e.keywords), [link "code" e.code]]) 

    indexStyle : List (Attribute msg)
    indexStyle = [ 
            style "background-color" "#222"
          , style "margin" "0"
          , style "padding" "1em 0"
          , style "flex-grow" "1"
          , style "display" "flex"
          , style "flex-wrap" "wrap"
          , style "align-content" "flex-start"
      ]

    searchBarStyle : List (Attribute msg)
    searchBarStyle = [
            style "background-color" "#333"
          , style "margin" "0"
          , style "padding" "0.3em 1em"
          , style "color" "#eea"
          ]

    searchBar : Html Msg
    searchBar = div searchBarStyle [
        text "Search : "
        , input (List.append searchBarStyle [value model.search, onInput Change]) []
        ]

    homeDiv : List (Html msg) -> Html msg
    homeDiv = div [
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
  { title = "Onkrul Home" 
  , body = [
    homeDiv [ 
      navLinks [link "About" "About", link "Github" "https://github.com/etnnth/onkrul"]
    , searchBar 
    , nav indexStyle (List.map indexView model.index)
    , footerView
      ]
    ]
  }


