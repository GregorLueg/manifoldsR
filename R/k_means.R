# k-means ----------------------------------------------------------------------

#' K-means clustering
#'
#' @description Performs k-means clustering on the input data. Supports both
#'   full Lloyd's iterations (with SIMD/GEMM acceleration) and mini-batch
#'   k-means (Sculley 2010) for large data sets.
#'
#' @param data Numerical matrix or data frame. The data to cluster, of shape
#'   samples x features. Will be coerced to a matrix.
#' @param k Integer. Number of clusters to create. Must be >= 2.
#' @param method Character. Clustering method. One of `"full"` (Lloyd's
#'   algorithm) or `"minibatch"` (mini-batch k-means). Defaults to `"full"`.
#' @param kmeans_params Named list. K-means parameters, see [params_kmeans()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A named list with:
#' \describe{
#'   \item{centroids}{Numeric matrix of shape k x features containing the
#'     final cluster centroids.}
#'   \item{assignments}{Integer vector of length samples with cluster
#'     assignments (1-indexed).}
#' }
#'
#' @export
kmeans_cluster <- function(
  data,
  k,
  method = c("full", "minibatch"),
  kmeans_params = params_kmeans(),
  seed = 42L,
  .verbose = TRUE
) {
  if (is.data.frame(data)) {
    data <- as.matrix(data)
  }
  method <- match.arg(method)

  checkmate::assert_matrix(
    data,
    mode = "numeric",
    any.missing = FALSE,
    min.rows = 2,
    min.cols = 1
  )
  checkmate::assert_int(k, lower = 2L, upper = nrow(data))
  assertKmeansParams(kmeans_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, "B1")

  k <- as.integer(k)

  res <- tryCatch(
    {
      if (method == "minibatch") {
        if (.verbose) {
          message(
            sprintf(
              "Running mini-batch k-means (k=%d, batch_size=%d, metric=%s)",
              k,
              kmeans_params$batch_size,
              kmeans_params$metric
            )
          )
        }
        rs_k_means_mini_batch(
          data = data,
          k = k,
          kmeans_params = kmeans_params,
          seed = seed,
          verbose = .verbose
        )
      } else {
        if (.verbose) {
          message(
            sprintf(
              "Running full k-means (k=%d, metric=%s)",
              k,
              kmeans_params$metric
            )
          )
        }
        rs_k_means(
          data = data,
          k = k,
          kmeans_params = kmeans_params,
          seed = seed,
          verbose = .verbose
        )
      }
    },
    error = function(e) {
      stop("K-means clustering failed: ", e$message, call. = FALSE)
    }
  )

  new_kmeans_cluster(
    centroids = res$centroids,
    assignments = res$assignments,
    k = k,
    method = method,
    metric = kmeans_params$metric
  )
}
