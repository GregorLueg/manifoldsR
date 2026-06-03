# Rust-based EVoC clustering

Performs EVoC (Embedding Vector Oriented Clustering) on the input data.
Combines a UMAP-like node embedding with HDBSCAN-style density-based
clustering and multi-layer persistence analysis.

## Usage

``` r
evoc(
  data,
  knn = NULL,
  n_neighbours = 15L,
  knn_method = c("kmknn", "hnsw", "annoy", "nndescent", "balltree", "ivf", "exhaustive"),
  nn_params = params_nn(),
  evoc_params = params_evoc(),
  return_knn = FALSE,
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to cluster, of shape samples
  x features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, EVoC will skip the
  kNN graph generation and use this one. Defaults to `NULL`.

- n_neighbours:

  Integer. Number of nearest neighbours for graph construction. Defaults
  to `15L`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- evoc_params:

  Named list. EVoC algorithm parameters, see
  [`params_evoc()`](https://gregorlueg.github.io/manifoldsR/reference/params_evoc.md).

- return_knn:

  Logical. Whether to return the kNN graph. If `knn` is provided, it is
  returned as-is. Defaults to `FALSE`.

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- use_high_precision:

  Optional boolean. Gives fine-grained control over `fp32` vs `fp64`
  usage.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

An `Evoc` S3 object (see
[print.Evoc](https://gregorlueg.github.io/manifoldsR/reference/print.Evoc.md),
[best_membership](https://gregorlueg.github.io/manifoldsR/reference/best_membership.md),
[get_layer](https://gregorlueg.github.io/manifoldsR/reference/get_layer.md)).
