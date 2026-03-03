# Rust-based UMAP

Performs UMAP dimensionality reduction on the input data. This function
provides a user-friendly interface with input validation before calling
the Rust implementation.

## Usage

``` r
umap(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 15L,
  min_dist = 0.5,
  spread = 1,
  knn_method = c("balltree", "hnsw", "annoy", "nndescent", "exhaustive"),
  nn_params = params_nn(),
  umap_params = params_umap(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, UMAP will skip the
  k-nearest neighbour graph generation and use this one. Defaults to
  `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Defaults to
  `2L`.

- k:

  Integer. Number of nearest neighbours to consider for manifold
  approximation. Larger values result in more global structure being
  preserved. Defaults to `15L`.

- min_dist:

  Numeric. Minimum distance between points in the embedding. Controls
  how tightly points are packed. Smaller values result in more clustered
  embeddings. Must be \>= 0. Defaults to `0.5`. If you use SGD, consider
  reducing this!

- spread:

  Numeric. Effective scale of embedded points. Determines the scale at
  which embedded points will be spread out. Defaults to `1.0`.

- knn_method:

  Character. Approximate nearest neighbour algorithm to use. One of
  `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, or `"exhaustive"`.
  Defaults to `"balltree"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- umap_params:

  Named list. UMAP algorithm parameters, see
  [`params_umap()`](https://gregorlueg.github.io/manifoldsR/reference/params_umap.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the UMAP
embedding.
