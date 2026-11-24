# Wrapper function to generate NCVis parameters

NCVis runs noise-contrastive Hogwild! SGD on the unweighted kNN graph.
The defaults are the NCVis+ ones: PCA start, a large learning rate and
10 negatives per edge. Only reproducible at a fixed seed on one thread.

## Usage

``` r
params_ncvis(
  n_epochs = 50L,
  n_negative = 10,
  lr = 2,
  lr_q = 1,
  init = c("pca", "random", "ncvis"),
  init_scale = 10,
  randomised = FALSE
)
```

## Arguments

- n_epochs:

  Integer. Number of optimisation epochs. Defaults to `50L`.

- n_negative:

  Numeric. Mean number of negative samples per edge. Defaults to `10.0`.

- lr:

  Numeric. Learning rate of the embedding. Defaults to `2.0`.

- lr_q:

  Numeric. Learning rate of the noise normalisation constant `Q`.
  Defaults to `1.0`.

- init:

  String. Embedding initialisation method. `"ncvis"` is the original
  NCVis start: uniform noise smoothed over the kNN graph in 20 passes.
  One of `c("pca", "random", "ncvis")`. Defaults to `"pca"`.

- init_scale:

  Numeric. Standard deviation of the first axis of the initial layout.
  The other axes are scaled by the same factor. Defaults to `10.0`.

- randomised:

  Boolean. Use randomised SVD for PCA initialisation. Defaults to
  `FALSE`.

## Value

A named list with the following elements:

- n_epochs - Integer. Number of optimisation epochs. Defaults to `50L`.

- n_negative - Numeric. Mean number of negative samples per edge.
  Defaults to `10.0`.

- lr - Numeric. Learning rate of the embedding. Defaults to `2.0`.

- lr_q - Numeric. Learning rate of the noise normalisation constant `Q`.
  Defaults to `1.0`.

- init - String. Embedding initialisation method. `"ncvis"` is the
  original NCVis start: uniform noise smoothed over the kNN graph in 20
  passes. One of `c("pca", "random", "ncvis")`. Defaults to `"pca"`.

- init_scale - Numeric. Standard deviation of the first axis of the
  initial layout. The other axes are scaled by the same factor. Defaults
  to `10.0`.

- randomised - Boolean. Use randomised SVD for PCA initialisation.
  Defaults to `FALSE`.

## References

Artemenkov & Panov, WWW, 2020; Pedersen, NCVis+, 2026
(https://github.com/SeanPedersen/ncvis-plus)
