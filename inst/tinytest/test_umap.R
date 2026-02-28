# umap tests -------------------------------------------------------------------

source("./utils_test.R")

## synthetic data --------------------------------------------------------------

zeallot::`%<-%`(
  c(cluster_data, cluster_membership),
  rs_data_clusters(
    n_samples = 1000L,
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

## umap general ----------------------------------------------------------------

### general wrapper ------------------------------------------------------------

umap_res <- umap(data = cluster_data, k = 5L, .verbose = FALSE)

umap_res_tests <- check_cluster_separation(
  umap_res = umap_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = umap_res,
    mode = "numeric",
    ncols = 2L,
    nrow = 100L
  ),
  info = "umap result correctly returned"
)

expect_true(
  current = mean(umap_res_tests$within_dists) <
    mean(umap_res_tests$between_dists),
  info = "umap correctly separates clusters"
)

umap_res_from_df <- umap(data = cluster_data_df, k = 5L, .verbose = FALSE)

expect_equal(
  current = umap_res,
  target = umap_res_from_df,
  info = "umap df is the same as umap matrix return results"
)

### over provided knn ----------------------------------------------------------

umap_res_knn <- umap(
  data = cluster_data,
  knn = exhaustive,
  k = 5L,
  .verbose = FALSE
)

### different optimisers -------------------------------------------------------

#### sgd -----------------------------------------------------------------------

umap_res_sgd <- umap(
  data = cluster_data,
  k = 5L,
  umap_params = params_umap(optimiser = "sgd"),
  .verbose = TRUE
)

umap_res_tests_sgd <- check_cluster_separation(
  umap_res = umap_res_sgd,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = umap_res_sgd,
    mode = "numeric",
    ncols = 2L,
    nrow = 100L
  ),
  info = "umap result correctly returned (sgd also working)"
)

expect_true(
  current = mean(umap_res_tests_sgd$within_dists) <
    mean(umap_res_tests_sgd$between_dists),
  info = "umap correctly separates clusters (sgd)"
)

#### adam ----------------------------------------------------------------------

umap_res_adam <- umap(
  data = cluster_data,
  k = 5L,
  umap_params = params_umap(optimiser = "adam"),
  .verbose = FALSE
)

umap_res_tests_adam <- check_cluster_separation(
  umap_res = umap_res_adam,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = umap_res_adam,
    mode = "numeric",
    ncols = 2L,
    nrow = 100L
  ),
  info = "umap result correctly returned (adam also working)"
)

expect_true(
  current = mean(umap_res_tests_adam$within_dists) <
    mean(umap_res_tests_adam$between_dists),
  info = "umap correctly separates clusters (adam)"
)

## .prepare_umap_params --------------------------------------------------------

### n_epochs resolution --------------------------------------------------------

prep_adam_parallel <- .prepare_umap_params(
  n = 5000L,
  min_dist = 0.1,
  spread = 1.0,
  nn_method = "hnsw",
  nn_params = params_nn(),
  umap_params = params_umap(optimiser = "adam_parallel"),
  .verbose = FALSE
)

expect_equal(
  current = prep_adam_parallel$n_epochs,
  target = 500L,
  info = "adam_parallel always gets n_epochs = 500"
)

prep_sgd_small <- .prepare_umap_params(
  n = 5000L,
  min_dist = 0.1,
  spread = 1.0,
  nn_method = "hnsw",
  nn_params = params_nn(),
  umap_params = params_umap(optimiser = "sgd"),
  .verbose = FALSE
)

expect_equal(
  current = prep_sgd_small$n_epochs,
  target = 500L,
  info = "sgd with n <= 10000 gets n_epochs = 500"
)

prep_sgd_large <- .prepare_umap_params(
  n = 20000L,
  min_dist = 0.1,
  spread = 1.0,
  nn_method = "hnsw",
  nn_params = params_nn(),
  umap_params = params_umap(optimiser = "sgd"),
  .verbose = FALSE
)

expect_equal(
  current = prep_sgd_large$n_epochs,
  target = 200L,
  info = "sgd with n > 10000 gets n_epochs = 200"
)

prep_user_epochs <- .prepare_umap_params(
  n = 20000L,
  min_dist = 0.1,
  spread = 1.0,
  nn_method = "hnsw",
  nn_params = params_nn(),
  umap_params = params_umap(n_epochs = 750L),
  .verbose = FALSE
)

expect_equal(
  current = prep_user_epochs$n_epochs,
  target = 750L,
  info = "user-defined n_epochs is respected"
)

expect_true(
  current = is.integer(prep_user_epochs$n_epochs),
  info = "user-defined n_epochs is coerced to integer"
)

### parameter composition ------------------------------------------------------

prep_composed <- .prepare_umap_params(
  n = 100L,
  min_dist = 0.2,
  spread = 1.5,
  nn_method = "annoy",
  nn_params = params_nn(dist_metric = "euclidean", m = 32L),
  umap_params = params_umap(lr = 0.5, init = "pca"),
  .verbose = FALSE
)

expect_equal(
  current = prep_composed$min_dist,
  target = 0.2,
  info = "min_dist is overwritten correctly in final params"
)

expect_equal(
  current = prep_composed$spread,
  target = 1.5,
  info = "spread is overwritten correctly in final params"
)

expect_equal(
  current = prep_composed$knn_method,
  target = "annoy",
  info = "nn_method is set as knn_method in final params"
)

expect_equal(
  current = prep_composed$dist_metric,
  target = "euclidean",
  info = "nn_params fields are present in final params"
)

expect_equal(
  current = prep_composed$m,
  target = 32L,
  info = "nn_params overrides are present in final params"
)

expect_equal(
  current = prep_composed$lr,
  target = 0.5,
  info = "umap_params fields are present in final params"
)

expect_equal(
  current = prep_composed$init,
  target = "pca",
  info = "umap_params overrides are present in final params"
)
