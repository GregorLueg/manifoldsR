# Rust-based ForceAtlas2

Lays out the kNN graph of the data with ForceAtlas2, the way scanpy's
`draw_graph` does: the kNN graph is turned into the UMAP fuzzy union
graph and every edge pulls, every node pair pushes (`1/d`, with masses
`1 + degree`), plus gravity towards the origin. Repulsion runs on a
Barnes-Hut tree. Already have a graph? Use
[`forceatlas2_from_graph()`](https://gregorlueg.github.io/manifoldsR/reference/forceatlas2_from_graph.md).

## Usage

``` r
forceatlas2(
  data,
  knn = NULL,
  k = 15L,
  knn_method = c("nndescent", "kmknn", "balltree", "hnsw", "annoy", "exhaustive", "ivf"),
  nn_params = params_nn(),
  fa2_params = params_fa2(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, the k-nearest
  neighbour search is skipped and this one is used. A wider graph is cut
  to `k`, with a warning on stderr. Defaults to `NULL`.

- k:

  Integer. Number of nearest neighbours. Defaults to `15L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"nndescent"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- fa2_params:

  Named list. ForceAtlas2 parameters, see
  [`params_fa2()`](https://gregorlueg.github.io/manifoldsR/reference/params_fa2.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- .verbose:

  Logical or integer. Controls verbosity. `TRUE` or `1L` prints timed
  stages and epochs every 50, `2L` adds parameters and the kNN
  internals, `FALSE` or `0L` is silent. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x 2 containing the
ForceAtlas2 layout.

## References

Jacomy, et al., PLoS ONE, 2014

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- forceatlas2(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
