# Get the indices as a matrix

Get the indices as a matrix

## Usage

``` r
get_idx_mat(x)

# S3 method for class 'NearestNeighbours'
get_idx_mat(x)
```

## Arguments

- x:

  `NearestNeighbours` class

## Value

The indices in samples x neighbours format

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
knn <- generate_knn_graph(d$data, k = 15L, .verbose = FALSE)
dim(get_idx_mat(knn))
#> [1] 500  15
```
