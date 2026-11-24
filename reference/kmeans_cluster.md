# K-means clustering

Performs k-means clustering on the input data. Three methods: e-means
(the default), full Lloyd's iterations (with SIMD/GEMM acceleration) and
Sculley's mini-batch k-means. e-means runs mini-batch EMA updates with a
batch size and step fitted to the data, and matches or beats Lloyd's
loss in a handful of passes over the data.

## Usage

``` r
kmeans_cluster(
  data,
  k,
  method = c("emeans", "lloyd", "minibatch"),
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

  Character. Clustering method. One of `"emeans"` (e-means), `"lloyd"`
  (Lloyd's algorithm) or `"minibatch"` (Sculley's mini-batch k-means).
  `"full"` is a deprecated alias of `"lloyd"`. Defaults to `"emeans"`.

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

## References

Bessa, et al., arXiv:2611.09501, 2026 (e-means)

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
km
#> KMeansCluster
#>   method:     emeans 
#>   metric:     euclidean 
#>   k:          4 
#>   n:          500 
#>   sizes:      min= 0  median= 39  max= 121 
```
