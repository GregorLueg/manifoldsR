# Rust-based PHATE

Performs PHATE dimensionality reduction on the input data. This function
provides a user-friendly interface with input validation before calling
the Rust implementation.

## Usage

``` r
phate(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 5L,
  knn_method = c("ivf", "kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive"),
  nn_params = params_nn(),
  phate_params = params_phate(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, PHATE will skip the
  k-nearest neighbour graph generation and use this one instead. Every
  neighbour in the graph can join the kernel while its affinity clears
  `thresh`, so build the graph `6 * k + 5` wide to match the internal
  search. Defaults to `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Currently only
  `2L` is supported. Defaults to `2L`.

- k:

  Integer. Number of nearest neighbours that set the kernel bandwidth.
  The kNN search itself runs `6 * k + 5` wide. Defaults to `5L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"ivf"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- phate_params:

  Named list. PHATE algorithm parameters, see
  [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical or integer. Controls verbosity. `TRUE` or `1L` prints timed
  stages and epochs every 50, `2L` adds parameters and the kNN
  internals, `FALSE` or `0L` is silent. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the PHATE
embedding.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- phate(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
