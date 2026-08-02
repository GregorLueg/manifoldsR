# Wrapper function to generate den-SNE parameters

The density-preservation knobs on top of the usual t-SNE parameters.
den-SNE adds `-lambda * Corr(log Ro, log Re)` to the t-SNE loss, where
`Ro` is the local radius in the input space and `Re` the matching radius
in the embedding. Setting `lambda` to `0` recovers plain t-SNE. The
default weight is twenty times smaller than the densMAP one, matching
the reference implementations.

## Usage

``` r
params_densne(lambda = 0.1, frac = 0.3, var_shift = 0.1)
```

## Arguments

- lambda:

  Numeric. Weight of the density term. `0` disables it. Defaults to
  `0.1`, the den-SNE reference value.

- frac:

  Numeric between 0 and 1. Fraction of the total epochs, at the end of
  the run, over which the density term is active. Defaults to `0.3`.

- var_shift:

  Numeric. Additive shift on the variance of the embedding log-radii.
  Defaults to `0.1`.

## Value

A list with the density-preservation parameters.

## References

Narayan, Berger & Cho, Nat. Biotechnol., 2021
