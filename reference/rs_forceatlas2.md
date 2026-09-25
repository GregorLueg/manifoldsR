# ForceAtlas2 implementation

**\[experimental\]** Leverages the ForceAtlas2 implementation in
manifolds-rs. Builds the UMAP fuzzy union graph from the data and lays
it out with ForceAtlas2.

## Usage

``` r
rs_forceatlas2(embd, k, fa2_params, seed, use_high_precision, verbose)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- k:

  Integer. Number of nearest neighbours to consider.

- fa2_params:

  Named list. List that contains all of the key parameters for the kNN
  search, graph generation and ForceAtlas2 optimisation.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64`. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The ForceAtlas2 embedding, samples x 2.
