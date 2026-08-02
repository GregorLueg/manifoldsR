# Check density-preservation parameters

Checkmate extension for checking the density-preservation parameters.
Shared by densMAP and den-SNE, which take the same three knobs and
differ only in the default `lambda`.

## Usage

``` r
checkDensParams(x)
```

## Arguments

- x:

  The list to check.

## Value

`TRUE` if the check was successful, otherwise an error message.
