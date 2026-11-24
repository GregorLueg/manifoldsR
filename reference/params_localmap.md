# Wrapper function to generate LocalMAP parameters

LocalMAP is PaCMAP with a different third phase: the mid-near pairs drop
out, the near-pair pull is scaled by distance and every 10 epochs each
point redraws its further pairs from within `max_distance` in the
embedding. That pulls apart clusters PaCMAP leaves touching.

## Usage

``` r
params_localmap(
  n_near = 10L,
  n_mid_near = 5L,
  n_further = 20L,
  max_distance = 10,
  init = c("pca", "random"),
  optimiser = c("adam_parallel", "adam"),
  lr = 1,
  n_epochs = NULL,
  beta1 = 0.9,
  beta2 = 0.999,
  eps = 1e-07,
  phase1_end = NULL,
  phase2_end = NULL
)
```

## Arguments

- n_near:

  Integer. Near pairs per point (attractive). The kNN search runs
  `n_near + 50` wide and the pairs are the best of those by locally
  scaled distance. Defaults to `10L`.

- n_mid_near:

  Integer. Mid-near pairs per point. Used in phases 1 and 2 only.
  Defaults to `5L`.

- n_further:

  Integer. Further (random) pairs per point. These exclude the near
  pairs. Defaults to `20L`.

- max_distance:

  Numeric. Radius in the embedding within which phase 3 redraws the
  further pairs. Defaults to `10.0`.

- init:

  String. Embedding initialisation. `"pca"` uses the PC scores times
  `0.01`, so the ratio between the components survives. One of
  `c("pca", "random")`. Defaults to `"pca"`.

- optimiser:

  String. The optimiser. One of `c("adam_parallel", "adam")`. Defaults
  to `"adam_parallel"`.

- lr:

  Numeric. Adam learning rate. Defaults to `1.0`.

- n_epochs:

  Integer or `NULL`. Total optimisation epochs. If `NULL`, resolved
  downstream to `450`. Defaults to `NULL`.

- beta1:

  Numeric. Adam first moment decay. Defaults to `0.9`.

- beta2:

  Numeric. Adam second moment decay. Defaults to `0.999`.

- eps:

  Numeric. Adam numerical stability constant. Defaults to `1e-07`.

- phase1_end:

  Integer or `NULL`. Epoch at which phase 1 ends. If `NULL`, resolved
  downstream to `100`. Defaults to `NULL`.

- phase2_end:

  Integer or `NULL`. Epoch at which phase 2 ends. If `NULL`, resolved
  downstream to `200`. Defaults to `NULL`.

## Value

A named list with the following elements:

- n_near - Integer. Near pairs per point (attractive). The kNN search
  runs `n_near + 50` wide and the pairs are the best of those by locally
  scaled distance. Defaults to `10L`.

- n_mid_near - Integer. Mid-near pairs per point. Used in phases 1 and 2
  only. Defaults to `5L`.

- n_further - Integer. Further (random) pairs per point. These exclude
  the near pairs. Defaults to `20L`.

- max_distance - Numeric. Radius in the embedding within which phase 3
  redraws the further pairs. Defaults to `10.0`.

- init - String. Embedding initialisation. `"pca"` uses the PC scores
  times `0.01`, so the ratio between the components survives. One of
  `c("pca", "random")`. Defaults to `"pca"`.

- optimiser - String. The optimiser. One of
  `c("adam_parallel", "adam")`. Defaults to `"adam_parallel"`.

- lr - Numeric. Adam learning rate. Defaults to `1.0`.

- n_epochs - Integer or `NULL`. Total optimisation epochs. If `NULL`,
  resolved downstream to `450`. Defaults to `NULL`.

- beta1 - Numeric. Adam first moment decay. Defaults to `0.9`.

- beta2 - Numeric. Adam second moment decay. Defaults to `0.999`.

- eps - Numeric. Adam numerical stability constant. Defaults to `1e-07`.

- phase1_end - Integer or `NULL`. Epoch at which phase 1 ends. If
  `NULL`, resolved downstream to `100`. Defaults to `NULL`.

- phase2_end - Integer or `NULL`. Epoch at which phase 2 ends. If
  `NULL`, resolved downstream to `200`. Defaults to `NULL`.

## References

Wang, et al., arXiv:2412.15426, 2024
