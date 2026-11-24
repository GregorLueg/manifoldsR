# Internal helper to prepare the LocalMAP parameters

Internal helper to prepare the LocalMAP parameters

## Usage

``` r
.prepare_localmap_params(
  knn_method,
  nn_params,
  localmap_params,
  .verbose = TRUE
)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- localmap_params:

  Named list. The LocalMAP-specific parameters.

- .verbose:

  Logical or integer `0L` to `2L`. Controls verbosity.

## Value

Returns the list of final parameters.
