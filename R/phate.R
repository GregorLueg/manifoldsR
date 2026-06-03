## param combination -----------------------------------------------------------

#' Internal helper to prepare the PHATE parameters
#'
#' @param knn_method Character. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param phate_params Named list. The PHATE-specific parameters.
#'
#' @return Returns the merged list of final parameters.
#'
#' @keywords internal
.prepare_phate_params <- function(
  knn_method,
  nn_params,
  phate_params
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
  assertPhateParams(phate_params)

  final_params <- c(nn_params, phate_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main function ---------------------------------------------------------------

#' Rust-based PHATE
#'
#' @description Performs PHATE dimensionality reduction on the input data.
#' This function provides a user-friendly interface with input validation
#' before calling the Rust implementation.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, PHATE will skip
#' the k-nearest neighbour graph generation and use this one instead. The `k`
#' argument must match the k used to generate this graph. Defaults to `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Currently only `2L` is supported. Defaults to `2L`.
#' @param k Integer. Number of nearest neighbours for graph construction.
#' Defaults to `5L`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param phate_params Named list. PHATE algorithm parameters, see
#' [params_phate()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the PHATE embedding.
#'
#' @export
phate <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 5L,
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
  phate_params = params_phate(),
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
  checkmate::qassert(n_dim, "I1[2,2]")
  checkmate::qassert(k, "I1[1,)")
  checkmate::assertChoice(
    knn_method,
    c("kmknn", "balltree", "hnsw", "annoy", "nndescent", "exhaustive", "ivf")
  )
  assertNnParams(nn_params)
  assertPhateParams(phate_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  final_phate_params <- .prepare_phate_params(
    knn_method = knn_method,
    nn_params = nn_params,
    phate_params = phate_params
  )

  # check if someone is trying to run this without landmarks on large datasets
  if (is.null(final_phate_params$n_landmarks) & nrow(data) >= 10000) {
    answer <- readline(
      prompt = sprintf(
        paste(
          "Data has %d rows but n_landmarks is NULL.",
          "This may be very slow. Continue without landmarks? [y/N]: "
        ),
        nrow(data)
      )
    )
    if (!tolower(trimws(answer)) %in% c("y", "yes")) {
      final_phate_params$n_landmarks <- 2048L
      if (.verbose) message("Setting n_landmarks to 2048.")
    }
  }

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_phate_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = as.integer(n_dim),
          k = as.integer(k),
          phate_params = final_phate_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("PHATE computation failed: ", e$message, call. = FALSE)
      }
    )
  } else {
    tryCatch(
      {
        rs_phate(
          embd = data,
          n_dim = as.integer(n_dim),
          k = as.integer(k),
          phate_params = final_phate_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("PHATE computation failed: ", e$message, call. = FALSE)
      }
    )
  }

  res
}
