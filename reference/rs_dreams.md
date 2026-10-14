# DREAMS implementation

**\[experimental\]** Leverages the DREAMS implementation in
manifolds-rs. DREAMS is tSNE with an added pull towards a global
reference embedding (PCA unless one is supplied), so you keep the local
structure of tSNE and most of the global layout of the reference.
`lambda = 0` is plain tSNE, `lambda = 1` the reference.

## Usage

``` r
rs_dreams(
  embd,
  reference,
  n_dim,
  perplexity,
  approx_type,
  dreams_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- reference:

  Optional numerical matrix. Global reference embedding of dimensions
  samples x 2. If `NULL`, the first two principal components are used.

- n_dim:

  Integer. Number of DREAMS dimensions to return. Needs to be two,
  others are not supported.

- perplexity:

  Numeric. The tSNE perplexity parameter.

- approx_type:

  String. One of `c("bh", "bh_qd", "fft", "fft_3k")`. Which of the
  approximations to use.

- dreams_params:

  Named list. List that contains all of the key parameters for the
  DREAMS generation, i.e. the tSNE ones plus `lambda`.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The DREAMS embeddings.

## References

Kury, Kobak & Damrich, Transactions on Machine Learning Research, 2026
