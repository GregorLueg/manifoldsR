# Rust-based t-SNE

Performs t-SNE dimensionality reduction on the input data. This function
provides a user-friendly interface with input validation before calling
the Rust implementation.

## Usage

``` r
tsne(
  data,
  knn = NULL,
  n_dim = 2L,
  perplexity = 30,
  approx_type = c("bh", "fft"),
  knn_method = c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive"),
  nn_params = params_nn(),
  tsne_params = params_tsne(),
  seed = 42L,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, t-SNE will skip the
  k-nearest neighbour graph generation and use this one. Defaults to
  `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Currently only
  `2L` is supported. Defaults to `2L`.

- perplexity:

  Numeric. Perplexity parameter, related to the number of nearest
  neighbours used in manifold learning. Typical values are between 5
  and 50. Defaults to `30.0`.

- approx_type:

  Character. Approximation method for computing repulsive forces. One of
  `"bh"` for Barnes-Hut or `"fft"` for FFT-accelerated interpolation.
  Defaults to `"bh"`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, or
  `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- tsne_params:

  Named list. t-SNE algorithm parameters, see
  [`params_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/params_tsne.md).

- seed:

  Integer. Random seed for reproducibility.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the t-SNE
embedding.

## Details

The number of neighbours will be \`3 \* perplexity“, as this is a usual
default in tSNE.
