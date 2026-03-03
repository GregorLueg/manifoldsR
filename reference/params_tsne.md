# Wrapper function to generate t-SNE parameters

Wrapper function to generate t-SNE parameters

## Usage

``` r
params_tsne(
  lr = 200,
  n_epochs = 1000L,
  early_exag_iter = 250L,
  early_exag_factor = 12,
  theta = 0.5,
  n_interp_points = 3L,
  init = "pca",
  randomised = TRUE
)
```

## Arguments

- lr:

  Numeric. Learning rate. Defaults to `200.0`.

- n_epochs:

  Integer. Number of optimisation epochs. Defaults to `1000L`.

- early_exag_iter:

  Integer. Number of early exaggeration iterations. Defaults to `250L`.

- early_exag_factor:

  Numeric. Early exaggeration factor. Defaults to `12.0`.

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
