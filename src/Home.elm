module Home exposing (main)


import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



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

type alias Example
  = {   title : String
      , link : String
      , description : String
      , keywords : List ( String )
      , code : String
  }

type alias Model
  = { examples : List ( Example )
  , search : String
  }


init : () -> ( Model, Cmd Msg )
init flags  =
  ( Model examples "", Cmd.none )


examples = [
    {title = "title", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw1", "kw2"],
            code = "code1"}
  , {title = "title", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw1", "kw3"],
            code = "code2"}
  ]

-- UPDATE


type Msg
  = Change String

append3 l1 l2 l3 = List.append l1 ( List.append l2 l3 )

viewExample : Example -> Html msg
viewExample e = p [style "margin" "1em", style "color" "#AAA"] (append3 [
    viewLink e.title e.link
  , text e.description
  ] (List.map viewKeyword e.keywords) [viewLink "code" e.code])

viewKeyword : String -> Html msg
viewKeyword kw = i [style "margin-left" "1em"] [text kw]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Change newContent ->
      ( { model | search = newContent, examples = List.reverse model.examples}, Cmd.none )



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
    , nav examplesStyle (List.map viewExample model.examples)
    , footer footerStyle [text "My footer"]
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
