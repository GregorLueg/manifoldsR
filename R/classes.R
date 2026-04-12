# classes ----------------------------------------------------------------------

## nearest neighbours ----------------------------------------------------------

#' Generate a new NearestNeighbours
#'
#' @param indices Integer. Nearest neigbours in flat storage format. Need to
#' be sorted!
#' @param dist Numeric. Nearest neighbour distances in flat storarge format.
#' Need to be sorted!
#' @param k Integer. Number of k-neighbours per sample.
#' @param n Integer. Number of samples.
#'
#' @returns Initialised `NearestNeighbours` class.
#'
#' @export
new_nearest_neighbour <- function(
  indices,
  dist,
  k,
  n
) {
  # checks
  checkmate::qassert(indices, "I+")
  checkmate::qassert(dist, "N+")
  checkmate::assertTRUE(length(indices) == length(dist))
  checkmate::qassert(k, "I1")
  checkmate::qassert(n, "I1")

  res <- list(
    indices = indices,
    dist = dist,
    k = k,
    n = n
  )

  class(res) <- "NearestNeighbours"

  return(res)
}

## getters ---------------------------------------------------------------------

### indices --------------------------------------------------------------------

#' Get the indices as a matrix
#'
#' @param x `NearestNeighbours` class
#'
#' @returns The indices in samples x neighbours format
#'
#' @export
get_idx_mat <- function(x) {
  UseMethod("get_idx_mat")
}

#' @rdname get_idx_mat
#'
#' @export
get_idx_mat.NearestNeighbours <- function(x) {
  # checks
  checkmate::assertClass(x, "NearestNeighbours")

  res <- matrix(data = x$indices, nrow = x$n, byrow = TRUE)

  return(res)
}

#' Get the indices as a flat vector
#'
#' @param x `NearestNeighbours` class
#'
#' @returns The indices in a flat format like
#' `c(idx1.1, idx1.2, ... , idx.2.1, idx2.2, ... idx3.1, idx3.2)`
#'
#' @export
get_idx_flat <- function(x) {
  UseMethod("get_idx_flat")
}

#' @rdname get_idx_flat
#'
#' @export
get_idx_flat.NearestNeighbours <- function(x) {
  # checks
  checkmate::assertClass(x, "NearestNeighbours")

  x$indices
}

### distances ------------------------------------------------------------------

#' Get the indices as a matrix
#'
#' @param x `NearestNeighbours` class
#'
#' @returns The indices in samples x neighbours format
#'
#' @export
get_dist_mat <- function(x) {
  UseMethod("get_dist_mat")
}

#' @rdname get_dist_mat
#'
#' @export
get_dist_mat.NearestNeighbours <- function(x) {
  # checks
  checkmate::assertClass(x, "NearestNeighbours")

  res <- matrix(data = x$dist, nrow = x$n, byrow = TRUE)

  return(res)
}

#' Get the distances as a flat vector
#'
#' @param x `NearestNeighbours` class
#'
#' @returns The distances in a flat format like
#' `c(dist1.1, dist1.2, ... , dist2.1, dist2.2, ... dist3.1, dist3.2)`
#'
#' @export
get_dist_flat <- function(x) {
  UseMethod("get_dist_flat")
}

#' @rdname get_dist_flat
#'
#' @export
get_dist_flat.NearestNeighbours <- function(x) {
  # checks
  checkmate::assertClass(x, "NearestNeighbours")

  x$dist
}

### primitives -----------------------------------------------------------------

#' Dimensions of a NearestNeighbours object
#'
#' @param x A `NearestNeighbours` object.
#'
#' @returns The dimensions of the `NearestNeigbour` matrix.
#'
#' @export
#'
#' @keywords internal
dim.NearestNeighbours <- function(x) {
  c(x$n, x$k)
}

#' Print a NearestNeighbours object
#'
#' @param x A `NearestNeighbours` object.
#' @param ... Further arguments passed to or from other methods.
#'
#' @returns Invisibly returns `x`.
#'
#' @export
#'
#' @keywords internal
print.NearestNeighbours <- function(x, ...) {
  cat("NearestNeighbours\n")
  cat("  n_samples:   ", x$n, "\n")
  cat("  k_neighbours:", x$k, "\n")
  invisible(x)
}

## evoc ------------------------------------------------------------------------

### class ----------------------------------------------------------------------

#' Construct an Evoc object
#'
#' @param cluster_layers List of integer vectors.
#' @param membership_strengths List of numeric vectors.
#' @param persistence_scores Numeric vector.
#' @param knn Optional `NearestNeighbours` object or NULL.
#'
#' @returns An `Evoc` S3 object.
#'
#' @keywords internal
new_evoc <- function(
  cluster_layers,
  membership_strengths,
  persistence_scores,
  knn
) {
  structure(
    list(
      cluster_layers = cluster_layers,
      membership_strengths = membership_strengths,
      persistence_scores = persistence_scores,
      knn = knn
    ),
    class = "Evoc"
  )
}

### getters --------------------------------------------------------------------

#' Get the cluster membership at the best persistence score
#'
#' @param x An `Evoc` object.
#'
#' @returns A named list with elements `labels` (integer vector of cluster
#' assignments, `-1` for noise), `membership` (numeric vector of strengths),
#' `layer` (which layer index was selected), and `persistence` (the score).
#'
#' @export
best_membership <- function(x) {
  UseMethod("best_membership")
}

#' @rdname best_membership
#' @export
best_membership.Evoc <- function(x) {
  idx <- which.max(x$persistence_scores)
  list(
    labels = x$cluster_layers[[idx]],
    membership = x$membership_strengths[[idx]],
    layer = idx,
    persistence = x$persistence_scores[idx]
  )
}

#' Get a specific EVoC layer
#'
#' @param x An `Evoc` object.
#' @param i Integer. Layer index to retrieve.
#'
#' @returns A named list with `labels`, `membership`, and `persistence` for
#' the requested layer.
#'
#' @export
get_layer <- function(x, i) {
  UseMethod("get_layer")
}

#' @rdname get_layer
#' @export
get_layer.Evoc <- function(x, i) {
  checkmate::qassert(i, "I1")
  n <- length(x$cluster_layers)
  if (i < 1L || i > n) {
    stop("Layer index out of range. Available layers: 1 to ", n, call. = FALSE)
  }
  list(
    labels = x$cluster_layers[[i]],
    membership = x$membership_strengths[[i]],
    persistence = x$persistence_scores[i]
  )
}

#' Get the kNN graph from an Evoc object
#'
#' @param x An `Evoc` object.
#'
#' @returns A `NearestNeighbours` object, or `NULL` if the kNN was not stored.
#'
#' @export
get_nearest_neighbours <- function(x) {
  UseMethod("get_nearest_neighbours")
}

#' @rdname get_nearest_neighbours
#' @export
get_nearest_neighbours.Evoc <- function(x) {
  if (is.null(x$knn)) {
    warning("kNN graph was not stored. Re-run evoc() with return_knn = TRUE.")
  }
  x$knn
}

### primitives -----------------------------------------------------------------

#' Print an Evoc object
#'
#' @param x An `Evoc` object.
#' @param ... Further arguments (ignored).
#'
#' @returns Invisibly returns `x`.
#'
#' @export
print.Evoc <- function(x, ...) {
  n_layers <- length(x$cluster_layers)
  best <- which.max(x$persistence_scores)
  cat("Evoc\n")
  cat("  layers:              ", n_layers, "\n")
  cat("  best layer:          ", best, "\n")
  cat("  best persistence:    ", round(x$persistence_scores[best], 4), "\n")
  cat(
    "  knn:                 ",
    if (is.null(x$knn)) "not stored" else "stored",
    "\n"
  )
  invisible(x)
}

## k means ---------------------------------------------------------------------

### class ----------------------------------------------------------------------

#' Construct a KMeansCluster object
#'
#' @param centroids Numeric matrix of shape k x features.
#' @param assignments Integer vector of length samples (1-indexed).
#' @param k Integer. Number of clusters.
#' @param method Character. Either `"full"` or `"minibatch"`.
#' @param metric Character. Distance metric used.
#'
#' @returns A `KMeansCluster` S3 object.
#'
#' @keywords internal
new_kmeans_cluster <- function(centroids, assignments, k, method, metric) {
  structure(
    list(
      centroids = centroids,
      assignments = assignments,
      k = k,
      method = method,
      metric = metric
    ),
    class = "KMeansCluster"
  )
}

### getters --------------------------------------------------------------------

#' Get cluster assignments
#'
#' @param x A `KMeansCluster` object.
#'
#' @returns Integer vector of length samples with cluster assignments
#'   (1-indexed).
#'
#' @export
membership <- function(x) {
  UseMethod("membership")
}

#' @rdname membership
#' @export
membership.KMeansCluster <- function(x) {
  x$assignments
}

#' Get cluster centroids
#'
#' @param x A `KMeansCluster` object.
#'
#' @returns Numeric matrix of shape k x features.
#'
#' @export
get_centroids <- function(x) {
  UseMethod("get_centroids")
}

#' @rdname get_centroids
#'
#' @export
get_centroids.KMeansCluster <- function(x) {
  # checks
  checkmate::assertClass(x, "KMeansCluster")

  x$centroids
}

### metrics --------------------------------------------------------------------

#' Calculate the cluster inertia
#'
#' @param x `KMeansCluster` class.
#' @param data Numerical matrix. The original data used to generate the k-means
#' clusters. Shape of samples x features
#'
#' @returns The cluster inertia
#'
#' @export
calc_inertia <- function(x, data) {
  UseMethod("calc_inertia")
}

#' @rdname calc_inertia
#'
#' @export
calc_inertia.KMeansCluster <- function(x, data) {
  # checks
  checkmate::assertClass(x, "KMeansCluster")
  checkmate::assertMatrix(data, mode = "numeric")

  rs_intertia(
    data = data,
    centroids = x$centroids,
    cluster_membership = x$assignments
  )
}

### primitives -----------------------------------------------------------------

#' Print a KMeansCluster object
#'
#' @param x A `KMeansCluster` object.
#' @param ... Further arguments (ignored).
#'
#' @returns Invisibly returns `x`.
#'
#' @export
print.KMeansCluster <- function(x, ...) {
  n <- length(x$assignments)
  sizes <- tabulate(x$assignments, nbins = x$k)
  cat("KMeansCluster\n")
  cat("  method:    ", x$method, "\n")
  cat("  metric:    ", x$metric, "\n")
  cat("  k:         ", x$k, "\n")
  cat("  n:         ", n, "\n")
  cat(
    "  sizes:      min=",
    min(sizes),
    " median=",
    median(sizes),
    " max=",
    max(sizes),
    "\n"
  )
  invisible(x)
}
