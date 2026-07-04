# EVoC clustering from pre-computed kNN

**\[experimental\]** Wrapper function into the Rust interface for EVoC
clustering. This version uses a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_evoc_from_knn(
  embd,
  knn_data,
  n_neighbours,
  evoc_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to cluster. Should be of dimensions samples
  x features.

- knn_data:

  List. A NearestNeighbours object with `k`, `indices`, and `dist`
  elements.

- n_neighbours:

  Integer. Number of nearest neighbours for graph construction.

- evoc_params:

  Named list. List that contains all of the key parameters for EVoC
  clustering.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

A named list with cluster layers, membership strengths, persistence
scores, and the kNN graph.
