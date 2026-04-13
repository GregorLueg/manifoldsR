# Assert k-means parameters

Checkmate extension for asserting the k-means parameters.

## Usage

``` r
assertKmeansParams(x, .var.name = checkmate::vname(x), add = NULL)
```

## Arguments

- x:

  The list to check.

- .var.name:

  Name of the checked object to print in assertions. Defaults to the
  heuristic implemented in checkmate.

- add:

  Collection to store assertion messages. See
  [`checkmate::makeAssertCollection()`](https://mllg.github.io/checkmate/reference/AssertCollection.html).

## Value

Invisibly returns the checked object if the assertion is successful.
