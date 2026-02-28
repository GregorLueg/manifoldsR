# test nearest neighbours ------------------------------------------------------

n_neighbours <- 10L
n_samples <- 1000L

## synthetic data --------------------------------------------------------------

zeallot::`%<-%`(
  c(cluster_data, cluster_membership),
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = 15L,
    seed = 42L
  )
)

## tests -----------------------------------------------------------------------

### exhaustive search and getters ----------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = n_neighbours,
  ann_method = "exhaustive"
)

expect_equal(
  current = dim(exhaustive),
  target = c(n_samples, n_neighbours),
  info = "dim primitive works and returns the right values"
)

expect_true(
  current = checkmate::testMatrix(
    get_idx_mat(exhaustive),
    mode = "integer",
    nrow = 1000L,
    ncol = 10L
  ),
  info = "get_idx_mat behaving"
)

expect_true(
  current = checkmate::testInteger(
    get_idx_flat(exhaustive),
    len = n_samples * n_neighbours
  ),
  info = "get_idx_flat behaving"
)

expect_true(
  current = checkmate::testMatrix(
    get_dist_mat(exhaustive),
    mode = "numeric",
    nrow = 1000L,
    ncol = 10L
  ),
  info = "get_dist_mat behaving"
)

expect_true(
  current = checkmate::testNumeric(
    get_dist_flat(exhaustive),
    len = n_samples * n_neighbours
  ),
  info = "get_dist_flat behaving"
)

### approximate nearest neighbour searches behaving ----------------------------

indices <- c("hnsw", "annoy", "nndescent", "balltree")

for (idx in indices) {
  idx_i <- generate_knn_graph(
    data = cluster_data,
    k = n_neighbours,
    knn_method = idx,
    .verbose = FALSE
  )

  expect_true(
    current = checkmate::testClass(idx_i, "NearestNeighbours"),
    info = sprintf("%s index object returning", idx)
  )

  recall <- sum(get_idx_flat(idx_i) == get_idx_flat(exhaustive)) /
    (n_neighbours * n_samples)

  expect_true(
    current = recall > 0.99,
    info = sprintf("%s index having sensible recall", idx)
  )
}
