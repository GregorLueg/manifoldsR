# Parameters for trajectory data generation

For use with
[`manifold_synthetic_data()`](https://gregorlueg.github.io/manifoldsR/reference/manifold_synthetic_data.md).

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

  String. Ignored if `cell_trajectories` is not `NULL`. One of
  `c("bifurcation", "linear", "combination")`. Defaults to
  `"bifurcation"`.

- cell_trajectories:

  Any. Optional named list with three equal-length vectors: `parent`
  (integer, `NA` for root, zero-indexed), `split_at` (numeric, fraction
  along parent where branch starts), and `length` (numeric, length of
  the branch). If `NULL`, `topology` is used instead. Defaults to
  `NULL`.

- noise:

  Numeric. Amount of noise to add. Defaults to `0.1`.

## Value

A named list with the following elements:

- topology - String. Ignored if `cell_trajectories` is not `NULL`. One
  of `c("bifurcation", "linear", "combination")`. Defaults to
  `"bifurcation"`.

- cell_trajectories - Any. Optional named list with three equal-length
  vectors: `parent` (integer, `NA` for root, zero-indexed), `split_at`
  (numeric, fraction along parent where branch starts), and `length`
  (numeric, length of the branch). If `NULL`, `topology` is used
  instead. Defaults to `NULL`.

- noise - Numeric. Amount of noise to add. Defaults to `0.1`.
