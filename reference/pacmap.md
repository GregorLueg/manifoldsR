# Rust-based PaCMAP

Performs PaCMAP dimensionality reduction on the input data. This
function provides a user-friendly interface with input validation before
calling the Rust implementation.

## Usage

``` r
pacmap(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 10L,
  knn_method = c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive"),
  nn_params = params_nn(),
  pacmap_params = params_pacmap(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, PaCMAP will skip the
  k-nearest neighbour graph generation and use this one. Defaults to
  `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Defaults to
  `2L`.

- k:

  Integer. Number of nearest neighbours to consider. Defaults to `10L`.
  Note that the kNN search will use `mn_candidate_end` neighbours
  internally; k only controls the near pairs used in optimisation.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- pacmap_params:

  Named list. PaCMAP algorithm parameters, see
  [`params_pacmap()`](https://gregorlueg.github.io/manifoldsR/reference/params_pacmap.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- use_high_precision:

  Optional boolean. Gives fine-grained control over `fp32` vs `fp64`
  usage.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the PaCMAP
embedding.
