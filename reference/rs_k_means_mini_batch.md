# Mini-batch k-means clustering

Rust interface for mini-batch k-means clustering (Sculley 2010). Uses
random mini-batches with a decaying learning rate for faster convergence
on large data sets.

## Usage

``` r
rs_k_means_mini_batch(data, k, kmeans_params, seed, verbose)
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
