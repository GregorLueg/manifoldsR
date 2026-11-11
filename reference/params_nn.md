# Wrapper function to generate nearest neighbour parameters

Wrapper function to generate nearest neighbour parameters

## Usage

``` r
params_nn(
  dist_metric = c("euclidean", "cosine"),
  n_tree = 50L,
  search_budget = NULL,
  m = 16L,
  ef_construction = 200L,
  ef_search = 100L,
  delta = 0.001,
  bt_budget = 0.1,
  n_list = NULL,
  n_probes = NULL
)
```

## Arguments

- dist_metric:

  String. The distance metric to use. One of `c("euclidean", "cosine")`.
  Defaults to `"euclidean"`.

- n_tree:

  Integer. Number of trees for Annoy. Defaults to `50L`.

- search_budget:

  Integer or `NULL`. Search budget for Annoy. If `NULL`, uses
  `k * n_tree * 20`. Defaults to `NULL`.

- m:

  Integer. Number of bidirectional links for HNSW. Defaults to `16L`.

- ef_construction:

  Integer. Size of the dynamic candidate list during HNSW construction.
  Defaults to `200L`.

- ef_search:

  Integer. Size of the dynamic candidate list during HNSW search.
  Defaults to `100L`.

- delta:

  Numeric. Precision parameter for NN descent. Defaults to `0.001`.

- bt_budget:

  Numeric. Budget for ball tree search. Defaults to `0.1`.

- n_list:

  Integer or `NULL`. Number of clusters to use for IVF. If `NULL`, uses
  `sqrt(n)`. Defaults to `NULL`.

- n_probes:

  Integer or `NULL`. Number of clusters to probe for IVF. If `NULL`,
  uses `sqrt(n_list)`. Defaults to `NULL`.

## Value

A named list with the following elements:

- dist_metric - String. The distance metric to use. One of
  `c("euclidean", "cosine")`. Defaults to `"euclidean"`.

- n_tree - Integer. Number of trees for Annoy. Defaults to `50L`.

- search_budget - Integer or `NULL`. Search budget for Annoy. If `NULL`,
  uses `k * n_tree * 20`. Defaults to `NULL`.

- m - Integer. Number of bidirectional links for HNSW. Defaults to
  `16L`.

- ef_construction - Integer. Size of the dynamic candidate list during
  HNSW construction. Defaults to `200L`.

- ef_search - Integer. Size of the dynamic candidate list during HNSW
  search. Defaults to `100L`.

- delta - Numeric. Precision parameter for NN descent. Defaults to
  `0.001`.

- bt_budget - Numeric. Budget for ball tree search. Defaults to `0.1`.

- n_list - Integer or `NULL`. Number of clusters to use for IVF. If
  `NULL`, uses `sqrt(n)`. Defaults to `NULL`.

- n_probes - Integer or `NULL`. Number of clusters to probe for IVF. If
  `NULL`, uses `sqrt(n_list)`. Defaults to `NULL`.

## Examples

``` r
params_nn()
#> $dist_metric
#> [1] "euclidean"
#> 
#> $n_tree
#> [1] 50
#> 
#> $search_budget
#> NULL
#> 
#> $m
#> [1] 16
#> 
#> $ef_construction
#> [1] 200
#> 
#> $ef_search
#> [1] 100
#> 
#> $delta
#> [1] 0.001
#> 
#> $bt_budget
#> [1] 0.1
#> 
#> $n_list
#> NULL
#> 
#> $n_probes
#> NULL
#> 
params_nn(dist_metric = "cosine", ef_search = 200L)
#> $dist_metric
#> [1] "cosine"
#> 
#> $n_tree
#> [1] 50
#> 
#> $search_budget
#> NULL
#> 
#> $m
#> [1] 16
#> 
#> $ef_construction
#> [1] 200
#> 
#> $ef_search
#> [1] 200
#> 
#> $delta
#> [1] 0.001
#> 
#> $bt_budget
#> [1] 0.1
#> 
#> $n_list
#> NULL
#> 
#> $n_probes
#> NULL
#> 
```
