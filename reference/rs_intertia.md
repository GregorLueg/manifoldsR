# Calculates the intertia for k-means clustering

Calculates the intertia for k-means clustering

## Usage

``` r
rs_intertia(data, centroids, cluster_membership)
```

## Arguments

- data:

  Numeric matrix. The data in shape of sample x features.

- centroids:

  Numeric matrix. The centroid data in shape k x features.

- cluster_membership:

  Integers. Cluster memberships as integers.

## Value

The inertia score
