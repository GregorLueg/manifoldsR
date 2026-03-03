# Generate synthetic data for manifold learning

A unified wrapper function for generating various types of synthetic
data to test manifold learning techniques and demonstrate differences.

## Usage

``` r
manifold_synthetic_data(
  type = c("swiss_role", "clusters", "trajectory"),
  n_samples,
  dim = 32L,
  n_clusters = 15L,
  cell_trajectories = NULL,
  topology = c("bifurcation", "linear", "combination"),
  noise = 0.1,
  seed = 42L
)
```

## Arguments

- type:

  Character. Type of synthetic data to generate. One of:

  - `"swiss_role"` - Swiss role manifold

  - `"clusters"` - Clustered data

  - `"trajectory"` - A trajectory-like data with branching. You can
    specify your own topology via `cell_trajectories` or use one of the
    pre- defined ones via topology.

- n_samples:

  Integer. Number of data points to generate.

- dim:

  Integer. Dimensionality of the data (used for `"clusters"` and
  `"trajectory"`).

- n_clusters:

  Integer. Number of clusters (used for "clusters" type). Default is
  `15L`.

- cell_trajectories:

  Optional list. Named list to use to provide your own topology for the
  `"trajectory"` version.

- topology:

  String. One of `c("bifurcation", "linear", "combination")`. If cell
  trajectories is not `NULL`, this will be ignored.

- noise:

  Numeric. Amount of noise to add (used for `"swiss_role"` and
  `"tree"`). must be any non 0 positive value. Default is `0.1`.

- seed:

  Integer. Seed for reproducibility.

## Value

A list with the following elements:

- data - Numerical matrix with the generated data

- membership - Vector of cluster/branch assignments (`NULL` for
  swiss_role)

## Examples

``` r
if (FALSE) { # \dontrun{

# Generate Swiss role data
swiss <- manifold_synthetic_data(
  "swiss_role",
  n_samples = 1000L
)

# Generate clustered data
clusters <- manifold_synthetic_data(
  "clusters",
  n_samples = 1000L,
  dim = 10L,
  n_clusters = 5L
)

# Generate trajectory-like data
trajectory <- manifold_synthetic_data(
  "trajectory",
  n_samples = 1000L,
  dim = 10L,
  cell_trajectories = NULL, # use a topology
  topology = "bifurcation"
)
} # }
```
