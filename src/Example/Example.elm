module Example.Example exposing (Example, sortBySearch, examples, distance, nextRow)

import Time
import List


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
  , {title = "title", 
            link = "link", 
            description = "description blabla", 
            keywords = ["kw2", "kw3"],
            code = "code2",
            date = Time.millisToPosix 0}
  ]

{-
  https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm
          k  i  t  t  e  n
       0  1  2  3  4  5  6
    s  1  1  2  3  4  5  6
    i  2  2  1  2  3  4  5
    t  3  3  2  1  2  3  4
    t  4  4  3  2  1  2  3
    i  5  5  4  3  2  2  3
    n  6  6  5  4  3  3  2
    g  7  7  6  5  4  4  3

    substitutionCost = s1[i] != s2[j]

    d[i, j] := minimum(d[i-1, j] + 1,                   // deletion
                       d[i, j-1] + 1,                   // insertion
                       d[i-1, j-1] + substitutionCost)  // substitution

-}

distance : String -> String -> Int
distance s1 s2 =
  let 
    next = nextRow (String.toList s1)
    r1 = List.range 1 (String.length s1) 
    r2 = List.range 0 (String.length s2)
    last = List.foldl next r1 (List.map2 Tuple.pair r2 (String.toList s2))
  in
  case List.reverse last of
    [] -> 0
    l::_ -> l


nextRow : List (Char) -> (Int, Char) -> List (Int) -> List (Int)
nextRow chars idch previousRow = 
  let
    (index, char) = idch
    comparison = List.map (\c-> if c == char then 0 else 1) chars 
    diagonal = List.map2 (+) comparison (index::previousRow)
    fromPreviousRow = List.map2 min diagonal (List.map (\n -> n+1) previousRow) 
    f n row =
      case row of
        [] -> [n] -- [min n (index + 2)] n for the first element cannot be bigger than index + 1
        x::xs -> (min n (x+1)) :: row
  in
  List.reverse ( List.foldl f [] fromPreviousRow ) 

