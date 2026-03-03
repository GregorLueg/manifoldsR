# Check cell trajectory parameters

Checkmate extension for checking the cell trajectory parameters.

## Usage

``` r
checkCellTrajectories(x)
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

## Value

`TRUE` if the check was successful, otherwise an error message.
