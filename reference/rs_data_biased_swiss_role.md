# Generates the SwissRole data

Generates synthetic data, i.e., the Swiss role to test different
manifold learning techniques

## Usage

``` r
rs_data_biased_swiss_role(n_samples, noise, bias, seed)
```

## Arguments

- n_samples:

  Integer. Number of data points to generate.

- noise:

  Numeric. How much noise to add.

- bias:

  Numeric. Sampling bias along `t`. `0.0` recovers uniform sampling;
  higher values concentrate samples at the inner end of the roll. A
  value of `2.5` mirrors the trajectory accumulation behaviour.

- seed:

  Integer. For reproducibility purposes

## Value

The biased swiss role synthetic data with the desired parameters.
