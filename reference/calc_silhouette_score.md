# Calculates the Silhouette score of a given clustering

If the membership has only one group, the function will return `NaN` for
`mean_silhouette` and `silhouette_scores`.

## Usage

``` r
calc_silhouette_score(data, membership)
```

## Arguments

- data:

  Numerical matrix. Samples x features. The matrix that was used to
  generate the clustering.

- membership:

  Integer vector. Membership/assignment of the clustering algorithm.

## Value

A list with the following items:

- mean_silhouette - The average Silhouette scores across all the data
  points.

- silhouette_scores - The individual Silhouette scores of all the data
  points.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
res <- calc_silhouette_score(d$data, membership(km))
res$mean_silhouette
#> [1] 0.3044454
```
