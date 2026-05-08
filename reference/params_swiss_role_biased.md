# Parameters for swiss roll data generation

Parameters for swiss roll data generation

## Usage

``` r
params_swiss_role_biased(noise = 0.1, bias = 2.5)
```

## Arguments

- noise:

  Numeric. Amount of noise to add. Must be a positive non-zero value.
  Defaults to `0.1`.

- bias:

  Numeric. The sampling bias across the manifold. Defaults to `2.5`.

## Value

A list of parameters for use with
[`manifold_synthetic_data()`](https://gregorlueg.github.io/manifoldsR/reference/manifold_synthetic_data.md).
