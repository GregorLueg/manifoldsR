# Wrapper function to generate densMAP parameters

The density-preservation knobs on top of the usual UMAP parameters.
densMAP adds `-lambda * Corr(log Ro, log Re)` to the UMAP loss, where
`Ro` is the local radius in the input space and `Re` the matching radius
in the embedding. Setting `lambda` to `0` recovers plain UMAP.

## Usage

``` r
params_densmap(lambda = 2, frac = 0.3, var_shift = 0.1)
```

## Arguments

- lambda:

  Numeric. Weight of the density term. `0` disables it. The default is
  the densMAP reference value. Defaults to `2.0`.

- frac:

  Numeric. Fraction of the total epochs, at the end of the run, over
  which the density term is active. Defaults to `0.3`.

- var_shift:

  Numeric. Additive shift on the variance of the embedding log-radii.
  Defaults to `0.1`.

## Value

A named list with the following elements:

- lambda - Numeric. Weight of the density term. `0` disables it. The
  default is the densMAP reference value. Defaults to `2.0`.

- frac - Numeric. Fraction of the total epochs, at the end of the run,
  over which the density term is active. Defaults to `0.3`.

- var_shift - Numeric. Additive shift on the variance of the embedding
  log-radii. Defaults to `0.1`.

## References

Narayan, Berger & Cho, Nat. Biotechnol., 2021
