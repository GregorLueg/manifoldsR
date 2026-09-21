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
  optimiser = c("adam_parallel", "sgd", "adam"),
  init = c("spectral", "pca", "random"),
  randomised = TRUE
)
```

## Arguments

- local_connectivity:

  Numeric. Number of nearest neighbours assumed to be at distance zero.
  Defaults to `1.0`.

- bandwidth:

  Numeric. Convergence tolerance for smooth kNN distance binary search.
  Defaults to `1e-05`.

- mix_weight:

  Numeric. Balance between fuzzy union and directed graph during
  symmetrisation. Defaults to `1.0`.

- lr:

  Numeric. Learning rate. Defaults to `1.0`.

- n_epochs:

  Integer or `NULL`. Number of optimisation epochs. If `NULL`, resolved
  downstream based on data size. Defaults to `NULL`.

- neg_sample_rate:

  Integer. Number of negative samples per positive sample. Defaults to
  `5L`.

- gamma:

  Numeric. Repulsion strength. Defaults to `1.0`.

- optimiser:

  String. The optimiser. One of `c("adam_parallel", "sgd", "adam")`.
  Defaults to `"adam_parallel"`.

- init:

  String. Embedding initialisation method. One of
  `c("spectral", "pca", "random")`. Defaults to `"spectral"`.

- randomised:

  Boolean. Use randomised SVD for PCA initialisation. Defaults to
  `TRUE`.

## Value

A named list with the following elements:

- local_connectivity - Numeric. Number of nearest neighbours assumed to
  be at distance zero. Defaults to `1.0`.

- bandwidth - Numeric. Convergence tolerance for smooth kNN distance
  binary search. Defaults to `1e-05`.

- mix_weight - Numeric. Balance between fuzzy union and directed graph
  during symmetrisation. Defaults to `1.0`.

- lr - Numeric. Learning rate. Defaults to `1.0`.

- n_epochs - Integer or `NULL`. Number of optimisation epochs. If
  `NULL`, resolved downstream based on data size. Defaults to `NULL`.

- neg_sample_rate - Integer. Number of negative samples per positive
  sample. Defaults to `5L`.

- gamma - Numeric. Repulsion strength. Defaults to `1.0`.

- optimiser - String. The optimiser. One of
  `c("adam_parallel", "sgd", "adam")`. Defaults to `"adam_parallel"`.

- init - String. Embedding initialisation method. One of
  `c("spectral", "pca", "random")`. Defaults to `"spectral"`.

- randomised - Boolean. Use randomised SVD for PCA initialisation.
  Defaults to `TRUE`.
