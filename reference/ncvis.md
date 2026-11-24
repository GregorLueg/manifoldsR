# Rust-based NCVis

Performs NCVis dimensionality reduction on the input data. NCVis runs
noise-contrastive SGD on the unweighted kNN graph: every edge pulls, a
handful of random negatives per edge push, and a learnt normalisation
constant `Q` replaces UMAP's fixed repulsion weight. The defaults are
the NCVis+ ones (PCA start, `min_dist = 0.001`, learning rate `2`, 10
negatives per edge). The optimiser is Hogwild! SGD, so the result is
only reproducible at a fixed seed on a single thread.

## Usage

``` r
ncvis(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 15L,
  min_dist = 0.001,
  spread = 1,
  knn_method = c("nndescent", "kmknn", "balltree", "hnsw", "annoy", "exhaustive", "ivf"),
  nn_params = params_nn(),
  ncvis_params = params_ncvis(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, NCVis will skip the
  k-nearest neighbour graph generation and use this one. The distances
  are ignored. A wider graph is cut to `k`, with a warning on stderr.
  Defaults to `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Defaults to
  `2L`.

- k:

  Integer. Number of nearest neighbours. Defaults to `15L`.

- min_dist:

  Numeric. Minimum distance between points in the embedding, fits the
  `a` and `b` of the kernel like in UMAP. Must be \>= 0. Defaults to
  `0.001`.

- spread:

  Numeric. Effective scale of embedded points, fits the `a` and `b` of
  the kernel. Defaults to `1.0`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"nndescent"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- ncvis_params:

  Named list. NCVis algorithm parameters, see
  [`params_ncvis()`](https://gregorlueg.github.io/manifoldsR/reference/params_ncvis.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical or integer. Controls verbosity. `TRUE` or `1L` prints timed
  stages, `2L` adds parameters and the kNN internals, `FALSE` or `0L` is
  silent. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the NCVis
embedding.

## References

Artemenkov & Panov, WWW, 2020; Pedersen, NCVis+, 2026
(https://github.com/SeanPedersen/ncvis-plus)

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- ncvis(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
