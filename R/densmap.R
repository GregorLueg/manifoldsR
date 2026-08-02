# densmap ----------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the densMAP parameters
#'
#' @description densMAP takes the same parameters as UMAP plus the three
#' density knobs, so this delegates to [.prepare_umap_params()] and appends
#' them.
#'
#' @param n Integer. Number of samples in the data set
#' @param min_dist Numeric. Minimum distance between embedded points.
#' @param spread Numeric. Effective scale of embedded points.
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param umap_params Named list. The UMAP-specific parameters.
#' @param dens_params Named list. The density-preservation parameters.
#' @param .verbose Boolean. Controls verbosity
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_densmap_params <- function(
  n,
  min_dist,
  spread,
  knn_method,
  nn_params,
  umap_params,
  dens_params,
  .verbose = TRUE
) {
  # checks
  assertDensParams(dens_params)

  final_params <- .prepare_umap_params(
    n = n,
    min_dist = min_dist,
    spread = spread,
    knn_method = knn_method,
    nn_params = nn_params,
    umap_params = umap_params,
    .verbose = .verbose
  )

  c(final_params, dens_params)
}

## main function ---------------------------------------------------------------

#' Rust-based densMAP
#'
#' @description Performs densMAP dimensionality reduction on the input data.
#' densMAP is UMAP with an added density-preserving term, so a tight cluster
#' stays tight and a diffuse one stays diffuse. Plain UMAP gives you no such
#' guarantee: relative sizes in the embedding mean nothing. This function
#' provides a user-friendly interface with input validation before calling the
#' Rust implementation.
#'
#' @details Setting `lambda` to `0` in [params_densmap()] recovers plain
#' [umap()] exactly. The density term is only active over the final `frac` of
#' the epochs, which is why it costs comparatively little.
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, densMAP will
#' skip the k-nearest neighbour graph generation and use this one. Defaults to
#' `NULL`.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Defaults to `2L`.
#' @param k Integer. Number of nearest neighbours to consider for manifold
#' approximation. Larger values result in more global structure being
#' preserved. Defaults to `15L`.
#' @param min_dist Numeric. Minimum distance between points in the embedding.
#' Controls how tightly points are packed. Smaller values result in more
#' clustered embeddings. Must be >= 0. Defaults to `0.5`. If you use SGD,
#' consider reducing this!
#' @param spread Numeric. Effective scale of embedded points. Determines the
#' scale at which embedded points will be spread out. Defaults to `1.0`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param umap_params Named list. UMAP algorithm parameters, see
#' [params_umap()].
#' @param dens_params Named list. Density-preservation parameters, see
#' [params_densmap()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the densMAP embedding.
#'
#' @export
#'
#' @references Narayan, Berger & Cho, Nat. Biotechnol., 2021
densmap <- function(
  data,
  knn = NULL,
  n_dim = 2L,
  k = 15L,
  min_dist = 0.5,
  spread = 1.0,
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
  umap_params = params_umap(),
  dens_params = params_densmap(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
) {
  # transformation
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
  checkmate::qassert(min_dist, "N1[0,)")
  checkmate::qassert(spread, "N1[0,)")
  assertDensParams(dens_params)
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(seed, "I1")

  final_densmap_params <- .prepare_densmap_params(
    n = nrow(data),
    min_dist = min_dist,
    spread = spread,
    knn_method = knn_method,
    nn_params = nn_params,
    umap_params = umap_params,
    dens_params = dens_params,
    .verbose = .verbose
  )

  # check if knn was provided
  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    tryCatch(
      {
        rs_densmap_from_knn(
          embd = data,
          knn_data = knn,
          n_dim = n_dim,
          min_dist = min_dist,
          spread = spread,
          k = k,
          densmap_params = final_densmap_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("densMAP computation failed: ", e$message, call. = FALSE)
      }
    )
  } else {
    tryCatch(
      {
        rs_densmap(
          embd = data,
          n_dim = n_dim,
          min_dist = min_dist,
          spread = spread,
          k = k,
          densmap_params = final_densmap_params,
          seed = seed,
          use_high_precision = use_high_precision,
          verbose = parse_verbosity(.verbose)
        )
      },
      error = function(e) {
        stop("densMAP computation failed: ", e$message, call. = FALSE)
      }
    )
  }

  res
}
