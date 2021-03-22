module Example.Example exposing (Example, sortBySearch, examples)

import Time


type alias Example
  = {   title : String
      , link : String
      , description : String
      , keywords : List ( String )
      , code : String
      , date : Time.Posix
  }



sortBySearch : String -> List ( Example )
sortBySearch search = List.sortBy (score search) examples


score : String -> Example -> Int
score search example = 1

examples : List (Example)
examples = [
    {title = "title", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw1", "kw2"],
            code = "code1",
            date = Time.millisToPosix 0}
  , {title = "title", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw1", "kw3"],
            code = "code2",
            date = Time.millisToPosix 0}
  ]


