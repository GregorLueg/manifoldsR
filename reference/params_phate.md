# Wrapper function to generate PHATE parameters

Wrapper function to generate PHATE parameters

## Usage

``` r
params_phate(
  decay = 40,
  bandwidth_scale = NULL,
  t_max = 100L,
  t_custom = NULL,
  gamma = 1,
  n_landmarks = 2024L,
  landmark_method = "spectral",
  n_svd = NULL,
  mds_method = "sgd_dense",
  graph_symmetry = "additive"
)
```

## Arguments

- decay:

  Numeric. Alpha decay parameter controlling the kernel bandwidth.
  Higher values create sharper transitions. Defaults to `40.0`.

- bandwidth_scale:

  Numeric or `NULL`. Scaling factor applied to the kernel bandwidth.
  When `NULL`, the library selects a sensible default. Defaults to
  `NULL`.

- t_max:

  Integer. Maximum diffusion time considered during automatic selection
  via Von Neumann entropy knee point detection. Defaults to `100L`.

- t_custom:

  Integer or `NULL`. Fixed diffusion time. When set, overrides automatic
  time selection. Defaults to `NULL`.

- gamma:

  Numeric. Informational distance parameter for the diffusion potential.
  Defaults to `1.0`.

- n_landmarks:

  Integer or `NULL`. Number of landmarks for compressed diffusion. When
  `NULL`, the full N x N diffusion operator is used. Defaults to
  `2048L`.

- landmark_method:

  Character. Method used to select landmarks. One of `"spectral"`,
  `"random"`, or `"density"`. Defaults to `"spectral"`.

- n_svd:

  Integer or `NULL`. Number of SVD components used in landmark
  construction. When `NULL`, the library selects a sensible default.
  Defaults to `NULL`.

- mds_method:

  Character. MDS algorithm used for the final embedding. One of
  `"sgd_dense"` or `"classic"`. Defaults to `"sgd_dense"`.

- graph_symmetry:

  Character. Method used to symmetrise the affinity graph. One of
  `"additive"`, `"multiplicative"`, `"mnn"`, or `"none"`. Defaults to
  `"additive"`.

## Value

A list with the PHATE parameters.
