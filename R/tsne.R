# tsne -------------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the t-SNE parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param tsne_params Named list. The t-SNE-specific parameters.
#' @param .verbose Boolean. Controls verbosity.
#'
#' @return Returns the list of final parameters.
#'
#' @export
.prepare_tsne_params <- function(
  knn_method,
  nn_params,
  tsne_params
) {
  checkmate::assertChoice(
    knn_method,
    c("hnsw", "annoy", "nndescent", "balltree", "exhaustive")
  )
  assertNnParams(nn_params)
  assertTsneParams(tsne_params)

  final_params <- c(nn_params, tsne_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main function ---------------------------------------------------------------

#' Rust-based t-SNE
#'
#' @description Performs t-SNE dimensionality reduction on the input data.
#' This function provides a user-friendly interface with input validation
#' before calling the Rust implementation.
#'
#' @details The number of neighbours will be `3 * perplexity``, as this is a
#' usual default in tSNE.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, t-SNE will skip
#' the k-nearest neighbour graph generation and use this one. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Currently only `2L` is supported. Defaults to `2L`.
#' @param perplexity Numeric. Perplexity parameter, related to the number of
#' nearest neighbours used in manifold learning. Typical values are between
#' 5 and 50. Defaults to `30.0`.
#' @param approx_type Character. Approximation method for computing repulsive
#' forces. One of `"bh"` for Barnes-Hut or `"fft"` for FFT-accelerated
#' interpolation. Defaults to `"bh"`.
#' @param knn_method Character. Approximate nearest neighbour algorithm to use.
#' One of `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, or
#' `"exhaustive"`. Defaults to `"hnsw"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param tsne_params Named list. t-SNE algorithm parameters, see
#' [params_tsne()].
#' @param seed Integer. Random seed for reproducibility.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the t-SNE embedding.
#'
#' @export
tsne <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  perplexity = 30.0,
  approx_type = c("bh", "fft"),
  knn_method = c("hnsw", "annoy", "nndescent", "balltree", "exhaustive"),
  nn_params = params_nn(),
  tsne_params = params_tsne(),
  seed = 42L,
  .verbose = TRUE
) {
  if (is.data.frame(data)) {
    data <- as.matrix(data)
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
  checkmate::qassert(n_dim, "I1[2,2]")
  checkmate::qassert(perplexity, "N1[1,)")
  checkmate::assertChoice(
    approx_type,
    c("bh", "fft")
  )
  checkmate::assertChoice(
    knn_method,
    c("hnsw", "annoy", "nndescent", "balltree", "exhaustive")
  )
  assertNnParams(nn_params)
  assertTsneParams(tsne_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, "B1")

  # warning when on windows...
  if (approx_type == "fft" && .Platform$OS.type != "unix") {
    stop(
      "The FFT approximation is not supported on non-Unix systems.",
      call. = FALSE
    )
  }

  final_tsne_params <- .prepare_tsne_params(
    knn_method = knn_method,
    nn_params = nn_params,
    tsne_params = tsne_params
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_tsne_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = as.integer(n_dim),
          perplexity = perplexity,
          approx_type = approx_type,
          tsne_params = final_tsne_params,
          seed = seed,
          verbose = .verbose
        )
      },
      error = function(e) {
        stop("t-SNE computation failed: ", e$message, call. = FALSE)
      }
    )
  } else {
    tryCatch(
      {
        rs_tsne(
          embd = data,
          n_dim = as.integer(n_dim),
          perplexity = perplexity,
          approx_type = approx_type,
          tsne_params = final_tsne_params,
          seed = seed,
          verbose = .verbose
        )
      },
      error = function(e) {
        stop("t-SNE computation failed: ", e$message, call. = FALSE)
      }
    )
  }

  res
}
