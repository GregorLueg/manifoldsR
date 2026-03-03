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

- verbose:

  Boolean. Controls verbosity of the function.

## Value

The UMAP embeddings.
