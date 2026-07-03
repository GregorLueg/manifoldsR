# Generate a k-nearest neighbour graph.

This function generates a kNN graph based on a given numeric matrix.
Seven different algorithms are implemented with different speed and
accuracy trade-offs:

- `"hnsw"` - Hierarchical Navigable Small Worlds vector search with
  slower index generation (which ammortises on larger data sets) and
  high precision.

- `"annoy"` - Approximate Nearest Neighbours Oh Yeah algorithm, faster
  to index but querying on large data sets can be slow.

- `"nndescent"` - Rust-based implementation of the PyNNDescent
  algorithm, a good all-rounder that performs well on very large data
  sets.

- `"balltree"` - Ball tree structure for exact search with a
  configurable budget.

- `"ivf"` - Inverted file index that leverages k-means clustering and
  probing a few of the clusters.

- `"exhaustive"` - Exact nearest neighbour search.

- `"kmknn"` - Fast exact nearest neighbour search using triangle
  inequality

## Usage

``` r
generate_knn_graph(
  data,
  k,
  knn_method = c("kmknn", "hnsw", "annoy", "nndescent", "balltree", "ivf", "exhaustive"),
  nn_params = params_nn(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numeric matrix. The embedding or feature matrix to compute neighbours
  on. Rows are observations, columns are features.

- k:

  Integer. The number of nearest neighbours to compute.

- knn_method:

  Character. The algorithm to use for nearest neighbour search. One of
  `c("kmknn", "hnsw", "annoy", "nndescent", "balltree", "ivf", "exhaustive")`.
  Defaults to `"kmknn"`.

- nn_params:

  List. Output of
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).
  Controls algorithm-specific parameters.

- seed:

  Integer. For reproducibility. Defaults to `42L`.

- .verbose:

  Boolean. Controls verbosity.

## Value

A nearest neighbours class object with 1-indexed neighbour indices and
distances.
