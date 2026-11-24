# localmap ---------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the LocalMAP parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param localmap_params Named list. The LocalMAP-specific parameters.
#' @param .verbose Logical or integer `0L` to `2L`. Controls verbosity.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_localmap_params <- function(
  knn_method,
  nn_params,
  localmap_params,
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
  assertLocalmapParams(localmap_params)
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_params <- c(nn_params, localmap_params)
  final_params[["knn_method"]] <- knn_method

  if (!is.null(final_params$n_epochs)) {
    final_params$n_epochs <- as.integer(final_params$n_epochs)
  }
  if (!is.null(final_params$phase1_end)) {
    final_params$phase1_end <- as.integer(final_params$phase1_end)
  }
  if (!is.null(final_params$phase2_end)) {
    final_params$phase2_end <- as.integer(final_params$phase2_end)
  }

  final_params
}

## main function ---------------------------------------------------------------

#' Rust-based LocalMAP
#'
#' @description Performs LocalMAP dimensionality reduction on the input data.
#' LocalMAP is PaCMAP with a different last phase: the mid-near pairs drop out
#' and every point redraws its further pairs from within `max_distance` in the
#' embedding. That local repulsion pulls apart clusters PaCMAP leaves touching.
#' Unlike NCVis or the Hogwild! UMAP optimisers, the result is the same at a
#' given seed whatever the number of threads.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, LocalMAP will
#' skip the k-nearest neighbour graph generation and use this one. Needs at
#' least `n_near` neighbours, and the near pairs are ranked from what it holds,
#' so build it `n_near + 50` wide to match the internal search. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Defaults to `2L`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"ivf"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param localmap_params Named list. LocalMAP algorithm parameters, see
#' [params_localmap()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param .verbose Logical or integer. Controls verbosity. `TRUE` or `1L` prints
#' timed stages and epochs every 50, `2L` adds parameters and the kNN internals,
#' `FALSE` or `0L` is silent. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the LocalMAP embedding.
#'
#' @references Wang, et al., arXiv:2412.15426, 2024
#'
#' @examples
#' d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
#' emb <- localmap(d$data, .verbose = FALSE)
#' dim(emb)
#'
#' @export
localmap <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  knn_method = c(
    "ivf",
    "nndescent",
    "kmknn",
    "balltree",
    "hnsw",
    "annoy",
    "exhaustive"
  ),
  nn_params = params_nn(),
  localmap_params = params_localmap(),
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
    min.rows = 2,
    min.cols = 1
  )
  checkmate::assert(
    checkmate::testNull(knn),
    checkmate::testClass(knn, "NearestNeighbours")
  )
  checkmate::assert_int(n_dim, lower = 1, upper = ncol(data))
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_localmap_params <- .prepare_localmap_params(
    knn_method = knn_method,
    nn_params = nn_params,
    localmap_params = localmap_params,
    .verbose = .verbose
  )

  res <- if (!is.null(knn)) {
    rs_localmap_from_knn(
      embd = data,
      knn_data = knn,
      n_dim = n_dim,
      localmap_params = final_localmap_params,
      seed = seed,
      verbose = parse_verbosity(.verbose)
    )
  } else {
    rs_localmap(
      embd = data,
      n_dim = n_dim,
      localmap_params = final_localmap_params,
      seed = seed,
      verbose = parse_verbosity(.verbose)
    )
  }

  res
}
