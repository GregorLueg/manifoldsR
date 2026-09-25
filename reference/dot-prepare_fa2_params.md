# Internal helper to prepare the ForceAtlas2 parameters

Internal helper to prepare the ForceAtlas2 parameters

## Usage

``` r
.prepare_fa2_params(knn_method, nn_params, fa2_params)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- fa2_params:

  Named list. The ForceAtlas2-specific parameters.

## Value

Returns the list of final parameters.
