# synthetic data ---------------------------------------------------------------

#' Generate synthetic data for manifold learning
#'
#' @description A unified wrapper function for generating various types of
#' synthetic data to test manifold learning techniques and demonstrate
#' differences.
#'
#' @param type Character. Type of synthetic data to generate. One of:
#' \itemize{
#'  \item `"swiss_role"` - Swiss role manifold
#'  \item `"clusters"` - Clustered data
#'  \item `"trajectory"` - A trajectory-like data with branching. You can
#'  specify your own topology via `cell_trajectories` or use one of the pre-
#'  defined ones via topology.
#' }
#' @param n_samples Integer. Number of data points to generate.
#' @param dim Integer. Dimensionality of the data (used for `"clusters"` and
#' `"trajectory"`).
#' @param n_clusters Integer. Number of clusters (used for "clusters" type).
#' Default is `15L`.
#' @param cell_trajectories Optional list. Named list to use to provide your
#' own topology for the `"trajectory"` version.
#' @param topology String. One of `c("bifurcation", "linear", "combination")`.
#' If cell trajectories is not `NULL`, this will be ignored.
#' @param noise Numeric. Amount of noise to add (used for `"swiss_role"` and
#' `"tree"`). must be any non 0 positive value. Default is `0.1`.
#' @param seed Integer. Seed for reproducibility.
#'
#' @return A list with the following elements:
#' \itemize{
#'  \item data - Numerical matrix with the generated data
#'  \item membership - Vector of cluster/branch assignments (`NULL` for
#'  swiss_role)
#' }
#'
#' @export
manifold_synthetic_data <- function(
  type = c("swiss_role", "clusters", "trajectory"),
  n_samples,
  dim = 32L,
  n_clusters = 15L,
  cell_trajectories = NULL,
  topology = c("bifurcation", "linear", "combination"),
  noise = 0.1,
  seed = 42L
) {
  type <- match.arg(type)
  topology <- match.arg(topology)

  # parameter checks
  checkmate::assertChoice(type, c("swiss_role", "clusters", "trajectory"))
  checkmate::qassert(n_samples, "I1(0,)")
  checkmate::qassert(dim, "I1(1,)")
  checkmate::qassert(n_clusters, "I1(1,)")
  if (!is.null(cell_trajectories)) {
    assertCellTrajectories(cell_trajectories)
  }
  checkmate::assertChoice(topology, c("bifurcation", "linear", "combination"))
  checkmate::qassert(noise, "N1(0,)")
  checkmate::qassert(seed, "I1(1,)")

  res <- switch(
    type,
    swiss_role = {
      data <- rs_data_swiss_role(
        n_samples = n_samples,
        noise = noise,
        seed = seed
      )
      list(data = data, membership = NULL)
    },
    clusters = {
      result <- rs_data_clusters(
        n_samples = n_samples,
        dim = dim,
        n_clusters = n_clusters,
        seed = seed
      )
      list(data = result$data, membership = as.integer(result$clusters))
    },
    trajectory = {
      result <- rs_data_trajectory(
        n_samples = n_samples,
        dim = dim,
        topology = topology,
        cell_trajectories = cell_trajectories,
        noise = noise,
        seed = seed
      )
      list(data = result$data, membership = as.integer(result$branches))
    }
  )

  return(res)
}
