# localmap tests ---------------------------------------------------------------

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
  k = 60L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

# tests ------------------------------------------------------------------------

## general wrapper -------------------------------------------------------------

localmap_res <- localmap(
  data = cluster_data,
  .verbose = FALSE
)

localmap_res_tests <- check_cluster_separation(
  embd = localmap_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = localmap_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "localmap result correctly returned"
)

expect_true(
  current = mean(localmap_res_tests$within_dists) <
    mean(localmap_res_tests$between_dists),
  info = "localmap correctly separates clusters"
)

expect_equal(
  current = localmap_res,
  target = localmap(data = cluster_data_df, .verbose = FALSE),
  info = "localmap df is the same as localmap matrix, deterministic at a seed"
)

## over provided knn -----------------------------------------------------------

localmap_res_knn <- localmap(
  data = cluster_data,
  knn = exhaustive,
  .verbose = FALSE
)

localmap_res_tests_knn <- check_cluster_separation(
  embd = localmap_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = localmap_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "localmap result correctly returned from knn"
)

expect_true(
  current = mean(localmap_res_tests_knn$within_dists) <
    mean(localmap_res_tests_knn$between_dists),
  info = "localmap correctly separates clusters from knn"
)

## params ----------------------------------------------------------------------

expect_error(
  current = params_localmap(max_distance = 0),
  info = "localmap max_distance must be positive"
)

prep <- .prepare_localmap_params(
  knn_method = "ivf",
  nn_params = params_nn(),
  localmap_params = params_localmap(n_epochs = 300L, max_distance = 5),
  .verbose = FALSE
)

expect_equal(
  current = prep$max_distance,
  target = 5,
  info = "localmap max_distance is passed through"
)
expect_true(
  current = is.integer(prep$n_epochs),
  info = "localmap n_epochs is coerced to integer"
)
