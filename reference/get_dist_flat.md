# Get the distances as a flat vector

Get the distances as a flat vector

## Usage

``` r
get_dist_flat(x)

# S3 method for class 'NearestNeighbours'
get_dist_flat(x)
```

## Arguments

- x:

  `NearestNeighbours` class

## Value

The distances in a flat format like
`c(dist1.1, dist1.2, ... , dist2.1, dist2.2, ... dist3.1, dist3.2)`

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
knn <- generate_knn_graph(d$data, k = 15L, .verbose = FALSE)
head(get_dist_flat(knn))
#> [1] 7.293975 7.875093 8.291838 8.783191 8.848424 9.047078
```
