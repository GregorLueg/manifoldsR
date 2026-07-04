# tSNE implementation

**\[experimental\]** Leverages the tSNE implementation in manifolds-rs -
a very fast Rust-based implementation. You have two optimiser options:
`"bh"` which tends to be faster on smaller datasets and `"fft"` for
large data sets. This version uses a pre-computed kNN graph, please see
[`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md).

## Usage

``` r
rs_tsne_from_knn(
  embd,
  knn_data,
  n_dim,
  perplexity,
  approx_type,
  tsne_params,
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

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64` for. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The tSNE embeddings.
