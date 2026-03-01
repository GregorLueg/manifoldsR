# test utils -------------------------------------------------------------------

## cluster seperation ----------------------------------------------------------

#' Helper function to check cluster separation
#'
#' Base R is unbearable slow, so, Rust...
check_cluster_separation <- function(embd, cluster_membership) {
  rs_check_cluster_separation(
    embd = embd,
    cluster_membership = as.integer(cluster_membership)
  )
}
