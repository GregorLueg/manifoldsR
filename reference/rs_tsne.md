# tSNE implementation

This is the wrapper function into the Rust interface for tSNE. You have
the option to use the Barnes-Hut implemetation or the FFT-accelerated
version to approximate the repulsive forces. Uses `fp64` path on larger
data sets to avoid catastrophic cancelleation.

## Usage

``` r
rs_tsne(embd, n_dim, perplexity, approx_type, tsne_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of tSNE dimensions to return. Needs to be two, others
  are not supported.

- perplexity:

  Numeric. The tSNE perplexity parameter.

- approx_type:

  String. One of `c("fft", "bh")`. Which of the two approximations to
  use.

- tsne_params:

  Named list. List that contains all of the key parameters for the tSNE
  generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The tSNE embeddings.
