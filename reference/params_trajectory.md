# Parameters for trajectory data generation

Parameters for trajectory data generation

## Usage

``` r
params_trajectory(
  topology = c("bifurcation", "linear", "combination"),
  cell_trajectories = NULL,
  noise = 0.1
)
```

## Arguments

- topology:

  Character. One of `c("bifurcation", "linear", "combination")`. Ignored
  if `cell_trajectories` is not `NULL`. Defaults to `"bifurcation"`.

- cell_trajectories:

  Optional list. Named list with three equal-length vectors: `parent`
  (integer, `NA` for root, zero-indexed), `split_at` (numeric, fraction
  along parent where branch starts), and `length` (numeric, length of
  the branch). If `NULL`, `topology` is used instead. Defaults to
  `NULL`.

- noise:

  Numeric. Amount of noise to add. Must be a positive non-zero value.
  Defaults to `0.1`.

## Value

A list of parameters for use with
[`manifold_synthetic_data()`](https://gregorlueg.github.io/manifoldsR/reference/manifold_synthetic_data.md).
