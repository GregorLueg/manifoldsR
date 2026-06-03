# PaCMAP implementation with pre-computed kNN

This is the wrapper function into the Rust interface for PaCMAP and can
use a pre-computed kNN.

## Usage

``` r
rs_pacmap_from_knn(
  embd,
  knn_data,
  n_dim,
  k,
  pacmap_params,
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

- pacmap_params:

  Named list. List that contains all of the key parameters for the
  PaCMAP generation.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The PaCMAP embeddings.
