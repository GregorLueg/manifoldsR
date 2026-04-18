# pacmap -----------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the PaCMAP parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param pacmap_params Named list. The PaCMAP-specific parameters.
#' @param .verbose Boolean. Controls verbosity.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_pacmap_params <- function(
  knn_method,
  nn_params,
  pacmap_params,
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
      "exhaustive"
    )
  )
  assertNnParams(nn_params)
  assertPacmapParams(pacmap_params)
  checkmate::qassert(.verbose, "B1")

  final_params <- c(nn_params, pacmap_params)
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

#' Rust-based PaCMAP
#'
#' @description Performs PaCMAP dimensionality reduction on the input data.
#' This function provides a user-friendly interface with input validation
#' before calling the Rust implementation.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, PaCMAP will skip
#' the k-nearest neighbour graph generation and use this one. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Defaults to `2L`.
#' @param k Integer. Number of nearest neighbours to consider. Defaults to
#' `10L`. Note that the kNN search will use `mn_candidate_end` neighbours
#' internally; k only controls the near pairs used in optimisation.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, or
#' `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param pacmap_params Named list. PaCMAP algorithm parameters, see
#' [params_pacmap()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the PaCMAP embedding.
#'
#' @export
pacmap <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 10L,
  knn_method = c(
    "kmknn",
    "balltree",
    "hnsw",
    "annoy",
    "nndescent",
    "exhaustive"
  ),
  nn_params = params_nn(),
  pacmap_params = params_pacmap(),
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
  checkmate::qassert(k, "I1[2,)")
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, "B1")

  final_pacmap_params <- .prepare_pacmap_params(
    knn_method = knn_method,
    nn_params = nn_params,
    pacmap_params = pacmap_params,
    .verbose = .verbose
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_pacmap_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = n_dim,
          k = k,
          pacmap_params = final_pacmap_params,
          seed = seed,
          verbose = .verbose
        )
      },
      error = function(e) {
        stop("PaCMAP computation failed: ", e$message, call. = FALSE)
      }
    )
  } else {
    tryCatch(
      {
        rs_pacmap(
          embd = data,
          n_dim = n_dim,
          k = k,
          pacmap_params = final_pacmap_params,
          seed = seed,
          verbose = .verbose
        )
      },
      error = function(e) {
        stop("PaCMAP computation failed: ", e$message, call. = FALSE)
      }
    )
  }

  res
}
