module CubeSoftShadow exposing (main, metadata)



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
  title = "Colored Cube",
  link = "ColoredCube",
  keywords = ["ray marching", "webgl"],
  description = "Colored cube drawing in webgl with ray marching",
  code = "https://github.com/etnnth/onkrul/blob/main/src/ColoredCube.elm",
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
  { title = "Cubes"
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
    const float SURF_DIST = .01;
    const float MAX_DIST = 50.;
    const int MAX_STEPS = 100;

    struct Surface {
      float sd; // signed distance value
      vec3 col; // color
    };

    Surface min(Surface obj1, Surface obj2) {
      if (obj2.sd < obj1.sd) return obj2; 
      // The sd component of the struct holds the "signed distance" value
      return obj1;
    }

    vec3 rotation (vec3 p, vec3 axis, float angle) {
      vec4 r = vec4(0., 0., 0., 0.);
      float half_angle = angle/2.;
      r.xyz = axis.xyz * sin(half_angle);
      r.w = cos(half_angle);
      vec3 temp = cross(r.xyz, p) + r.w * p;
      return p + 2.0*cross(r.xyz, temp);
      }

    float box( vec3 p, vec3 b) {
      vec3 q = abs(p) - b;
      return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) -.01;
    }

    Surface cube (vec3 p) {
      vec3 u = rotation (p-vec3(0.,3.,1.), normalize(vec3(1.)), 1.6);
      u = rotation(u, vec3(0., 0., 1), time * .001);
      return Surface(box(u,vec3(1.)), vec3(.8, .2, .2));
      }

    Surface GetDist(vec3 p) {
      Surface f = Surface(p.y + 2., vec3(.2, .5, .3));
      Surface w = Surface(10. - length(p), vec3(.2, .3, .3));
      return min (cube (p), min(f, w));
    }

    Surface RayMarch(vec3 ro, vec3 rd) {
      float dO=0.;
      vec3 p = ro + rd*dO;
      Surface dS = GetDist(p);
      for(int i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;
        dS = GetDist(p);
        dO += dS.sd*.8;
        if(dO>MAX_DIST || dS.sd<SURF_DIST ) break;
      }
      return Surface(dO, dS.col);
    }

    vec3 GetNormal(vec3 p) {
      Surface s = GetDist(p);
      float d = s.sd;
      vec2 e = vec2(.01, 0);
      vec3 n = d - vec3(
          GetDist(p-e.xyy).sd,
          GetDist(p-e.yxy).sd,
          GetDist(p-e.yyx).sd);
      return normalize(n);
    }

    float GetLight(vec3 p) {
        vec3 lightPos = vec3(3, 6, -2);
        vec3 l = normalize(lightPos-p);
        vec3 n = GetNormal(p);
        float dif = clamp(dot(n, l), 0., 1.) * .7 + .3;
        Surface s = RayMarch(p+n*SURF_DIST*2., l);
        if(s.sd<length(lightPos-p)) dif = .3;
        return dif;
    }

    vec3 render(vec2 coord) {
      vec2 uv = coord / dim;
      vec3 col = vec3(.1, .2, .6);
      vec3 ro = vec3(0., 2.5, -4);
      vec3 rd = normalize(vec3(uv.x, uv.y, 1));
      Surface s = RayMarch(ro, rd);
      if (s.sd < MAX_DIST) {
        vec3 p = ro + rd * s.sd;
        col = GetLight(p)*s.col;
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

