# Calculates the cluster silhouette scores

Uses the squared Euclidean distance under the hood for speed.

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
