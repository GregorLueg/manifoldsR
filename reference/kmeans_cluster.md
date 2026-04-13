# K-means clustering

Performs k-means clustering on the input data. Supports both full
Lloyd's iterations (with SIMD/GEMM acceleration) and mini-batch k-means
for large data sets.

## Usage

``` r
kmeans_cluster(
  data,
  k,
  method = c("full", "minibatch"),
  kmeans_params = params_kmeans(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to cluster, of shape samples
  x features. Will be coerced to a matrix.

- k:

  Integer. Number of clusters to create. Must be \>= 2.

- method:

  Character. Clustering method. One of `"full"` (Lloyd's algorithm) or
  `"minibatch"` (mini-batch k-means). Defaults to `"full"`.

- kmeans_params:

  Named list. K-means parameters, see
  [`params_kmeans()`](https://gregorlueg.github.io/manifoldsR/reference/params_kmeans.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A named list with:

- centroids:

  Numeric matrix of shape k x features containing the final cluster
  centroids.

- assignments:

  Integer vector of length samples with cluster assignments (1-indexed).
