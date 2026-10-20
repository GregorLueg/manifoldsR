# Generates biased Swiss roll data

**\[experimental\]** Generates synthetic data, i.e., the Swiss roll to
test different manifold learning techniques

## Usage

``` r
rs_data_biased_swiss_roll(n_samples, noise, bias, seed)
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

The biased Swiss roll synthetic data with the desired parameters.
