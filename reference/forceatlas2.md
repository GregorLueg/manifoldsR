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
  knn_method = c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive", "ivf"),
  nn_params = params_nn(),
  fa2_params = params_fa2(),
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

  Optional `NearestNeighbours` class. If provided, the k-nearest
  neighbour search is skipped and this one is used. Defaults to `NULL`.

- k:

  Integer. Number of nearest neighbours. Defaults to `15L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- fa2_params:

  Named list. ForceAtlas2 parameters, see
  [`params_fa2()`](https://gregorlueg.github.io/manifoldsR/reference/params_fa2.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- use_high_precision:

  Optional boolean. Gives fine-grained control over `fp32` vs `fp64`
  usage.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x 2 containing the
ForceAtlas2 layout.

## References

Jacomy, et al., PLoS ONE, 2014
