# Generate hierarchical cluster data

Generates synthetic data with a two-level cluster hierarchy:
`n_supergroups` top-level groups each containing `n_subclusts` tight
subclusters. Supergroup centres are spread far apart; subcluster centres
sit tightly around their supergroup centre.

Note that the actual number of samples returned may be slightly less
than `n_samples` if it is not evenly divisible by
`n_supergroups * n_subclusts`.

## Usage

``` r
rs_data_hierarchical(
  n_samples,
  dim,
  n_supergroups,
  n_subclusts,
  supergroup_spread,
  subcluster_spread,
  point_std,
  seed
)
```

## Arguments

- n_samples:

  Integer. Total number of points, distributed evenly across all
  subclusters.

- dim:

  Integer. Dimensionality of the ambient space.

- n_supergroups:

  Integer. Number of top-level groups. Defaults to `3`.

- n_subclusts:

  Integer. Number of subclusters per supergroup. Defaults to `3`.

- supergroup_spread:

  Numeric. Spread of supergroup centres. Defaults to `15.0`.

- subcluster_spread:

  Numeric. Spread of subcluster centres around their supergroup centre.
  Defaults to `2.0`.

- point_std:

  Numeric. Within-subcluster Gaussian noise. Defaults to `0.4`.

- seed:

  Integer. Seed for reproducibility.

## Value

A named list with three elements: `data`, a numeric matrix of shape
samples x `dim`; `supergroup`, an integer vector of supergroup labels
(`0..n_supergroups`) one per sample; and `subgroup`, an integer vector
of subcluster labels (`0..n_supergroups * n_subclusts`) one per sample.
