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
  thresh = 1e-04,
  n_landmarks = 2048L,
  landmark_method = c("spectral", "random", "density"),
  n_svd = NULL,
  mds_method = c("sgd_dense", "classic"),
  mds_iter = NULL,
  graph_symmetry = c("additive", "multiplicative", "mnn", "none")
)
```

## Arguments

- decay:

  Numeric. Alpha decay parameter controlling the kernel bandwidth.
  Higher values create sharper transitions. Defaults to `40.0`.

- bandwidth_scale:

  Numeric or `NULL`. Scaling factor applied to the kernel bandwidth. If
  `NULL`, uses `1.0`. Defaults to `NULL`.

- t_max:

  Integer. Maximum diffusion time considered during automatic selection
  via Von Neumann entropy knee point detection. At least `3`, as the
  knee search needs three points. Defaults to `100L`.

- t_custom:

  Integer or `NULL`. Fixed diffusion time. If set, overrides automatic
  time selection. Defaults to `NULL`.

- gamma:

  Numeric. Informational distance parameter for the diffusion potential.
  `1` is the log potential. Defaults to `1.0`.

- thresh:

  Numeric. Sparsity threshold on the kernel. Neighbours past `k` join
  the kernel while their affinity clears it. Defaults to `1e-04`.

- n_landmarks:

  Integer or `NULL`. Number of landmarks for compressed diffusion. If
  `NULL`, or at least the number of samples, the full N x N diffusion
  operator is used. Defaults to `2048L`.

- landmark_method:

  String. Method used to select landmarks. One of
  `c("spectral", "random", "density")`. Defaults to `"spectral"`.

- n_svd:

  Integer or `NULL`. Number of singular vectors for spectral landmark
  selection. If `NULL`, uses `100`. Ignored by the other landmark
  methods. Defaults to `NULL`.

- mds_method:

  String. MDS algorithm used for the final embedding. One of
  `c("sgd_dense", "classic")`. Defaults to `"sgd_dense"`.

- mds_iter:

  Integer or `NULL`. Number of SGD-MDS iterations. If `NULL`, scales
  with the number of points: `300` below 1000, `500` below 5000 and
  `800` otherwise. Defaults to `NULL`.

- graph_symmetry:

  String. Method used to symmetrise the affinity graph. One of
  `c("additive", "multiplicative", "mnn", "none")`. Defaults to
  `"additive"`.

## Value

A named list with the following elements:

- decay - Numeric. Alpha decay parameter controlling the kernel
  bandwidth. Higher values create sharper transitions. Defaults to
  `40.0`.

- bandwidth_scale - Numeric or `NULL`. Scaling factor applied to the
  kernel bandwidth. If `NULL`, uses `1.0`. Defaults to `NULL`.

- t_max - Integer. Maximum diffusion time considered during automatic
  selection via Von Neumann entropy knee point detection. At least `3`,
  as the knee search needs three points. Defaults to `100L`.

- t_custom - Integer or `NULL`. Fixed diffusion time. If set, overrides
  automatic time selection. Defaults to `NULL`.

- gamma - Numeric. Informational distance parameter for the diffusion
  potential. `1` is the log potential. Defaults to `1.0`.

- thresh - Numeric. Sparsity threshold on the kernel. Neighbours past
  `k` join the kernel while their affinity clears it. Defaults to
  `1e-04`.

- n_landmarks - Integer or `NULL`. Number of landmarks for compressed
  diffusion. If `NULL`, or at least the number of samples, the full N x
  N diffusion operator is used. Defaults to `2048L`.

- landmark_method - String. Method used to select landmarks. One of
  `c("spectral", "random", "density")`. Defaults to `"spectral"`.

- n_svd - Integer or `NULL`. Number of singular vectors for spectral
  landmark selection. If `NULL`, uses `100`. Ignored by the other
  landmark methods. Defaults to `NULL`.

- mds_method - String. MDS algorithm used for the final embedding. One
  of `c("sgd_dense", "classic")`. Defaults to `"sgd_dense"`.

- mds_iter - Integer or `NULL`. Number of SGD-MDS iterations. If `NULL`,
  scales with the number of points: `300` below 1000, `500` below 5000
  and `800` otherwise. Defaults to `NULL`.

- graph_symmetry - String. Method used to symmetrise the affinity graph.
  One of `c("additive", "multiplicative", "mnn", "none")`. Defaults to
  `"additive"`.

## Examples

``` r
params_phate()
#> $decay
#> [1] 40
#> 
#> $bandwidth_scale
#> NULL
#> 
#> $t_max
#> [1] 100
#> 
#> $t_custom
#> NULL
#> 
#> $gamma
#> [1] 1
#> 
#> $thresh
#> [1] 1e-04
#> 
#> $n_landmarks
#> [1] 2048
#> 
#> $landmark_method
#> [1] "spectral"
#> 
#> $n_svd
#> NULL
#> 
#> $mds_method
#> [1] "sgd_dense"
#> 
#> $mds_iter
#> NULL
#> 
#> $graph_symmetry
#> [1] "additive"
#> 
params_phate(decay = 20, n_landmarks = 500L)
#> $decay
#> [1] 20
#> 
#> $bandwidth_scale
#> NULL
#> 
#> $t_max
#> [1] 100
#> 
#> $t_custom
#> NULL
#> 
#> $gamma
#> [1] 1
#> 
#> $thresh
#> [1] 1e-04
#> 
#> $n_landmarks
#> [1] 500
#> 
#> $landmark_method
#> [1] "spectral"
#> 
#> $n_svd
#> NULL
#> 
#> $mds_method
#> [1] "sgd_dense"
#> 
#> $mds_iter
#> NULL
#> 
#> $graph_symmetry
#> [1] "additive"
#> 
```
