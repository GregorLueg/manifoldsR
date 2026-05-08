# Internal helper to prepare the diffusion maps parameters

Internal helper to prepare the diffusion maps parameters

## Usage

``` r
.prepare_diffusion_maps_params(knn_method, nn_params, dm_params)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- dm_params:

  Named list. The diffusion maps specific parameters.

## Value

Returns the list of final parameters.
