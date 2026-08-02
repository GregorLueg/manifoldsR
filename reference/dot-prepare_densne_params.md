# Internal helper to prepare the den-SNE parameters

den-SNE takes the same parameters as t-SNE plus the three density knobs,
so this delegates to
[`.prepare_tsne_params()`](https://gregorlueg.github.io/manifoldsR/reference/dot-prepare_tsne_params.md)
and appends them.

## Usage

``` r
.prepare_densne_params(knn_method, nn_params, tsne_params, dens_params)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- tsne_params:

  Named list. The t-SNE-specific parameters.

- dens_params:

  Named list. The density-preservation parameters.

## Value

Returns the list of final parameters.
