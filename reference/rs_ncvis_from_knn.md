# NCVis implementation with pre-computed kNN

**\[experimental\]** Leverages the NCVis implementation in manifolds-rs.
This version uses a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).
The distances are ignored; NCVis works on the unweighted graph. Graphs
wider than `k` are cut to `k` with a warning.

## Usage

``` r
rs_ncvis_from_knn(
  embd,
  knn_data,
  n_dim,
  min_dist,
  spread,
  k,
  ncvis_params,
  seed,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features. Needed for the PCA
  initialisation.

- knn_data:

  `NearestNeighbours` class from R.

- n_dim:

  Integer. Number of dimensions to return.

- min_dist:

  Numeric. Minimum distance, fits the kernel's `a` and `b`.

- spread:

  Numeric. Spread, fits the kernel's `a` and `b`.

- k:

  Integer. Number of nearest neighbours.

- ncvis_params:

  Named list. List that contains all of the key parameters for the NCVis
  generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The NCVis embeddings.
