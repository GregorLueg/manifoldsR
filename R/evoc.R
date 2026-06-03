# evoc -------------------------------------------------------------------------

## helpers ---------------------------------------------------------------------

#' Internal helper to prepare EVoC parameters
#'
#' @param knn_method String. Method for kNN graph generation.
#' @param nn_params Named list. Nearest neighbour search parameters.
#' @param evoc_params Named list. EVoC-specific parameters.
#'
#' @return The merged list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_evoc_params <- function(
  knn_method,
  nn_params,
  evoc_params
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
  assertEvocParams(evoc_params)

  final_params <- c(nn_params, evoc_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main ------------------------------------------------------------------------

#' Rust-based EVoC clustering
#'
#' @description Performs EVoC (Embedding Vector Oriented Clustering) on the
#' input data. Combines a UMAP-like node embedding with HDBSCAN-style
#' density-based clustering and multi-layer persistence analysis.
#'
#' @param data Numerical matrix or data frame. The data to cluster, of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, EVoC will skip
#' the kNN graph generation and use this one. Defaults to `NULL`.
#' @param n_neighbours Integer. Number of nearest neighbours for graph
#' construction. Defaults to `15L`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param evoc_params Named list. EVoC algorithm parameters, see
#' [params_evoc()].
#' @param return_knn Logical. Whether to return the kNN graph. If `knn` is
#' provided, it is returned as-is. Defaults to `FALSE`.
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return An `Evoc` S3 object (see [print.Evoc], [best_membership],
#' [get_layer]).
#'
#' @export
evoc <- function(
  data,
  knn = NULL,
  n_neighbours = 15L,
  knn_method = c(
    "kmknn",
    "hnsw",
    "annoy",
    "nndescent",
    "balltree",
    "ivf",
    "exhaustive"
  ),
  nn_params = params_nn(),
  evoc_params = params_evoc(),
  return_knn = FALSE,
  seed = 42L,
  use_high_precision = NULL,
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
  checkmate::qassert(n_neighbours, "I1[2,)")
  checkmate::qassert(return_knn, "B1")
  checkmate::qassert(seed, "I1")
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_params <- .prepare_evoc_params(
    knn_method = knn_method,
    nn_params = nn_params,
    evoc_params = evoc_params
  )

  if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    raw <- tryCatch(
      rs_evoc_from_knn(
        embd = data,
        knn_data = knn,
        n_neighbours = n_neighbours,
        evoc_params = final_params,
        seed = seed,
        use_high_precision = use_high_precision,
        verbose = parse_verbosity(.verbose)
      ),
      error = function(e) {
        stop("EVoC clustering failed: ", e$message, call. = FALSE)
      }
    )

    knn_out <- if (return_knn) knn else NULL
  } else {
    raw <- tryCatch(
      rs_evoc(
        embd = data,
        n_neighbours = n_neighbours,
        evoc_params = final_params,
        return_knn = return_knn,
        seed = seed,
        use_high_precision = use_high_precision,
        verbose = parse_verbosity(.verbose)
      ),
      error = function(e) {
        stop("EVoC clustering failed: ", e$message, call. = FALSE)
      }
    )

    knn_out <- if (return_knn && !is.null(raw$knn)) {
      knn_raw <- raw$knn
      new_nearest_neighbour(
        indices = knn_raw$indices,
        dist = knn_raw$dist,
        k = as.integer(knn_raw$k),
        n = as.integer(knn_raw$n)
      )
    } else {
      NULL
    }
    # rs_evoc wraps in evoc_res/knn; unwrap
    raw <- raw$evoc_res
  }

  new_evoc(
    cluster_layers = raw$cluster_layers,
    membership_strengths = raw$membership_strengths,
    persistence_scores = raw$persistence_scores,
    knn = knn_out
  )
}
