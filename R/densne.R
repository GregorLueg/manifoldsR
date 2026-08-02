# densne -----------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the den-SNE parameters
#'
#' @description den-SNE takes the same parameters as t-SNE plus the three
#' density knobs, so this delegates to [.prepare_tsne_params()] and appends
#' them.
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param tsne_params Named list. The t-SNE-specific parameters.
#' @param dens_params Named list. The density-preservation parameters.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_densne_params <- function(
  knn_method,
  nn_params,
  tsne_params,
  dens_params
) {
  # checks
  assertDensParams(dens_params)

  final_params <- .prepare_tsne_params(
    knn_method = knn_method,
    nn_params = nn_params,
    tsne_params = tsne_params
  )

  c(final_params, dens_params)
}

## main function ---------------------------------------------------------------

#' Rust-based den-SNE
#'
#' @description Performs den-SNE dimensionality reduction on the input data.
#' den-SNE is t-SNE with an added density-preserving term, so a tight cluster
#' stays tight and a diffuse one stays diffuse. Plain t-SNE gives you no such
#' guarantee: relative sizes in the embedding mean nothing. This function
#' provides a user-friendly interface with input validation before calling the
#' Rust implementation.
#'
#' @details The number of neighbours will be `3 * perplexity`, as this is a
#' usual default in tSNE. Setting `lambda` to `0` in [params_densne()] recovers
#' plain [tsne()] exactly. The default `lambda` is twenty times smaller than the
#' densMAP one, matching the reference implementations.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, den-SNE will skip
#' the k-nearest neighbour graph generation and use this one. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Currently only `2L` is supported. Defaults to `2L`.
#' @param perplexity Numeric. Perplexity parameter, related to the number of
#' nearest neighbours used in manifold learning. Typical values are between
#' 5 and 50. Defaults to `20.0`.
#' @param approx_type Character. Approximation method for computing repulsive
#' forces. One of `"bh"` for Barnes-Hut or `"fft"` for FFT-accelerated
#' interpolation. Defaults to `"bh"`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param tsne_params Named list. t-SNE algorithm parameters, see
#' [params_tsne()].
#' @param dens_params Named list. Density-preservation parameters, see
#' [params_densne()].
#' @param seed Integer. Random seed for reproducibility.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the den-SNE embedding.
#'
#' @export
#'
#' @references Narayan, Berger & Cho, Nat. Biotechnol., 2021
densne <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  perplexity = 20.0,
  approx_type = c("bh", "fft"),
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
  dens_params = params_densne(),
  seed = 42L,
  use_high_precision = NULL,
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
    c("kmknn", "hnsw", "annoy", "nndescent", "balltree", "exhaustive", "ivf")
  )
  assertNnParams(nn_params)
  assertTsneParams(tsne_params)
  assertDensParams(dens_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(use_high_precision, c("B1", "0"))
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))

  # warning when on windows...
  if (approx_type == "fft" && .Platform$OS.type != "unix") {
    stop(
      "The FFT approximation is not supported on non-Unix systems.",
      call. = FALSE
    )
  }

  final_densne_params <- .prepare_densne_params(
    knn_method = knn_method,
    nn_params = nn_params,
    tsne_params = tsne_params,
    dens_params = dens_params
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_densne_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = as.integer(n_dim),
          perplexity = perplexity,
          approx_type = approx_type,
          densne_params = final_densne_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("den-SNE computation failed: ", e$message, call. = FALSE)
      }
    )
  } else {
    tryCatch(
      {
        rs_densne(
          embd = data,
          n_dim = as.integer(n_dim),
          perplexity = perplexity,
          approx_type = approx_type,
          densne_params = final_densne_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("den-SNE computation failed: ", e$message, call. = FALSE)
      }
    )
  }

  res
}
