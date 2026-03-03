# Internal helper to prepare the PHATE parameters

Internal helper to prepare the PHATE parameters

## Usage

``` r
.prepare_phate_params(knn_method, nn_params, phate_params)
```

## Arguments

- knn_method:

  Character. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- phate_params:

  Named list. The PHATE-specific parameters.

## Value

Returns the merged list of final parameters.
