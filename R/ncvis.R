# ncvis ------------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the NCVis parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param ncvis_params Named list. The NCVis-specific parameters.
#' @param .verbose Logical or integer `0L` to `2L`. Controls verbosity.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_ncvis_params <- function(
  knn_method,
  nn_params,
  ncvis_params,
  .verbose = TRUE
) {
  checkmate::assertChoice(
    knn_method,
    c(
      "kmknn",
      "balltree",
      "hnsw",
      "annoy",
      "nndescent",
      "exhaustive",
      "ivf"
    )
  )
  assertNnParams(nn_params)
  assertNcvisParams(ncvis_params)
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_params <- c(nn_params, ncvis_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main function ---------------------------------------------------------------

#' Rust-based NCVis
#'
#' @description Performs NCVis dimensionality reduction on the input data.
#' NCVis runs noise-contrastive SGD on the unweighted kNN graph: every edge
#' pulls, a handful of random negatives per edge push, and a learnt
#' normalisation constant `Q` replaces UMAP's fixed repulsion weight. The
#' defaults are the NCVis+ ones (PCA start, `min_dist = 0.001`, learning rate
#' `2`, 10 negatives per edge). The optimiser is Hogwild! SGD, so the result is
#' only reproducible at a fixed seed on a single thread.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, NCVis will skip
#' the k-nearest neighbour graph generation and use this one. The distances are
#' ignored. A wider graph is cut to `k`, with a warning on stderr. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Defaults to `2L`.
#' @param k Integer. Number of nearest neighbours. Defaults to `15L`.
#' @param min_dist Numeric. Minimum distance between points in the embedding,
#' fits the `a` and `b` of the kernel like in UMAP. Must be >= 0. Defaults to
#' `0.001`.
#' @param spread Numeric. Effective scale of embedded points, fits the `a` and
#' `b` of the kernel. Defaults to `1.0`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"nndescent"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param ncvis_params Named list. NCVis algorithm parameters, see
#' [params_ncvis()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param .verbose Logical or integer. Controls verbosity. `TRUE` or `1L` prints
#' timed stages, `2L` adds parameters and the kNN internals, `FALSE` or `0L` is
#' silent. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the NCVis embedding.
#'
#' @references Artemenkov & Panov, WWW, 2020; Pedersen, NCVis+, 2026
#' (https://github.com/SeanPedersen/ncvis-plus)
#'
#' @examples
#' d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
#' emb <- ncvis(d$data, .verbose = FALSE)
#' dim(emb)
#'
#' @export
ncvis <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 15L,
  min_dist = 0.001,
  spread = 1.0,
  knn_method = c(
    "nndescent",
    "kmknn",
    "balltree",
    "hnsw",
    "annoy",
    "exhaustive",
    "ivf"
  ),
  nn_params = params_nn(),
  ncvis_params = params_ncvis(),
  seed = 42L,
  .verbose = TRUE
) {
  if (is.data.frame(data)) {
    data <- as.matrix(data)
  }
  knn_method <- match.arg(knn_method)

  checkmate::assert_matrix(
    data,
    mode = "numeric",
    any.missing = FALSE,
    min.rows = 3,
    min.cols = 1
  )
  checkmate::assert(
    checkmate::testNull(knn),
    checkmate::testClass(knn, "NearestNeighbours")
  )
  checkmate::assert_int(n_dim, lower = 1, upper = ncol(data))
  checkmate::qassert(k, "I1[2,)")
  checkmate::qassert(min_dist, "N1[0,)")
  checkmate::qassert(spread, "N1(0,)")
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_ncvis_params <- .prepare_ncvis_params(
    knn_method = knn_method,
    nn_params = nn_params,
    ncvis_params = ncvis_params,
    .verbose = .verbose
  )

  res <- if (!is.null(knn)) {
    rs_ncvis_from_knn(
      embd = data,
      knn_data = knn,
      n_dim = n_dim,
      min_dist = min_dist,
      spread = spread,
      k = k,
      ncvis_params = final_ncvis_params,
      seed = seed,
      verbose = parse_verbosity(.verbose)
    )
  } else {
    rs_ncvis(
      embd = data,
      n_dim = n_dim,
      min_dist = min_dist,
      spread = spread,
      k = k,
      ncvis_params = final_ncvis_params,
      seed = seed,
      verbose = parse_verbosity(.verbose)
    )
  }

  res
}
