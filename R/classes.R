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
generate_nearest_neigbours_class <- function(
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
