# UMAP implementation

This is the wrapper function into the Rust interface for UMAP and can
use a pre-computed kNN.

## Usage

``` r
rs_umap_from_knn(
  embd,
  knn_data,
  n_dim,
  min_dist,
  spread,
  k,
  umap_params,
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

  Integer. Number of UMAP dimensions to return.

- min_dist:

  Numeric. Minimum distance to use.

- spread:

  Numeric. Spread parameter to use.

- k:

  Integer. Number of nearest neighbours to consider

- umap_params:

  Named list. List that contains all of the key parameters for the UMAP
  generation.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The UMAP embeddings.
