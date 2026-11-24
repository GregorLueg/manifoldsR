# LocalMAP implementation with pre-computed kNN

**\[experimental\]** Leverages the LocalMAP implementation in
manifolds-rs. This version uses a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_localmap_from_knn(embd, knn_data, n_dim, localmap_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- knn_data:

  `NearestNeighbours` class from R. Needs at least `n_near` neighbours,
  and should be `n_near + 50` wide to match the internal search.

- n_dim:

  Integer. Number of dimensions to return.

- localmap_params:

  Named list. List that contains all of the key parameters for the
  LocalMAP generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The LocalMAP embeddings.
