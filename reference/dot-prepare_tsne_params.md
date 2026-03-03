# Internal helper to prepare the t-SNE parameters

Internal helper to prepare the t-SNE parameters

## Usage

``` r
.prepare_tsne_params(knn_method, nn_params, tsne_params)
```

## Arguments

- knn_method:

  String. Method to use to generate the kNN graph.

- nn_params:

  Named list. The nearest neighbour search parameters.

- tsne_params:

  Named list. The t-SNE-specific parameters.

## Value

Returns the list of final parameters.
