# PaCMAP implementation

**\[experimental\]** Leverages the PacMAP implementation in
manifolds-rs - a very fast Rust-based implementation.

## Usage

``` r
rs_pacmap(embd, n_dim, pacmap_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of dimensions to return.

- pacmap_params:

  Named list. List that contains all of the key parameters for the
  PaCMAP generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The PaCMAP embeddings.
