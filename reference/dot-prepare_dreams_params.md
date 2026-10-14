# Internal helper to prepare the DREAMS parameters

DREAMS takes the same parameters as t-SNE plus `lambda`, so this
delegates to
[`.prepare_tsne_params()`](https://gregorlueg.github.io/manifoldsR/reference/dot-prepare_tsne_params.md)
and appends it.

## Usage

``` r
.prepare_dreams_params(knn_method, nn_params, tsne_params, dreams_params)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- tsne_params:

  Named list. The t-SNE-specific parameters.

- dreams_params:

  Named list. The DREAMS parameters.

## Value

Returns the list of final parameters.
