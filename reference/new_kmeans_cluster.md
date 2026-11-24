# Construct a KMeansCluster object

Construct a KMeansCluster object

## Usage

``` r
new_kmeans_cluster(centroids, assignments, k, method, metric)
```

## Arguments

- centroids:

  Numeric matrix of shape k x features.

- assignments:

  Integer vector of length samples (1-indexed).

- k:

  Integer. Number of clusters.

- method:

  Character. One of `"emeans"`, `"lloyd"` or `"minibatch"`.

- metric:

  Character. Distance metric used.

## Value

A `KMeansCluster` S3 object.
