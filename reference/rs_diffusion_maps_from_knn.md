# Diffusion maps implementation with pre-computed kNN

**\[experimental\]** Leverages the Diffusion Maps implementation in
manifolds-rs - a very fast Rust-based implementation. This version uses
a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_diffusion_maps_from_knn(
  embd,
  knn_data,
  n_dim,
  k,
  dm_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- knn_data:

  `NearestNeighbours` class from R.

- n_dim:

  Integer. Number of dimensions to return.

- k:

  Integer. Number of nearest neighbours to consider.

- dm_params:

  Named list. List that contains all of the key parameters for the
  diffusion maps generation.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The diffusion maps embeddings.
