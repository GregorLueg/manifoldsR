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
  knn_method = c("ivf", "nndescent", "kmknn", "balltree", "hnsw", "annoy", "exhaustive"),
  nn_params = params_nn(),
  pacmap_params = params_pacmap(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, PaCMAP will skip the
  k-nearest neighbour graph generation and use this one. Needs at least
  `n_near` neighbours, and the near pairs are ranked from what it holds,
  so build it `n_near + 50` wide to match the internal search. Defaults
  to `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Defaults to
  `2L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"ivf"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- pacmap_params:

  Named list. PaCMAP algorithm parameters, see
  [`params_pacmap()`](https://gregorlueg.github.io/manifoldsR/reference/params_pacmap.md).
  Controls near/mid-near/further pair counts. The kNN search runs
  `n_near + 50` wide and the near pairs are the best of those by locally
  scaled distance.

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical or integer. Controls verbosity. `TRUE` or `1L` prints timed
  stages and epochs every 50, `2L` adds parameters and the kNN
  internals, `FALSE` or `0L` is silent. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the PaCMAP
embedding.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- pacmap(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
