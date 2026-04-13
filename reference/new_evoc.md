# Construct an Evoc object

Construct an Evoc object

## Usage

``` r
new_evoc(cluster_layers, membership_strengths, persistence_scores, knn)
```

## Arguments

- cluster_layers:

  List of integer vectors.

- membership_strengths:

  List of numeric vectors.

- persistence_scores:

  Numeric vector.

- knn:

  Optional `NearestNeighbours` object or NULL.

## Value

An `Evoc` S3 object.
