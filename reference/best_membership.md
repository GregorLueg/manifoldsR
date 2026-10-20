# Get the cluster membership at the best persistence score

Get the cluster membership at the best persistence score

## Usage

``` r
best_membership(x)

# S3 method for class 'Evoc'
best_membership(x)
```

## Arguments

- x:

  An `Evoc` object.

## Value

A named list with elements `labels` (integer vector of cluster
assignments, `-1` for noise), `membership` (numeric vector of
strengths), `layer` (which layer index was selected), and `persistence`
(the score).

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
res <- evoc(d$data, .verbose = FALSE)
table(best_membership(res)$cluster)
#> < table of extent 0 >
```
