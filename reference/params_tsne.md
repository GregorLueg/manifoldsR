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

  Optional numeric. Learning rate. If `NULL` (the default), the Rust
  backend sets it to `max((n_samples / 12), 200)`, following the
  N-dependent heuristic of Belkina et al. (2019).

- n_epochs:

  Integer. Number of optimisation epochs. Defaults to `1000L`.

- early_exag_iter:

  Integer. Number of early exaggeration iterations. Defaults to `250L`.

- early_exag_factor:

  Numeric. Early exaggeration factor. Defaults to `12.0`.

- late_exag_factor:

  Optional numeric. If you wish to also use late exaggerations. Can be
  useful on large data sets (set it to `2.0` to `4.0`).

- theta:

  Numeric. Barnes-Hut approximation angle. Lower values increase
  accuracy at the cost of speed. Defaults to `0.5`.

- n_interp_points:

  Integer. Number of interpolation points per grid cell for FFT
  acceleration. Defaults to `3L`.

- init:

  Character. Embedding initialisation method. One of `"spectral"`,
  `"pca"`, or `"random"`. Defaults to `"pca"`.

- randomised:

  Logical. Use randomised SVD for PCA initialisation. Defaults to
  `TRUE`.

## Value

A list with the t-SNE parameters.

## References

Belkina, et al., Nat. Commun., 2019
