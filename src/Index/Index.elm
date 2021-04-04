module Index.Index exposing (index)


import Time
import Index.Metadata exposing (Metadata)
 
index : List (Metadata)
index = [
    {title = "titititiitiiit", 
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
            date = Time.millisToPosix 10}
  , {title = "kitle", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw2", "kw3"],
            code = "code2",
            date = Time.millisToPosix 100}
  ]

