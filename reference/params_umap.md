# Wrapper function to generate UMAP parameters

Wrapper function to generate UMAP parameters

## Usage

``` r
params_umap(
  local_connectivity = 1,
  bandwidth = 1e-05,
  mix_weight = 1,
  lr = 1,
  n_epochs = NULL,
  neg_sample_rate = 5L,
  gamma = 1,
  optimiser = "adam_parallel",
  init = "spectral",
  randomised = FALSE
)
```

## Arguments

- local_connectivity:

  Numeric. Number of nearest neighbours assumed to be at distance zero.
  Defaults to `1.0`.

- bandwidth:

  Numeric. Convergence tolerance for smooth kNN distance binary search.
  Defaults to `1e-5`.

- mix_weight:

  Numeric. Balance between fuzzy union and directed graph during
  symmetrisation. Defaults to `1.0`.

- lr:

  Numeric. Learning rate. Defaults to `1.0`.

- n_epochs:

  Integer or `NULL`. Number of optimisation epochs. Defaults to `NULL`,
  resolved downstream based on data size.

- neg_sample_rate:

  Integer. Number of negative samples per positive sample. Defaults to
  `5L`.

- gamma:

  Numeric. Repulsion strength. Defaults to `1.0`.

- optimiser:

  Character. One of `"sgd"`, `"adam"`, or `"adam_parallel"`. Defaults to
  `"adam_parallel"`.

- init:

  Character. Embedding initialisation method. One of `"spectral"`,
  `"pca"`, or `"random"`. Defaults to `"spectral"`.

- randomised:

  Logical. Use randomised SVD for PCA initialisation. Defaults to
  `FALSE`.

## Value

A list with the UMAP parameters.
