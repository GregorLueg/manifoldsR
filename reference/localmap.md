# Rust-based LocalMAP

Performs LocalMAP dimensionality reduction on the input data. LocalMAP
is PaCMAP with a different last phase: the mid-near pairs drop out and
every point redraws its further pairs from within `max_distance` in the
embedding. That local repulsion pulls apart clusters PaCMAP leaves
touching. Unlike NCVis or the Hogwild! UMAP optimisers, the result is
the same at a given seed whatever the number of threads.

## Usage

``` r
localmap(
  data,
  knn = NULL,
  n_dim = 2L,
  knn_method = c("ivf", "nndescent", "kmknn", "balltree", "hnsw", "annoy", "exhaustive"),
  nn_params = params_nn(),
  localmap_params = params_localmap(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, LocalMAP will skip
  the k-nearest neighbour graph generation and use this one. Needs at
  least `n_near` neighbours, and the near pairs are ranked from what it
  holds, so build it `n_near + 50` wide to match the internal search.
  Defaults to `NULL`.

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

- localmap_params:

  Named list. LocalMAP algorithm parameters, see
  [`params_localmap()`](https://gregorlueg.github.io/manifoldsR/reference/params_localmap.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical or integer. Controls verbosity. `TRUE` or `1L` prints timed
  stages and epochs every 50, `2L` adds parameters and the kNN
  internals, `FALSE` or `0L` is silent. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the
LocalMAP embedding.

## References

Wang, et al., arXiv:2412.15426, 2024

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- localmap(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
