# Wrapper function to generate k-means parameters

Wrapper function to generate k-means parameters

## Usage

``` r
params_kmeans(
  metric = c("euclidean", "cosine"),
  max_iters = 1000L,
  batch_size = 4096L,
  drift_threshold = 1e-04,
  lr_alpha = 1,
  init = c("parallel", "random"),
  use_hamerly = NULL,
  use_gemm = NULL
)
```

## Arguments

- metric:

  String. Distance metric to use. One of `c("euclidean", "cosine")`.
  Defaults to `"euclidean"`.

- max_iters:

  Integer. Maximum number of iterations. Defaults to `1000L`.

- batch_size:

  Integer. Mini-batch size. Only used when `method = "minibatch"`.
  Defaults to `4096L`.

- drift_threshold:

  Numeric. Below which centroid drift the mini-batch k-means is
  considered converged. Only used when `method = "minibatch"`. Defaults
  to `1e-04`.

- lr_alpha:

  Numeric. Learning rate decay for the mini-batch k-means. Original
  paper uses `1.0`. Defaults to `1.0`.

- init:

  String. The initialisation of the centroids. One of
  `c("parallel", "random")`. Defaults to `"parallel"`.

- use_hamerly:

  Boolean or `NULL`. Shall Hamerly's method be used (only if
  `metric == "euclidean"`). Defaults to `NULL`.

- use_gemm:

  Boolean or `NULL`. Shall the GEMM path be used. Useful on high
  dimensional data. If `NULL`, choice will be based on heuristics.
  Defaults to `NULL`.

## Value

A named list with the following elements:

- metric - String. Distance metric to use. One of
  `c("euclidean", "cosine")`. Defaults to `"euclidean"`.

- max_iters - Integer. Maximum number of iterations. Defaults to
  `1000L`.

- batch_size - Integer. Mini-batch size. Only used when
  `method = "minibatch"`. Defaults to `4096L`.

- drift_threshold - Numeric. Below which centroid drift the mini-batch
  k-means is considered converged. Only used when
  `method = "minibatch"`. Defaults to `1e-04`.

- lr_alpha - Numeric. Learning rate decay for the mini-batch k-means.
  Original paper uses `1.0`. Defaults to `1.0`.

- init - String. The initialisation of the centroids. One of
  `c("parallel", "random")`. Defaults to `"parallel"`.

- use_hamerly - Boolean or `NULL`. Shall Hamerly's method be used (only
  if `metric == "euclidean"`). Defaults to `NULL`.

- use_gemm - Boolean or `NULL`. Shall the GEMM path be used. Useful on
  high dimensional data. If `NULL`, choice will be based on heuristics.
  Defaults to `NULL`.
