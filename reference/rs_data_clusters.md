# Generates clustered data

Generates synthetic data with clear cluster structure.

## Usage

``` r
rs_data_clusters(n_samples, dim, n_clusters, seed)
```

## Arguments

- n_samples:

  Integer. Number of data points to generate.

- dim:

  Integer. Dimensionality of the data

- n_clusters:

  Integer. Number of clusters to produce in the data.

- seed:

  Integer. For reproducibility purposes

## Value

A list with the following elements:

- data - Numerical matrix with the data.

- clusters - Cluster assignments
