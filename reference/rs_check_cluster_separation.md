# Check cluster separation in an embedding

Check cluster separation in an embedding

## Usage

``` r
rs_check_cluster_separation(embd, cluster_membership)
```

## Arguments

- embd:

  Numerical matrix. The embedding of shape samples x dims.

- cluster_membership:

  Integer vector. Zero-indexed cluster labels.

## Value

A named list with `within_dists` and `between_dists`.
