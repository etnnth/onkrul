module Index.Metadata exposing (Metadata)

import Time

type alias Metadata
  = {   title : String
      , link : String
      , description : String
      , keywords : List ( String )
      , code : String
      , date : Time.Posix
  }


