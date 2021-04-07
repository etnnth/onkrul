module Mandelbrot exposing (main, metadata)



import Browser
import Browser.Events
import Html exposing (Html)
import Browser.Dom exposing (getViewport, Viewport)
import Html.Attributes exposing (width, height, style)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import WebGL
import Task
import List
import Index.Metadata
import Time
import Components.Components


-- MAIN


main =
  Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


metadata : Index.Metadata.Metadata
metadata = {
  title = "Mandelbrot",
  link = "Mandelbrot",
  keywords = ["mandelbrot", "webgl"],
  description = "Mandelbrot drawing in webgl",
  code = "https://github.com/etnnth/onkrul/blob/main/src/Mandelbrot.elm",
  date = Time.millisToPosix 0
  }


-- MODEL


type alias Model =
  { time : Float
  , width : Int
  , height : Int
  }


init : () -> (Model, Cmd Msg)
init () =
  ( { time = 0
    , width = 0
    , height = 0}, Cmd.batch
        [Task.perform GetViewport getViewport
        ] 
        )


-- UPDATE


type Msg
  = TimeDelta Float
  | Resize Int Int
  | GetViewport Viewport


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TimeDelta dt ->
      ( {model | time = model.time + dt}, Cmd.none )
    Resize width height -> ( {model | width = width, height = height}, Cmd.none ) 
    GetViewport { viewport } ->
            ( { model | width = round viewport.width, height = round viewport.height }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ Browser.Events.onAnimationFrameDelta TimeDelta -- time in seconds
    , Browser.Events.onResize Resize
    ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
  { title = "Mandelbrot"
  , body = [
      WebGL.toHtml
        [ width model.width
        , height model.height
        , style "position" "absolute"
        , style "left" "0"
        , style "top" "0"
        , style "background-color" "#000"
        ]
        [ WebGL.entity vertexShader fragmentShader mesh (uniforms model)],
    Components.Components.mainDiv [
      Components.Components.navLinks (List.append (Components.Components.infosView metadata) []),
      Html.div [style "flex-grow" "1"] [],
      Components.Components.footerView
      ]
    ]
  }

type alias Uniforms =
  { time : Float
  , size : Vec2
  , dim : Float
  }


uniforms : Model -> Uniforms
uniforms model =
  { time = model.time
  , size = vec2 (toFloat model.width) (toFloat model.height)
  , dim = toFloat (min model.width model.height)
  }



-- MESH


type alias Vertex = { position : Vec2 }


mesh : WebGL.Mesh Vertex
mesh = WebGL.triangles 
  [ ( Vertex (vec2 1 1), Vertex (vec2 1 -1), Vertex (vec2 -1 -1) )
  , ( Vertex (vec2 1 1), Vertex (vec2 -1 1), Vertex (vec2 -1 -1) )
  ]




-- SHADERS


vertexShader : WebGL.Shader Vertex Uniforms { fragCoord : Vec2 }
vertexShader =
  [glsl|
    attribute vec2 position;
    varying vec2 fragCoord;
    void main () {
        gl_Position = vec4(position, 0.0,  1.0);
        fragCoord = position;
    }
  |]


fragmentShader : WebGL.Shader {} Uniforms { fragCoord : Vec2 }
fragmentShader =
  [glsl|
    precision mediump float;
    uniform float time;
    uniform float dim;
    uniform vec2 size;
    varying vec2 fragCoord;
    vec3 palette (float t, float time) {
      float speed = 0.001;
      float c = 0.5 * (1.0 + cos(speed * time));
      float s = 0.5 * (1.0 + sin(speed * time));
      vec3 c2 = vec3(0.05, 0.05, 0.05);
      vec3 c3 = vec3(0.3, 0.2, 0.5);
      vec3 c4 = vec3(c, s, 0.8);
      float x = 1.0 / 100.0;
        if (t < 1.9*x) return c2;
        else if (t < 2.0 * x) return mix(c2, c3, (t - 1.9*x)/x);
        else if (t < 3.0 * x) return mix(c3, c4, (t - 2.0*x)/x);
        return c4;
    }
    void main () {
      vec2 uv = fragCoord * size / dim;
      int iteration;
      const int max_iteration = 1000;
      vec2 c =  uv + vec2( -0.5, 0.0);
      vec2 z = vec2(.0);
      for (int i = 0; i < max_iteration; i++) {
        iteration = i + 1;
        z = vec2(z.x*z.x - z.y *z.y, 2.0 * z.x *z.y) + c;
        if (length(z) > 200.0) { break; }
      }
      if ( iteration < max_iteration ) {
        gl_FragColor = vec4(palette(float(iteration) / float(max_iteration), time), 1.0);
      } else {
        gl_FragColor = vec4(0.0);
      }
    }
  |]


