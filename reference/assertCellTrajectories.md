# Assert cell trajectory parameters

Checkmate extension for asserting the cell trajectory parameters.

## Usage

``` r
assertCellTrajectories(x, .var.name = checkmate::vname(x), add = NULL)
```

## Arguments

- x:

  The list to check. Must be a named list with the following elements:

  - `parent` - Integer vector. Parent branch index for each branch. Use
    `NA` for the root branch. Indices are zero-based.

  - `split_at` - Numeric vector. Fraction along the parent branch where
    the branch splits off. Must be between 0 and 1.

  - `length` - Numeric vector. Length of each branch.

  All three vectors must be of equal length.

- .var.name:

  Name of the checked object to print in assertions. Defaults to the
  heuristic implemented in checkmate.

- add:

  Collection to store assertion messages. See
  [`checkmate::makeAssertCollection()`](https://mllg.github.io/checkmate/reference/AssertCollection.html).

## Value

Invisibly returns the checked object if the assertion is successful.
