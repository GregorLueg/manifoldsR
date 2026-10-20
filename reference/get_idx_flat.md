# Get the indices as a flat vector

Get the indices as a flat vector

## Usage

``` r
get_idx_flat(x)

# S3 method for class 'NearestNeighbours'
get_idx_flat(x)
```

## Arguments

- x:

  `NearestNeighbours` class

## Value

The indices in a flat format like
`c(idx1.1, idx1.2, ... , idx.2.1, idx2.2, ... idx3.1, idx3.2)`

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
knn <- generate_knn_graph(d$data, k = 15L, .verbose = FALSE)
head(get_idx_flat(knn))
#> [1] 347  34 279  79 407 125
```
