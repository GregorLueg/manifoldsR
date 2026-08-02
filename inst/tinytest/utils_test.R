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

## local density ---------------------------------------------------------------

#' Get the log local radius per point
#'
#' densMAP and den-SNE preserve a graph-weighted local radius. The mean squared
#' kNN distance is the R-side proxy for it, and it stays finite when the kNN
#' graph includes the point itself at distance zero.
local_radii <- function(x, k = 15L) {
  knn <- if (inherits(x, "NearestNeighbours")) {
    x
  } else {
    generate_knn_graph(
      data = x,
      k = k,
      knn_method = "exhaustive",
      .verbose = FALSE
    )
  }
  log(rowMeans(get_dist_mat(knn)^2) + 1e-8)
}

#' Spearman correlation of the local radii before and after embedding
density_preservation <- function(data, embd, k = 15L) {
  stats::cor(
    local_radii(data, k = k),
    local_radii(embd, k = k),
    method = "spearman"
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
