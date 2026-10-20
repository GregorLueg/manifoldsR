# Get a specific EVoC layer

Get a specific EVoC layer

## Usage

``` r
get_layer(x, i)

# S3 method for class 'Evoc'
get_layer(x, i)
```

## Arguments

- x:

  An `Evoc` object.

- i:

  Integer. Layer index to retrieve.

## Value

A named list with `labels`, `membership`, and `persistence` for the
requested layer.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
res <- evoc(d$data, .verbose = FALSE)
str(get_layer(res, 1L))
#> List of 3
#>  $ labels     : int [1:500] 13 10 0 11 10 14 12 2 0 3 ...
#>  $ membership : num [1:500] 0.92 0.126 0.174 0.537 0.331 ...
#>  $ persistence: num 0
```
