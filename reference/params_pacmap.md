# Wrapper function to generate PaCMAP parameters

Wrapper function to generate PaCMAP parameters

## Usage

``` r
params_pacmap(
  n_near = 10L,
  n_mid_near = 5L,
  n_further = 20L,
  mn_candidate_start = 4L,
  mn_candidate_end = 50L,
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

  Integer. Near pairs per point (attractive). Defaults to `10L`.

- n_mid_near:

  Integer. Mid-near pairs per point. Defaults to `5L`.

- n_further:

  Integer. Further (random) pairs per point. Defaults to `20L`.

- mn_candidate_start:

  Integer. Start index into kNN list for mid-near candidate window.
  Defaults to `4L`.

- mn_candidate_end:

  Integer. End index into kNN list for mid-near candidate window. Also
  determines the kNN search size. Defaults to `50L`.

- init:

  String. Embedding initialisation. One of `c("pca", "random")`.
  Defaults to `"pca"`.

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

- n_near - Integer. Near pairs per point (attractive). Defaults to
  `10L`.

- n_mid_near - Integer. Mid-near pairs per point. Defaults to `5L`.

- n_further - Integer. Further (random) pairs per point. Defaults to
  `20L`.

- mn_candidate_start - Integer. Start index into kNN list for mid-near
  candidate window. Defaults to `4L`.

- mn_candidate_end - Integer. End index into kNN list for mid-near
  candidate window. Also determines the kNN search size. Defaults to
  `50L`.

- init - String. Embedding initialisation. One of `c("pca", "random")`.
  Defaults to `"pca"`.

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
