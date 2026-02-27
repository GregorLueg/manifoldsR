# test utils -------------------------------------------------------------------

## cluster seperation ----------------------------------------------------------

# Helper function to check cluster separation
check_cluster_separation <- function(umap_res, cluster_membership) {
  # shift Rust 0-indexed clusters to 1-indexed
  clusters <- cluster_membership + 1
  unique_clusters <- unique(clusters)

  within_dists <- c()
  between_dists <- c()

  for (k in unique_clusters) {
    idx <- which(clusters == k)
    other_idx <- which(clusters != k)

    if (length(idx) > 1) {
      pairs <- combn(idx, 2)
      within_dists <- c(
        within_dists,
        apply(pairs, 2, function(p) {
          dist(umap_res[p, ])
        })
      )
    }

    if (length(other_idx) > 0) {
      for (i in idx) {
        between_dists <- c(
          between_dists,
          apply(as.matrix(other_idx), 1, function(j) {
            dist(umap_res[c(i, j), ])
          })
        )
      }
    }
  }

  list(within_dists = within_dists, between_dists = between_dists)
}
