# k-means ----------------------------------------------------------------------

#' K-means clustering
#'
#' @description Performs k-means clustering on the input data. Three methods:
#' e-means (the default), full Lloyd's iterations (with SIMD/GEMM acceleration)
#' and Sculley's mini-batch k-means. e-means runs mini-batch EMA updates with a
#' batch size and step fitted to the data, and matches or beats Lloyd's loss in
#' a handful of passes over the data.
#'
#' @param data Numerical matrix or data frame. The data to cluster, of shape
#' samples x features. Will be coerced to a matrix.
#' @param k Integer. Number of clusters to create. Must be >= 2.
#' @param method Character. Clustering method. One of `"emeans"` (e-means),
#' `"lloyd"` (Lloyd's algorithm) or `"minibatch"` (Sculley's mini-batch
#' k-means). `"full"` is a deprecated alias of `"lloyd"`. Defaults to
#' `"emeans"`.
#' @param kmeans_params Named list. K-means parameters, see [params_kmeans()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A named list with:
#' \describe{
#'  \item{centroids}{Numeric matrix of shape k x features containing the
#'  final cluster centroids.}
#'  \item{assignments}{Integer vector of length samples with cluster
#'  assignments (1-indexed).}
#' }
#'
#' @references Bessa, et al., arXiv:2611.09501, 2026 (e-means)
#'
#' @examples
#' d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
#' km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
#' km
#'
#' @export
kmeans_cluster <- function(
  data,
  k,
  method = c("emeans", "lloyd", "minibatch"),
  kmeans_params = params_kmeans(),
  seed = 42L,
  .verbose = TRUE
) {
  if (is.data.frame(data)) {
    data <- as.matrix(data)
  }
  if (identical(method, "full")) {
    lifecycle::deprecate_warn(
      "0.7.0",
      I('kmeans_cluster(method = "full")'),
      I('kmeans_cluster(method = "lloyd")')
    )
    method <- "lloyd"
  }
  method <- match.arg(method)
  checkmate::assertChoice(method, c("emeans", "lloyd", "minibatch"))

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

  res <- if (method == "minibatch") {
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
          "Running %s (k=%d, metric=%s)",
          if (method == "emeans") "e-means" else "Lloyd's k-means",
          k,
          kmeans_params$metric
        )
      )
    }
    rs_k_means(
      data = data,
      k = k,
      algorithm = method,
      kmeans_params = kmeans_params,
      seed = seed,
      verbose = .verbose
    )
  }

  new_kmeans_cluster(
    centroids = res$centroids,
    assignments = res$assignments,
    k = k,
    method = method,
    metric = kmeans_params$metric
  )
}
