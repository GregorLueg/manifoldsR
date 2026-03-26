# Internal helper to prepare the PaCMAP parameters

Internal helper to prepare the PaCMAP parameters

## Usage

``` r
.prepare_pacmap_params(knn_method, nn_params, pacmap_params, .verbose = TRUE)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- pacmap_params:

  Named list. The PaCMAP-specific parameters.

- .verbose:

  Boolean. Controls verbosity.

## Value

Returns the list of final parameters.
