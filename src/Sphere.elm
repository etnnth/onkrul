module Sphere exposing (main, metadata)



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
  title = "Sphere",
  link = "Sphere",
  keywords = ["ray marching", "webgl"],
  description = "Sphere drawing in webgl with ray marching",
  code = "https://github.com/etnnth/onkrul/blob/main/src/Sphere.elm",
  date = Time.millisToPosix 0
  }


-- MODEL


type alias Model =
  { time : Float
  , width : Int
  , height : Int
  , fps : Float
  }


init : () -> (Model, Cmd Msg)
init () =
  ( { time = 0
    , width = 0
    , height = 0
    , fps = 0
  }, Cmd.batch
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
      ( {model | time = model.time + dt, fps = model.fps * 0.9 +  100 / dt}, Cmd.none )
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
  { title = "Sphere"
  , body = [
      WebGL.toHtmlWith [WebGL.clearColor 0 0 0 0, WebGL.antialias]
        [ width model.width
        , height model.height
        , style "height" "100%"
        , style "width" "100%"
        , style "position" "absolute"
        , style "left" "0"
        , style "top" "0"
        , style "background-color" "#000"
        ]
        [ WebGL.entity vertexShader fragmentShader mesh (uniforms model)],
    Components.Components.mainDiv [
      Components.Components.navLinks (List.append (Components.Components.infosView metadata) []),
      Html.div [style "flex-grow" "1"] [],
      Components.Components.footerView,
      Components.Components.fpsViewer model.fps
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
    const float SURF_DIST = .001;
    const float MAX_DIST = 20.;
    const int MAX_STEPS = 1000;

    float GetDist(vec3 p) {
      vec4 s = vec4(3.0 * sin(time * 7e-4), 1.1, 7.0 + 2.0 * cos(time * 3e-4), 1.0);
      float sphereDist = length(p-s.xyz)-s.w;
      vec2 tilling = .1 * pow(.5 - .49 * sin(p.xz * 20.), vec2(300.));
      float planeDist = p.y + max(tilling.x, tilling.y);
      float d = min(sphereDist, planeDist);
      return d;
    }

    float RayMarch(vec3 ro, vec3 rd) {
      float dO=0.;
      for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST ) break;
      }
      return dO;
    }

    vec3 GetNormal(vec3 p) {
      float d = GetDist(p);
      vec2 e = vec2(.01, 0);
      vec3 n = d - vec3(
          GetDist(p-e.xyy),
          GetDist(p-e.yxy),
          GetDist(p-e.yyx));
      return normalize(n);
    }

    float GetLight(vec3 p) {
        vec3 lightPos = vec3(0, 5, 6);
        lightPos.xz += vec2(sin(time * 1e-3), cos(time * 1e-3))*2.;
        vec3 l = normalize(lightPos-p);
        vec3 n = GetNormal(p);
        float dif = clamp(dot(n, l), 0., 1.);
        float d = RayMarch(p+n*SURF_DIST*2., l);
        if(d<length(lightPos-p)) dif *= .1;
        return dif;
    }

    vec3 getSky(vec2 uv) {
      float atmosphere = sqrt(1.0-uv.y);
      vec3 skyColor = vec3(0.2,0.4,0.8);
      return mix(skyColor,vec3(.6, .2, .5),atmosphere / 1.3);
    }

    vec3 render(vec2 coord) {
      vec2 uv = coord / dim;
      vec3 col = getSky(uv);
      vec3 ro = vec3(0, 1, 0);
      vec3 rd = normalize(vec3(uv.x, uv.y, 1));
      float d = RayMarch(ro, rd);
      if (d < MAX_DIST) {
        vec3 p = ro + rd * d;
        float dif = GetLight(p);
        col = vec3(dif);
      }
      return col;
    }

    void main () {
      vec2 coord = fragCoord * size;
      vec3 col = render(coord);
      col += // Anti aliasing
        render(coord+vec2(1.0, 1.0))+
        render(coord+vec2(1.0, 0.0))+
        render(coord+vec2(0.0, 1.0));
      col /= 4.;
      col = pow(col, vec3(.4545));	// gamma correction
      gl_FragColor = vec4(col, 1.0);
    }
  |]

