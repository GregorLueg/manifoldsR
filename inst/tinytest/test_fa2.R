# forceatlas2 tests ------------------------------------------------------------

source("./utils_test.R")

n_samples <- 100L

## synthetic data --------------------------------------------------------------

zeallot::`%<-%`(
  c(cluster_data, cluster_membership),
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = 3L,
    seed = 42L
  )
)

cluster_data_df <- as.data.frame(cluster_data)

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = 5L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## forceatlas2 -----------------------------------------------------------------

### general wrapper ------------------------------------------------------------

fa2_res <- forceatlas2(data = cluster_data, k = 5L, .verbose = FALSE)

fa2_res_tests <- check_cluster_separation(
  embd = fa2_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = fa2_res,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "forceatlas2 result correctly returned"
)

expect_true(
  current = mean(fa2_res_tests$within_dists) <
    mean(fa2_res_tests$between_dists),
  info = "forceatlas2 correctly separates clusters"
)

fa2_res_from_df <- forceatlas2(data = cluster_data_df, k = 5L, .verbose = FALSE)

expect_equal(
  current = fa2_res,
  target = fa2_res_from_df,
  info = "forceatlas2 df is the same as forceatlas2 matrix return results"
)

### over provided knn ----------------------------------------------------------

fa2_res_knn <- forceatlas2(
  data = cluster_data,
  knn = exhaustive,
  k = 5L,
  .verbose = FALSE
)

fa2_res_knn_tests <- check_cluster_separation(
  embd = fa2_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = fa2_res_knn,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "forceatlas2 result correctly returned from pre-computed kNN"
)

expect_true(
  current = mean(fa2_res_knn_tests$within_dists) <
    mean(fa2_res_knn_tests$between_dists),
  info = "forceatlas2 correctly separates clusters from pre-computed kNN"
)

### fp64 -----------------------------------------------------------------------

fa2_res_fp64 <- forceatlas2(
  data = cluster_data,
  k = 5L,
  use_high_precision = TRUE,
  .verbose = FALSE
)

fa2_res_fp64_tests <- check_cluster_separation(
  embd = fa2_res_fp64,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(fa2_res_fp64_tests$within_dists) <
    mean(fa2_res_fp64_tests$between_dists),
  info = "forceatlas2 correctly separates clusters (fp64)"
)

### reproducibility ------------------------------------------------------------

fa2_res_rerun <- forceatlas2(data = cluster_data, k = 5L, .verbose = FALSE)

expect_equal(
  current = fa2_res_rerun,
  target = fa2_res,
  info = "forceatlas2 same seed gives the same layout"
)

## forceatlas2_from_graph ------------------------------------------------------

if (!requireNamespace("igraph", quietly = TRUE)) {
  exit_file("igraph not installed")
}

knn_idx <- get_idx_mat(exhaustive)

knn_graph <- igraph::simplify(
  igraph::graph_from_edgelist(
    cbind(rep(seq_len(n_samples), ncol(knn_idx)), as.vector(knn_idx)),
    directed = FALSE
  )
)

### general wrapper ------------------------------------------------------------

fa2_graph_res <- forceatlas2_from_graph(graph = knn_graph, .verbose = FALSE)

fa2_graph_res_tests <- check_cluster_separation(
  embd = fa2_graph_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = fa2_graph_res,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "forceatlas2_from_graph result correctly returned"
)

expect_true(
  current = mean(fa2_graph_res_tests$within_dists) <
    mean(fa2_graph_res_tests$between_dists),
  info = "forceatlas2_from_graph correctly separates clusters"
)

### weighted graph with init ---------------------------------------------------

set.seed(42L)
weighted_graph <- knn_graph
igraph::E(weighted_graph)$weight <- runif(igraph::ecount(knn_graph), 0.5, 1)

fa2_graph_init <- forceatlas2_from_graph(
  graph = weighted_graph,
  init = fa2_res,
  .verbose = FALSE
)

fa2_graph_init_tests <- check_cluster_separation(
  embd = fa2_graph_init,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(fa2_graph_init_tests$within_dists) <
    mean(fa2_graph_init_tests$between_dists),
  info = "forceatlas2_from_graph separates clusters (weights + init)"
)

### input errors ---------------------------------------------------------------

expect_error(
  current = forceatlas2_from_graph(
    graph = igraph::as_directed(knn_graph),
    .verbose = FALSE
  ),
  info = "forceatlas2_from_graph rejects directed graphs"
)

expect_error(
  current = forceatlas2_from_graph(
    graph = igraph::add_edges(knn_graph, c(1, 2, 1, 2)),
    .verbose = FALSE
  ),
  info = "forceatlas2_from_graph rejects multi-edges"
)

expect_error(
  current = forceatlas2_from_graph(
    graph = knn_graph,
    init = fa2_res[-1, ],
    .verbose = FALSE
  ),
  info = "forceatlas2_from_graph rejects init with the wrong dimensions"
)
