module Index.Index exposing (sortIndex)
import Mandelbrot
import Sphere
import Cubes

import Time
import Index.Metadata exposing (Metadata)
import Index.Sort

 
sortIndex = Index.Sort.sortBySearch index

index : List (Metadata)
index = [
    Mandelbrot.metadata,
    Sphere.metadata,
    Cubes.metadata
  ]

