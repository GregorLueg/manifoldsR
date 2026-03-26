# Wrapper function to generate PaCMAP parameters

Wrapper function to generate PaCMAP parameters

## Usage

``` r
params_pacmap(
  n_mid_near = 2L,
  n_further = 2L,
  mn_candidate_start = 4L,
  mn_candidate_end = 50L,
  init = "pca",
  optimiser = "adam_parallel",
  lr = 0.01,
  n_epochs = NULL,
  beta1 = 0.9,
  beta2 = 0.999,
  eps = 1e-07,
  phase1_end = NULL,
  phase2_end = NULL
)
```

## Arguments

- n_mid_near:

  Integer. Mid-near pairs per point. Defaults to `2L`.

- n_further:

  Integer. Further (random) pairs per point. Defaults to `2L`.

- mn_candidate_start:

  Integer. Start index into kNN list for mid-near candidate window.
  Defaults to `4L`.

- mn_candidate_end:

  Integer. End index into kNN list for mid-near candidate window.
  Defaults to `50L`.

- init:

  Character. Embedding initialisation. One of `"pca"` or `"random"`.
  Defaults to `"pca"`.

- optimiser:

  Character. One of `"adam"` or `"adam_parallel"`. Defaults to
  `"adam_parallel"`.

- lr:

  Numeric. Adam learning rate. Defaults to `0.01`.

- n_epochs:

  Integer or `NULL`. Total optimisation epochs. Defaults to `NULL`,
  resolved downstream to `450`.

- beta1:

  Numeric. Adam first moment decay. Defaults to `0.9`.

- beta2:

  Numeric. Adam second moment decay. Defaults to `0.999`.

- eps:

  Numeric. Adam numerical stability constant. Defaults to `1e-7`.

- phase1_end:

  Integer or `NULL`. Epoch at which phase 1 ends. Defaults to `NULL`,
  resolved downstream to `100`.

- phase2_end:

  Integer or `NULL`. Epoch at which phase 2 ends. Defaults to `NULL`,
  resolved downstream to `200`.

## Value

A list with the PaCMAP parameters.
