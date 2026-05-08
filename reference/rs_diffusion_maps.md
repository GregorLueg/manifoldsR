# Diffusion maps implementation

This is the wrapper function into the Rust interface for diffusion maps.

## Usage

``` r
rs_diffusion_maps(embd, n_dim, k, dm_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of dimensions to return.

- k:

  Integer. Number of nearest neighbours to consider.

- dm_params:

  Named list. List that contains all of the key parameters for the
  diffusion maps generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Boolean. Controls verbosity of the function.

## Value

The diffusion maps embeddings.
