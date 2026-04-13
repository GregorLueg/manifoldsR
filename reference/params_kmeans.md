# Wrapper function to generate k-means parameters

Wrapper function to generate k-means parameters

## Usage

``` r
params_kmeans(
  metric = c("euclidean", "cosine"),
  max_iters = 1000L,
  batch_size = 4096L,
  drift_threshold = 1e-04,
  lr_alpha = 1
)
```

## Arguments

- metric:

  Character. Distance metric to use. One of `"euclidean"` or `"cosine"`.
  Defaults to `"euclidean"`.

- max_iters:

  Integer. Maximum number of iterations. Defaults to `1000L`.

- batch_size:

  Integer. Mini-batch size. Only used when `method = "minibatch"`.
  Defaults to `4096L`.

- drift_threshold:

  Float. Below which centroid drift the mini-batch k-means is considered
  converged. Defaults to `1e-4`. Only used when `method = "minibatch"`

- lr_alpha:

  Float. Learning rate decay for the mini-batch k-means. Original paper
  uses `1.0`.

## Value

A named list with the k-means parameters.
