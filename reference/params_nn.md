# Wrapper function to generate nearest neighbour parameters

Wrapper function to generate nearest neighbour parameters

## Usage

``` r
params_nn(
  dist_metric = c("euclidean", "cosine"),
  n_tree = 50L,
  search_budget = NULL,
  m = 16L,
  ef_construction = 100L,
  ef_search = 100L,
  diversify_prob = 0,
  delta = 0.001,
  ef_budget = NULL,
  extract_knn = TRUE,
  bt_budget = 0.1,
  n_list = NULL,
  n_probes = NULL
)
```

## Arguments

- dist_metric:

  Character. The distance metric to use. Defaults to `"euclidean"`.

- n_tree:

  Integer. Number of trees for Annoy. Defaults to `50L`.

- search_budget:

  Integer or `NULL`. Search budget for Annoy. Defaults to `NULL`.

- m:

  Integer. Number of bidirectional links for HNSW. Defaults to `16L`.

- ef_construction:

  Integer. Size of the dynamic candidate list during HNSW construction.
  Defaults to `100L`.

- ef_search:

  Integer. Size of the dynamic candidate list during HNSW search.
  Defaults to `100L`.

- diversify_prob:

  Float. Diversification probability for NN descent. Defaults to `0.0`.

- delta:

  Float. Precision parameter for NN descent. Defaults to `0.001`.

- ef_budget:

  Integer or `NULL`. Effort budget for NN descent. Defaults to `NULL`.
  Ignored when `extract_knn` is `TRUE`, as no search runs.

- extract_knn:

  Boolean. Only affects the `"nndescent"` backend. If `TRUE`, the
  descent hands back the graph it just built instead of running a beam
  search over it. Faster, at a recall of roughly `0.98` rather than
  `0.99`-`1.00`. Defaults to `TRUE`.

- bt_budget:

  Float. Budget for ball tree search. Defaults to `0.1`.

- n_list:

  Optional integer. Number of clusters to use for IVF. If `NULL`, will
  default to `sqrt(n)`.

- n_probes:

  Optional integer. Number of clusters to probe for IVF. If `NULL`, will
  default to `sqrt(n_list)`.

## Value

A list with the nearest neighbour parameters.
