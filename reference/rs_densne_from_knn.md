# den-SNE implementation

**\[experimental\]** Leverages the den-SNE implementation in
manifolds-rs - a very fast Rust-based implementation. den-SNE is tSNE
with an added density-preserving term, so tight clusters stay tight and
diffuse ones stay diffuse. This version uses a pre-computed kNN graph,
please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_densne_from_knn(
  embd,
  knn_data,
  n_dim,
  perplexity,
  approx_type,
  densne_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- embd:

  Numerical matrix. The data to use to generate the embeddings. Should
  be of dimensions samples x features.

- knn_data:

  `NearestNeighbours` class from R.

- n_dim:

  Integer. Number of den-SNE dimensions to return. Needs to be two,
  others are not supported.

- perplexity:

  Numeric. The tSNE perplexity parameter.

- approx_type:

  String. One of `c("fft", "bh")`. Which of the two approximations to
  use.

- densne_params:

  Named list. List that contains all of the key parameters for the
  den-SNE generation, i.e. the tSNE ones plus `lambda`, `frac` and
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

The den-SNE embeddings.

## References

Narayan, Berger & Cho, Nature Biotechnology, 2021
