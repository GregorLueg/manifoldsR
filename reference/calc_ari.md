# Adjusted Rand index calculation

Calculates the adjusted Rand index between two sets of cluster
assignments.

## Usage

``` r
calc_ari(members_a, members_b)
```

## Arguments

- members_a:

  Integer vector. Membership/assignment of the first clustering
  algorithm.

- members_b:

  Integer vector. Membership/assignment of the second clustering
  algorithm.

## Value

Adjusted Rand index

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
calc_ari(membership(km), d$membership)
#> [1] 0.2614975
```
