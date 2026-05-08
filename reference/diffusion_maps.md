# Rust-based diffusion maps

Performs diffusion maps dimensionality reduction on the input data. This
function provides a user-friendly interface with input validation before
calling the Rust implementation.

## Usage

``` r
diffusion_maps(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 5L,
  knn_method = c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive"),
  nn_params = params_nn(),
  dm_params = params_diffusion_maps(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, diffusion maps will
  skip the k-nearest neighbour graph generation and use this one.
  Defaults to `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Defaults to
  `2L`.

- k:

  Integer. Number of nearest neighbours to consider for the affinity
  graph. Defaults to `5L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, or
  `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- dm_params:

  Named list. Diffusion maps algorithm parameters, see
  [`params_diffusion_maps()`](https://gregorlueg.github.io/manifoldsR/reference/params_diffusion_maps.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the
diffusion maps embedding.
