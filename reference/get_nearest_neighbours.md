# Get the kNN graph from an Evoc object

Get the kNN graph from an Evoc object

## Usage

``` r
get_nearest_neighbours(x)

# S3 method for class 'Evoc'
get_nearest_neighbours(x)
```

## Arguments

- x:

  An `Evoc` object.

## Value

A `NearestNeighbours` object, or `NULL` if the kNN was not stored.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
res <- evoc(d$data, return_knn = TRUE, .verbose = FALSE)
get_nearest_neighbours(res)
#> NearestNeighbours
#>   n_samples:    500 
#>   k_neighbours: 15 
```
