# Run PHATE dimensionality reduction

**\[experimental\]** Leverages the PHATE implementation in
manifolds-rs - a very fast Rust-based implementation.

## Usage

``` r
rs_phate(embd, n_dim, k, phate_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to embed of shape samples x features.

- n_dim:

  Integer. Number of PHATE dimensions to return. Currently only `2L` is
  supported.

- k:

  Integer. Number of nearest neighbours that set the kernel bandwidth.
  The kNN search itself runs `6 * k + 5` wide.

- phate_params:

  Named list. Contains all key parameters for PHATE, see
  [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md)
  and
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The PHATE embedding as a matrix of shape samples x n_dim.
