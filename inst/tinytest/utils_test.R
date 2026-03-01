# test utils -------------------------------------------------------------------

## cluster separation ----------------------------------------------------------

#' Helper function to check cluster separation
#'
#' Base R is unbearable slow, so, Rust...
check_cluster_separation <- function(embd, cluster_membership) {
  rs_check_cluster_separation(
    embd = embd,
    cluster_membership = as.integer(cluster_membership)
  )
}

## branch separation -----------------------------------------------------------

#' Get the branch centroids
branch_centroids <- function(embd, membership) {
  branches <- sort(unique(membership))
  lapply(branches, function(b) {
    colMeans(embd[membership == b, , drop = FALSE])
  })
}

#' Helper function to check the branch separation
check_branch_topology <- function(embd, membership, connected_pairs) {
  n_branches <- length(unique(membership))
  all_pairs <- combn(seq_len(n_branches) - 1L, 2, simplify = FALSE)

  connected_set <- lapply(connected_pairs, sort)
  unconnected_pairs <- Filter(
    function(p) !any(vapply(connected_set, identical, logical(1), sort(p))),
    all_pairs
  )

  centroids <- branch_centroids(embd, membership)

  centroid_dist <- function(i, j) {
    sqrt(sum((centroids[[i + 1L]] - centroids[[j + 1L]])^2))
  }

  connected_dists <- vapply(
    connected_pairs,
    function(p) centroid_dist(p[1], p[2]),
    numeric(1)
  )
  unconnected_dists <- vapply(
    unconnected_pairs,
    function(p) centroid_dist(p[1], p[2]),
    numeric(1)
  )

  list(
    connected_dists = connected_dists,
    unconnected_dists = unconnected_dists,
    preserved = mean(connected_dists) < mean(unconnected_dists)
  )
}
