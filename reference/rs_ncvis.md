# NCVis implementation

**\[experimental\]** Leverages the NCVis implementation in manifolds-rs:
noise-contrastive Hogwild! SGD on the unweighted kNN graph, with the
NCVis+ defaults. Only reproducible at a fixed seed on a single thread.

## Usage

``` r
rs_ncvis(embd, n_dim, min_dist, spread, k, ncvis_params, seed, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of dimensions to return.

- min_dist:

  Numeric. Minimum distance, fits the kernel's `a` and `b`.

- spread:

  Numeric. Spread, fits the kernel's `a` and `b`.

- k:

  Integer. Number of nearest neighbours.

- ncvis_params:

  Named list. List that contains all of the key parameters for the NCVis
  generation.

- seed:

  Integer. Seed for reproducibility.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The NCVis embeddings.
