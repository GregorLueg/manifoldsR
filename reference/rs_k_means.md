# Full k-means clustering

Rust interface for k-means clustering using Lloyd's algorithm with SIMD
or GEMM acceleration depending on dimensionality.

## Usage

``` r
rs_k_means(data, k, kmeans_params, seed, verbose)
```

## Arguments

- data:

  Numerical matrix. The data to cluster, of dimensions samples x
  features.

- k:

  Integer. Number of clusters.

- kmeans_params:

  Named list. Parameters produced by
  [`params_kmeans()`](https://gregorlueg.github.io/manifoldsR/reference/params_kmeans.md).

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Boolean. Controls verbosity.

## Value

A named list with:

- centroids - Numeric matrix of shape k x features.

- assignments - Integer vector of length samples (1-indexed).
