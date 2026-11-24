# LocalMAP implementation

**\[experimental\]** Leverages the LocalMAP implementation in
manifolds-rs. LocalMAP is PaCMAP with a local repulsion phase that pulls
apart clusters PaCMAP leaves touching.

## Usage

``` r
rs_localmap(embd, n_dim, localmap_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of dimensions to return.

- localmap_params:

  Named list. List that contains all of the key parameters for the
  LocalMAP generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The LocalMAP embeddings.
