# Generate a new NearestNeighbours

Generate a new NearestNeighbours

## Usage

``` r
new_nearest_neighbour(indices, dist, k, n)

generate_nearest_neigbours_class(indices, dist, k, n)
```

## Arguments

- indices:

  Integer. Nearest neighbours in flat storage format. Need to be sorted!

- dist:

  Numeric. Nearest neighbour distances in flat storarge format. Need to
  be sorted! On the scale of the metric they were generated with, i.e.
  Euclidean rather than squared Euclidean.

- k:

  Integer. Number of k-neighbours per sample.

- n:

  Integer. Number of samples.

## Value

Initialised `NearestNeighbours` class.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
knn <- generate_knn_graph(d$data, k = 15L, .verbose = FALSE)
knn2 <- new_nearest_neighbour(
  indices = get_idx_flat(knn),
  dist = get_dist_flat(knn),
  k = 15L,
  n = 500L
)
knn2
#> NearestNeighbours
#>   n_samples:    500 
#>   k_neighbours: 15 
```
