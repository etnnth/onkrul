module Home exposing (main)


import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Index.Sort exposing (sortBySearch)
import Index.Metadata exposing (Metadata)


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
  ( Model (sortBySearch "") "", Cmd.none )

-- UPDATE


type Msg
  = Change String


viewIndex : Metadata -> Html msg
viewIndex e = p [style "margin" "1em", style "color" "#AAA"] (List.concat [
  [viewLink e.title e.link
  , text ": "
  , text e.description
  , br [] []
  ], (List.map viewKeyword e.keywords), [viewLink "code" e.code]])

viewKeyword : String -> Html msg
viewKeyword kw = i [style "margin-left" "1em"] [text kw]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Change search ->
      ( { model | search = search, index = sortBySearch search}, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW

mainStyle : List (Attribute msg)
mainStyle = [
          style "display" "flex"
        , style "flex-direction" "column"
        , style "margin" "0"
        , style "padding" "0em 0"
        , style "width" "100%"
        , style "height" "100%"
        , style "position" "absolute"
    ]

footerStyle : List (Attribute msg)
footerStyle = [
        style "background-color" "#333"
      , style "margin" "0"
      , style "padding" "1em 1em"
      , style "color" "#EEE"
      ]

searchBarStyle : List (Attribute msg)
searchBarStyle = [
        style "background-color" "#333"
      , style "margin" "0"
      , style "padding" "0.3em 1em"
      , style "color" "#eea"
      ]

searchBar : Model -> Html Msg
searchBar model = div searchBarStyle [
    text "Search : "
    , input (List.append searchBarStyle [value model.search, onInput Change]) []
    ]

view : Model -> Browser.Document Msg
view model =
  { title = "WebGL examples with elm" 
  , body = [
    div mainStyle [ 
      navLinks
    , searchBar model
    , nav indexStyle (List.map viewIndex model.index)
    , footer footerStyle [text "My footer"]
      ]
    ]
  }

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
    , style "margin" "1em 0.3em 1em 1em"
    ] [ text name ] 
