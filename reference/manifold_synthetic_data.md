# Generate synthetic data for manifold learning

A unified wrapper function for generating various types of synthetic
data to test manifold learning techniques and demonstrate differences.

## Usage

``` r
manifold_synthetic_data(
  type = c("swiss_roll", "biased_swiss_roll", "clusters", "trajectory", "hierarchical"),
  n_samples,
  dim = 32L,
  seed = 42L,
  parameters = NULL
)
```

## Arguments

- type:

  Character. Type of synthetic data to generate. One of:

  - `"swiss_roll"` - Swiss roll manifold

  - `"biased_swiss_roll"` - Biased Swiss roll manifold

  - `"clusters"` - Clustered data

  - `"trajectory"` - Trajectory-like data with branching

  - `"hierarchical"` - Two-level hierarchical cluster structure

- n_samples:

  Integer. Number of data points to generate.

- dim:

  Integer. Dimensionality of the ambient space. Used for all types
  except `"swiss_roll"`. Defaults to `32L`.

- seed:

  Integer. Seed for reproducibility. Defaults to `42L`.

- parameters:

  A named list of type-specific parameters, constructed via
  [`params_swiss_roll()`](https://gregorlueg.github.io/manifoldsR/reference/params_swiss_roll.md),
  [`params_swiss_roll_biased()`](https://gregorlueg.github.io/manifoldsR/reference/params_swiss_roll_biased.md)
  [`params_clusters()`](https://gregorlueg.github.io/manifoldsR/reference/params_clusters.md),
  [`params_trajectory()`](https://gregorlueg.github.io/manifoldsR/reference/params_trajectory.md),
  or
  [`params_hierarchical()`](https://gregorlueg.github.io/manifoldsR/reference/params_hierarchical.md).
  If `NULL`, defaults for the chosen type are used. A plain list is
  accepted but must contain all required fields for the given type.

## Value

A list with the following elements:

- `data` - Numeric matrix of shape `n_samples x dim`

- `membership` - Integer vector of cluster/branch assignments (`NULL`
  for `"swiss_roll"`)

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
dim(d$data)
#> [1] 500  32
table(d$membership)
#> 
#>  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 
#> 38 31 35 23 35 56 16 14 29 36 33 55 33 18 48 

roll <- manifold_synthetic_data(type = "swiss_roll", n_samples = 500L)
dim(roll$data)
#> [1] 500   3
```
