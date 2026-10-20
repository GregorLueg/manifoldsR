# Wrapper function to generate DREAMS parameters

The regularisation knob on top of the usual t-SNE parameters. DREAMS
pulls every t-SNE epoch towards a scaled global reference embedding (PCA
unless one is supplied). Setting `lambda` to `0` recovers plain t-SNE,
`1` the reference.

## Usage

``` r
params_dreams(lambda = 0.15)
```

## Arguments

- lambda:

  Numeric. Regularisation strength. Larger values pull harder towards
  the reference layout. The default is the DREAMS reference value.
  Defaults to `0.15`.

## Value

A named list with the following elements:

- lambda - Numeric. Regularisation strength. Larger values pull harder
  towards the reference layout. The default is the DREAMS reference
  value. Defaults to `0.15`.

## References

Kury, Kobak & Damrich, Transactions on Machine Learning Research, 2026

## Examples

``` r
params_dreams()
#> $lambda
#> [1] 0.15
#> 
params_dreams(lambda = 0.3)
#> $lambda
#> [1] 0.3
#> 
```
