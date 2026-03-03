# Internal helper to prepare the UMAP parameters

Internal helper to prepare the UMAP parameters

## Usage

``` r
.prepare_umap_params(
  n,
  min_dist,
  spread,
  knn_method,
  nn_params,
  umap_params,
  .verbose = TRUE
)
```

## Arguments

- n:

  Integer. Number of samples in the data set

- min_dist:

  Numeric. Minimum distance between embedded points.

- spread:

  Numeric. Effective scale of embedded points.

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- umap_params:

  Named list. The UMAP-specific parameters.

- .verbose:

  Boolean. Controls verbosity

## Value

Returns the list of final parameters.
