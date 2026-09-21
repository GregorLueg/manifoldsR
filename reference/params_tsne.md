# Wrapper function to generate t-SNE parameters

Wrapper function to generate t-SNE parameters

## Usage

``` r
params_tsne(
  lr = NULL,
  n_epochs = 1000L,
  early_exag_iter = 250L,
  early_exag_factor = 12,
  late_exag_factor = NULL,
  theta = 0.5,
  n_interp_points = 3L,
  init = c("pca", "spectral", "random"),
  randomised = TRUE
)
```

## Arguments

- lr:

  Numeric or `NULL`. Learning rate. If `NULL`, the Rust backend sets it
  to `max((n_samples / 12), 200)`, following the N-dependent heuristic
  of Belkina et al. (2019). Defaults to `NULL`.

- n_epochs:

  Integer. Number of optimisation epochs. Defaults to `1000L`.

- early_exag_iter:

  Integer. Number of early exaggeration iterations. Defaults to `250L`.

- early_exag_factor:

  Numeric. Early exaggeration factor. Defaults to `12.0`.

- late_exag_factor:

  Numeric or `NULL`. Late exaggeration factor, if you wish to use one.
  Can be useful on large data sets (set it to `2.0` to `4.0`). Defaults
  to `NULL`.

- theta:

  Numeric. Barnes-Hut approximation angle. Lower values increase
  accuracy at the cost of speed. Defaults to `0.5`.

- n_interp_points:

  Integer. Number of interpolation points per grid cell for FFT
  acceleration. Defaults to `3L`.

- init:

  String. Embedding initialisation method. One of
  `c("pca", "spectral", "random")`. Defaults to `"pca"`.

- randomised:

  Boolean. Use randomised SVD for PCA initialisation. Defaults to
  `TRUE`.

## Value

A named list with the following elements:

- lr - Numeric or `NULL`. Learning rate. If `NULL`, the Rust backend
  sets it to `max((n_samples / 12), 200)`, following the N-dependent
  heuristic of Belkina et al. (2019). Defaults to `NULL`.

- n_epochs - Integer. Number of optimisation epochs. Defaults to
  `1000L`.

- early_exag_iter - Integer. Number of early exaggeration iterations.
  Defaults to `250L`.

- early_exag_factor - Numeric. Early exaggeration factor. Defaults to
  `12.0`.

- late_exag_factor - Numeric or `NULL`. Late exaggeration factor, if you
  wish to use one. Can be useful on large data sets (set it to `2.0` to
  `4.0`). Defaults to `NULL`.

- theta - Numeric. Barnes-Hut approximation angle. Lower values increase
  accuracy at the cost of speed. Defaults to `0.5`.

- n_interp_points - Integer. Number of interpolation points per grid
  cell for FFT acceleration. Defaults to `3L`.

- init - String. Embedding initialisation method. One of
  `c("pca", "spectral", "random")`. Defaults to `"pca"`.

- randomised - Boolean. Use randomised SVD for PCA initialisation.
  Defaults to `TRUE`.

## References

Belkina, et al., Nat. Commun., 2019
