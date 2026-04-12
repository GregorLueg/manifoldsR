# metrics ----------------------------------------------------------------------

## cluster metrics -------------------------------------------------------------

#' Adjusted Rand index calculation
#'
#' @description
#' Calculates the adjusted Rand index between two sets of cluster assignments.
#'
#' @param members_a Integer vector. Membership/assignment of the first
#' clustering algorithm.
#' @param members_b Integer vector. Membership/assignment of the second
#' clustering algorithm.
#'
#' @returns Adjusted Rand index
#'
#' @export
calc_ari <- function(members_a, members_b) {
  # checks
  checkmate::qassert(members_a, "I+")
  checkmate::qassert(members_b, "I+")
  checkmate::assertTRUE(length(members_a) == length(members_b))

  rs_ari(cluster_membership_a = members_a, cluster_membership_b = members_b)
}

#' Calculates the Silhouette score of a given clustering
#'
#' @description
#' If the membership has only one group, the function will return `NaN` for
#' `mean_silhouette` and `silhouette_scores`.
#'
#' @param data Numerical matrix. Samples x features. The matrix that was used
#' to generate the clustering.
#' @param membership Integer vector. Membership/assignment of the clustering
#' algorithm.
#'
#' @returns A list with the following items:
#' \itemize{
#'  \item mean_silhouette - The average Silhouette scores across all the data
#'  points.
#'  \item silhouette_scores - The individual Silhouette scores of all the data
#'  points.
#' }
#'
#' @export
calc_silhouette_score <- function(data, membership) {
  # checks
  checkmate::assertMatrix(data, mode = "numeric", nrows = length(membership))
  checkmate::qassert(membership, "I+")

  res <- rs_silhouette_score(data = data, cluster_membership = membership)

  res
}
