# dreams -----------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the DREAMS parameters
#'
#' @description DREAMS takes the same parameters as t-SNE plus `lambda`, so
#' this delegates to [.prepare_tsne_params()] and appends it.
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param tsne_params Named list. The t-SNE-specific parameters.
#' @param dreams_params Named list. The DREAMS parameters.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_dreams_params <- function(
  knn_method,
  nn_params,
  tsne_params,
  dreams_params
) {
  # checks
  assertDreamsParams(dreams_params)

  final_params <- .prepare_tsne_params(
    knn_method = knn_method,
    nn_params = nn_params,
    tsne_params = tsne_params
  )

  c(final_params, dreams_params)
}

## main function ---------------------------------------------------------------

#' Rust-based DREAMS
#'
#' @description Performs DREAMS dimensionality reduction on the input data.
#' DREAMS is t-SNE with a pull towards a global reference embedding, PCA by
#' default. You get the local cluster structure of t-SNE, and the relative
#' positions of the clusters still mean something. Plain t-SNE makes no such
#' promise. This function provides a user-friendly interface with input
#' validation before calling the Rust implementation.
#'
#' @details The number of neighbours will be `3 * perplexity`, as this is a
#' usual default in tSNE. Setting `lambda` to `0` in [params_dreams()] gives
#' t-SNE started from the reference, `1` returns the (scaled) reference. The
#' `init` element of `tsne_params` is ignored: DREAMS always initialises from
#' its reference.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, DREAMS will skip
#' the k-nearest neighbour graph generation and use this one. Defaults to
#' `NULL`.
#' @param reference Optional numerical matrix or data frame of shape
#' samples x 2. Global reference embedding to regularise towards, e.g. a PHATE
#' or MDS result. If `NULL`, the first two principal components are used.
#' Defaults to `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Currently only `2L` is supported. Defaults to `2L`.
#' @param perplexity Numeric. Perplexity parameter, related to the number of
#' nearest neighbours used in manifold learning. Typical values are between
#' 5 and 50. Defaults to `20.0`.
#' @param approx_type Character. Approximation method for computing repulsive
#' forces. One of `"bh"` for Barnes-Hut, `"bh_qd"` for the quick-and-dirty
#' Barnes-Hut of qdtsne (tree depth capped at `max_depth` in [params_tsne()],
#' repulsion computed once per leaf), `"fft"` for FFT-accelerated
#' interpolation or `"fft_3k"` for the three-kernel variant of the latter (one
#' forward and three inverse FFTs per epoch instead of four each). Defaults to
#' `"bh"`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param tsne_params Named list. t-SNE algorithm parameters, see
#' [params_tsne()].
#' @param dreams_params Named list. DREAMS parameters, see [params_dreams()].
#' @param seed Integer. Random seed for reproducibility.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the DREAMS embedding.
#'
#' @export
#'
#' @references Kury, Kobak & Damrich, Transactions on Machine Learning
#' Research, 2026
#'
#' @examples
#' d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
#' emb <- dreams(d$data, .verbose = FALSE)
#' dim(emb)
dreams <- function(
  data,
  knn = NULL,
  reference = NULL,
  n_dim = 2L,
  perplexity = 20.0,
  approx_type = c("bh", "bh_qd", "fft", "fft_3k"),
  knn_method = c(
    "kmknn",
    "balltree",
    "hnsw",
    "annoy",
    "nndescent",
    "exhaustive",
    "ivf"
  ),
  nn_params = params_nn(),
  tsne_params = params_tsne(),
  dreams_params = params_dreams(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
) {
  if (is.data.frame(data)) {
    data <- as.matrix(data)
  }
  if (is.data.frame(reference)) {
    reference <- as.matrix(reference)
  }
  approx_type <- match.arg(approx_type)
  knn_method <- match.arg(knn_method)

  checkmate::assert_matrix(
    data,
    mode = "numeric",
    any.missing = FALSE,
    min.rows = 2,
    min.cols = 1
  )
  checkmate::assert(
    checkmate::testNull(knn),
    checkmate::testClass(knn, "NearestNeighbours")
  )
  checkmate::assert_matrix(
    reference,
    mode = "numeric",
    any.missing = FALSE,
    nrows = nrow(data),
    ncols = 2L,
    null.ok = TRUE
  )
  checkmate::qassert(n_dim, "I1[2,2]")
  checkmate::qassert(perplexity, "N1[1,)")
  checkmate::assertChoice(
    approx_type,
    c("bh", "bh_qd", "fft", "fft_3k")
  )
  checkmate::assertChoice(
    knn_method,
    c("kmknn", "hnsw", "annoy", "nndescent", "balltree", "exhaustive", "ivf")
  )
  assertNnParams(nn_params)
  assertTsneParams(tsne_params)
  assertDreamsParams(dreams_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(use_high_precision, c("B1", "0"))
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  # Rust expects a double matrix; an integer one would fail the conversion
  if (!is.null(reference)) {
    storage.mode(reference) <- "double"
  }

  final_dreams_params <- .prepare_dreams_params(
    knn_method = knn_method,
    nn_params = nn_params,
    tsne_params = tsne_params,
    dreams_params = dreams_params
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    rs_dreams_from_knn(
      embd = data,
      knn_data = knn,
      reference = reference,
      n_dim = as.integer(n_dim),
      perplexity = perplexity,
      approx_type = approx_type,
      dreams_params = final_dreams_params,
      seed = seed,
      use_high_precision = use_high_precision,
      verbose = parse_verbosity(.verbose)
    )
  } else {
    rs_dreams(
      embd = data,
      reference = reference,
      n_dim = as.integer(n_dim),
      perplexity = perplexity,
      approx_type = approx_type,
      dreams_params = final_dreams_params,
      seed = seed,
      use_high_precision = use_high_precision,
      verbose = parse_verbosity(.verbose)
    )
  }

  res
}
