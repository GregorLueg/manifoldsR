# Generates tree-like data with branches

**\[experimental\]** Generates synthetic data that has a tree-like
structure to simulate evolution/trajectory of data.

## Usage

``` r
rs_data_trajectory(n_samples, dim, topology, cell_trajectories, noise, seed)
```

## Arguments

- n_samples:

  Integer. Number of data points to generate.

- dim:

  Integer. Dimensionality of the data.

- topology:

  String. One of `c("bifurcation", "linear", "combination")`.

- cell_trajectories:

  List or NULL. Named list with three equal-length vectors: `parent`
  (integer, NA for root, zero-indexed), `split_at` (numeric, fraction
  along parent where branch starts), and `length` (numeric, length of
  the branch). If NULL, will use the topology specified in topology.

- noise:

  Numeric. How much noise to add.

- seed:

  Integer. For reproducibility purposes.

## Value

A list with the following elements:

- data - Numerical matrix with the generated data.

- branches - Branch assignments for each sample.
