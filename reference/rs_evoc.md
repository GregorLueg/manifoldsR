# EVoC clustering

Wrapper function into the Rust interface for EVoC clustering.

## Usage

``` r
rs_evoc(
  embd,
  n_neighbours,
  evoc_params,
  return_knn,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to cluster. Should be of dimensions samples
  x features.

- n_neighbours:

  Integer. Number of nearest neighbours for graph construction.

- evoc_params:

  Named list. List that contains all of the key parameters for EVoC
  clustering.

- return_knn:

  Boolean. Shall the kNN graph be returned.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

A named list with:

- evoc_res - List with the EVoC results

- knn - Optional list (can be NULL) with the kNN graph
