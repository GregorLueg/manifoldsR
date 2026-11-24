# K-means clustering (full)

**\[experimental\]** Rust interface for k-means clustering via e-means
(mini-batch EMA updates, Bessa et al. 2026) or Lloyd's algorithm with
SIMD or GEMM acceleration depending on dimensionality. It exposes the
k-means code from the Rust crate `ann-search-rs` through `bixverse-rs`.

## Usage

``` r
rs_k_means(data, k, algorithm, kmeans_params, seed, verbose)
```

## Arguments

- data:

  Numerical matrix. The data to cluster, of dimensions samples x
  features.

- k:

  Integer. Number of clusters.

- algorithm:

  String. One of `"emeans"` or `"lloyd"`.

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
