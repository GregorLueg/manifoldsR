# Calculates the cluster silhouette scores

**\[experimental\]** Calculates the Silhouette in Rust given the
original data and a membership vector. `a(i)` and `b(i)` are mean
**squared** Euclidean distances, which keeps the whole thing closed-form
and avoids materialising any pairwise distance. The trade-off is that
the scores are not the numbers a plain-Euclidean silhouette gives:
squaring inflates `b` more than `a`, so the values run higher. The sign
is unaffected, so which points sit in the wrong cluster is the same
call, but do not compare the magnitudes against implementations that use
plain Euclidean.

## Usage

``` r
rs_silhouette_score(data, cluster_membership)
```

## Arguments

- data:

  Numeric matrix. The data in shape of sample x features.

- cluster_membership:

  Integers. Cluster memberships as integers.

## Value

A list with the following items

- mean_silhouette - Mean silhouette scores per cluster.

- silhouette_scores - Silhouette scores per given data point.
