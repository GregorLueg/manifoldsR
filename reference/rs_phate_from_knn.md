# Run PHATE dimensionality reduction from a precomputed kNN graph

**\[experimental\]** Leverages the PHATE implementation in
manifolds-rs - a very fast Rust-based implementation. This version uses
a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_phate_from_knn(
  embd,
  knn_data,
  n_dim,
  k,
  phate_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to embed of shape samples x features.

- knn_data:

  `NearestNeighbours` class from R.

- n_dim:

  Integer. Number of PHATE dimensions to return. Currently only `2L` is
  supported.

- k:

  Integer. Number of nearest neighbours used during graph construction.
  Must match the k used to generate `knn_data`.

- phate_params:

  Named list. Contains all key parameters for PHATE, see
  [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md)
  and
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The PHATE embedding as a matrix of shape samples x n_dim.
