# diffusion maps ---------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the diffusion maps parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param dm_params Named list. The diffusion maps specific parameters.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_diffusion_maps_params <- function(
  knn_method,
  nn_params,
  dm_params
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
  assertDiffusionMapsParams(dm_params)

  final_params <- c(nn_params, dm_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main function ---------------------------------------------------------------

#' Rust-based diffusion maps
#'
#' @description Performs diffusion maps dimensionality reduction on the input
#' data. This function provides a user-friendly interface with input
#' validation before calling the Rust implementation.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, diffusion maps
#' will skip the k-nearest neighbour graph generation and use this one.
#' Defaults to `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Defaults to `2L`.
#' @param k Integer. Number of nearest neighbours to consider for the
#' affinity graph. Defaults to `5L`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param dm_params Named list. Diffusion maps algorithm parameters, see
#' [params_diffusion_maps()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing the
#' diffusion maps embedding.
#'
#' @export
diffusion_maps <- function(
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
  dm_params = params_diffusion_maps(),
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
  checkmate::assert_int(n_dim, lower = 1, upper = ncol(data))
  checkmate::qassert(k, "I1[2,)")
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(seed, "I1")

  final_dm_params <- .prepare_diffusion_maps_params(
    knn_method = knn_method,
    nn_params = nn_params,
    dm_params = dm_params
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_diffusion_maps_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = n_dim,
          k = k,
          dm_params = final_dm_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop(
          "Diffusion maps computation failed: ",
          e$message,
          call. = FALSE
        )
      }
    )
  } else {
    tryCatch(
      {
        rs_diffusion_maps(
          embd = data,
          n_dim = n_dim,
          k = k,
          dm_params = final_dm_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop(
          "Diffusion maps computation failed: ",
          e$message,
          call. = FALSE
        )
      }
    )
  }

  res
}
