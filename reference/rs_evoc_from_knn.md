# EVoC clustering from pre-computed kNN

Wrapper function into the Rust interface for EVoC clustering using a
pre-computed kNN graph.

## Usage

``` r
rs_evoc_from_knn(embd, knn_data, n_neighbours, evoc_params, seed, verbose)
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

- verbose:

  Boolean. Controls verbosity of the function.

## Value

A named list with cluster layers, membership strengths, persistence
scores, and the kNN graph.
