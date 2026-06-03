# Run PHATE dimensionality reduction

Wrapper function into the Rust interface for PHATE. Constructs a kNN
graph, computes alpha decay affinities, powers the diffusion operator to
time `t`, and embeds via MDS on the resulting diffusion potential
distances.

## Usage

``` r
rs_phate(embd, n_dim, k, phate_params, seed, use_high_precision, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to embed of shape samples x features.

- n_dim:

  Integer. Number of PHATE dimensions to return. Currently only `2L` is
  supported.

- k:

  Integer. Number of nearest neighbours for graph construction.

- phate_params:

  Named list. Contains all key parameters for PHATE, see
  [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md)
  and
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The PHATE embedding as a matrix of shape samples x n_dim.
