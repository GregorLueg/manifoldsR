# Wrapper function to generate diffusion maps parameters

Wrapper function to generate diffusion maps parameters

## Usage

``` r
params_diffusion_maps(
  bandwidth_scale = 1,
  thresh = 1e-04,
  graph_symmetry = c("additive", "multiplicative", "mnn", "none"),
  alpha_norm = 1,
  t_max = 100L,
  t_custom = NULL,
  n_landmarks = 2048L,
  landmark_method = c("spectral", "random", "density"),
  n_svd = NULL
)
```

## Arguments

- bandwidth_scale:

  Numeric. Multiplicative factor applied to the adaptive kernel
  bandwidth. Defaults to `1.0`.

- thresh:

  Numeric. Sparsity threshold applied to kernel entries. Defaults to
  `1e-04`.

- graph_symmetry:

  String. Method used to symmetrise the affinity graph. One of
  `c("additive", "multiplicative", "mnn", "none")`. Defaults to
  `"additive"`.

- alpha_norm:

  Numeric. Anisotropic density-correction exponent. `0` gives the
  normalised graph Laplacian, `0.5` the Fokker-Planck operator, `1` the
  Laplace-Beltrami operator. Defaults to `1.0`.

- t_max:

  Integer. Maximum diffusion time considered during automatic selection
  via Von Neumann entropy knee point detection. Defaults to `100L`.

- t_custom:

  Integer or `NULL`. Fixed diffusion time. If set, overrides automatic
  time selection. Defaults to `NULL`.

- n_landmarks:

  Integer or `NULL`. Number of landmarks for compressed diffusion. If
  `NULL`, the full N x N diffusion operator is used. Defaults to
  `2048L`.

- landmark_method:

  String. Method used to select landmarks. One of
  `c("spectral", "random", "density")`. Defaults to `"spectral"`.

- n_svd:

  Integer or `NULL`. Number of SVD components used in landmark
  construction. If `NULL`, the library selects a sensible default.
  Defaults to `NULL`.

## Value

A named list with the following elements:

- bandwidth_scale - Numeric. Multiplicative factor applied to the
  adaptive kernel bandwidth. Defaults to `1.0`.

- thresh - Numeric. Sparsity threshold applied to kernel entries.
  Defaults to `1e-04`.

- graph_symmetry - String. Method used to symmetrise the affinity graph.
  One of `c("additive", "multiplicative", "mnn", "none")`. Defaults to
  `"additive"`.

- alpha_norm - Numeric. Anisotropic density-correction exponent. `0`
  gives the normalised graph Laplacian, `0.5` the Fokker-Planck
  operator, `1` the Laplace-Beltrami operator. Defaults to `1.0`.

- t_max - Integer. Maximum diffusion time considered during automatic
  selection via Von Neumann entropy knee point detection. Defaults to
  `100L`.

- t_custom - Integer or `NULL`. Fixed diffusion time. If set, overrides
  automatic time selection. Defaults to `NULL`.

- n_landmarks - Integer or `NULL`. Number of landmarks for compressed
  diffusion. If `NULL`, the full N x N diffusion operator is used.
  Defaults to `2048L`.

- landmark_method - String. Method used to select landmarks. One of
  `c("spectral", "random", "density")`. Defaults to `"spectral"`.

- n_svd - Integer or `NULL`. Number of SVD components used in landmark
  construction. If `NULL`, the library selects a sensible default.
  Defaults to `NULL`.
