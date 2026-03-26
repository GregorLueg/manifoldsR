# Parameters for hierarchical cluster data generation

Parameters for hierarchical cluster data generation

## Usage

``` r
params_hierarchical(
  n_supergroups = 3L,
  n_subclusts = 3L,
  supergroup_spread = 15,
  subcluster_spread = 2,
  point_std = 0.4
)
```

## Arguments

- n_supergroups:

  Integer. Number of top-level groups. Defaults to `3L`.

- n_subclusts:

  Integer. Number of subclusters per supergroup. Defaults to `3L`.

- supergroup_spread:

  Numeric. Spread of supergroup centres in the ambient space. Defaults
  to `15.0`.

- subcluster_spread:

  Numeric. Spread of subcluster centres around their supergroup centre.
  Defaults to `2.0`.

- point_std:

  Numeric. Within-subcluster Gaussian noise. Defaults to `0.4`.

## Value

A list of parameters for use with
[`manifold_synthetic_data()`](https://gregorlueg.github.io/manifoldsR/reference/manifold_synthetic_data.md).
