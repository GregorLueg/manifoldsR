# Internal helper to prepare the NCVis parameters

Internal helper to prepare the NCVis parameters

## Usage

``` r
.prepare_ncvis_params(knn_method, nn_params, ncvis_params, .verbose = TRUE)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- ncvis_params:

  Named list. The NCVis-specific parameters.

- .verbose:

  Logical or integer `0L` to `2L`. Controls verbosity.

## Value

Returns the list of final parameters.
