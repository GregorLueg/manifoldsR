# Internal helper to prepare the densMAP parameters

densMAP takes the same parameters as UMAP plus the three density knobs,
so this delegates to
[`.prepare_umap_params()`](https://gregorlueg.github.io/manifoldsR/reference/dot-prepare_umap_params.md)
and appends them.

## Usage

``` r
.prepare_densmap_params(
  n,
  min_dist,
  spread,
  knn_method,
  nn_params,
  umap_params,
  dens_params,
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

- dens_params:

  Named list. The density-preservation parameters.

- .verbose:

  Boolean. Controls verbosity

## Value

Returns the list of final parameters.
