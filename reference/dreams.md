# Rust-based DREAMS

Performs DREAMS dimensionality reduction on the input data. DREAMS is
t-SNE with a pull towards a global reference embedding, PCA by default.
You get the local cluster structure of t-SNE, and the relative positions
of the clusters still mean something. Plain t-SNE makes no such promise.
This function provides a user-friendly interface with input validation
before calling the Rust implementation.

## Usage

``` r
dreams(
  data,
  knn = NULL,
  reference = NULL,
  n_dim = 2L,
  perplexity = 20,
  approx_type = c("bh", "bh_qd", "fft", "fft_3k"),
  knn_method = c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive", "ivf"),
  nn_params = params_nn(),
  tsne_params = params_tsne(),
  dreams_params = params_dreams(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
)
```

## Arguments

- data:

  Numerical matrix or data frame. The data to embed of shape samples x
  features. Will be coerced to a matrix.

- knn:

  Optional `NearestNeighbours` class. If provided, DREAMS will skip the
  k-nearest neighbour graph generation and use this one. Defaults to
  `NULL`.

- reference:

  Optional numerical matrix or data frame of shape samples x 2. Global
  reference embedding to regularise towards, e.g. a PHATE or MDS result.
  If `NULL`, the first two principal components are used. Defaults to
  `NULL`.

- n_dim:

  Integer. Number of dimensions in the embedding space. Currently only
  `2L` is supported. Defaults to `2L`.

- perplexity:

  Numeric. Perplexity parameter, related to the number of nearest
  neighbours used in manifold learning. Typical values are between 5
  and 50. Defaults to `20.0`.

- approx_type:

  Character. Approximation method for computing repulsive forces. One of
  `"bh"` for Barnes-Hut, `"bh_qd"` for the quick-and-dirty Barnes-Hut of
  qdtsne (tree depth capped at `max_depth` in
  [`params_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/params_tsne.md),
  repulsion computed once per leaf), `"fft"` for FFT-accelerated
  interpolation or `"fft_3k"` for the three-kernel variant of the latter
  (one forward and three inverse FFTs per epoch instead of four each).
  Defaults to `"bh"`.

- knn_method:

  Character. (Approximate) Nearest neighbour method to use. One of
  `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
  or `"exhaustive"`. Defaults to `"kmknn"`.

- nn_params:

  Named list. Nearest neighbour search parameters, see
  [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md).

- tsne_params:

  Named list. t-SNE algorithm parameters, see
  [`params_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/params_tsne.md).

- dreams_params:

  Named list. DREAMS parameters, see
  [`params_dreams()`](https://gregorlueg.github.io/manifoldsR/reference/params_dreams.md).

- seed:

  Integer. Random seed for reproducibility.

- use_high_precision:

  Optional boolean. Gives fine-grained control over `fp32` vs `fp64`
  usage.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions samples x n_dim containing the DREAMS
embedding.

## Details

The number of neighbours will be `3 * perplexity`, as this is a usual
default in tSNE. Setting `lambda` to `0` in
[`params_dreams()`](https://gregorlueg.github.io/manifoldsR/reference/params_dreams.md)
gives t-SNE started from the reference, `1` returns the (scaled)
reference. The `init` element of `tsne_params` is ignored: DREAMS always
initialises from its reference.

## References

Kury, Kobak & Damrich, Transactions on Machine Learning Research, 2026

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
emb <- dreams(d$data, .verbose = FALSE)
dim(emb)
#> [1] 500   2
```
