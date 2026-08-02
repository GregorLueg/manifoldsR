# densMAP implementation

**\[experimental\]** Leverages the densMAP implementation in
manifolds-rs - a very fast Rust-based implementation. densMAP is UMAP
with an added density-preserving term, so tight clusters stay tight and
diffuse ones stay diffuse. Setting `lambda` to `0` in the parameters
recovers plain UMAP.

## Usage

``` r
rs_densmap(
  embd,
  n_dim,
  min_dist,
  spread,
  k,
  densmap_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- n_dim:

  Integer. Number of densMAP dimensions to return.

- min_dist:

  Numeric. Minimum distance to use.

- spread:

  Numeric. Spread parameter to use.

- k:

  Integer. Number of nearest neighbours to consider

- densmap_params:

  Named list. List that contains all of the key parameters for the
  densMAP generation, i.e. the UMAP ones plus `lambda`, `frac` and
  `var_shift`.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The densMAP embeddings.

## References

Narayan, Berger & Cho, Nature Biotechnology, 2021
