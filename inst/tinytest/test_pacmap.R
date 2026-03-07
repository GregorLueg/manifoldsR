# pacmap tests -----------------------------------------------------------------

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
  k = 10L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## pacmac general --------------------------------------------------------------

# reduced numbers because very small test data set
pacmap_test_params <- params_pacmap(
  mn_candidate_start = 3L,
  mn_candidate_end = 10L
)

### general wrapper ------------------------------------------------------------

pacmap_res <- pacmap(
  data = cluster_data,
  k = 5L,
  pacmap_params = pacmap_test_params,
  .verbose = FALSE
)

pacmap_res_tests <- check_cluster_separation(
  embd = umap_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = pacmap_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "pacmac result correctly returned"
)

expect_true(
  current = mean(pacmap_res_tests$within_dists) <
    mean(pacmap_res_tests$between_dists),
  info = "pacmap correctly separates clusters"
)

pacmap_res_from_df <- pacmap(data = cluster_data_df, k = 5L, .verbose = FALSE)

expect_equal(
  current = pacmap_res,
  target = pacmap_res_from_df,
  info = "pacmac df is the same as pacmac matrix return results"
)

### over provided knn ----------------------------------------------------------

pacmap_res_knn <- pacmap(
  data = cluster_data,
  knn = exhaustive,
  k = 5L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = pacmap_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "pacmac result correctly returned from knn"
)

expect_true(
  current = mean(pacmap_res_knn$within_dists) <
    mean(pacmap_res_knn$between_dists),
  info = "pacmac correctly separates clusters  from knn"
)

### different optimisers -------------------------------------------------------

#### adam ----------------------------------------------------------------------

## .prepare_pacmap_params ------------------------------------------------------

### integer coercion -----------------------------------------------------------

prep_user_epochs <- .prepare_pacmap_params(
  knn_method = "hnsw",
  nn_params = params_nn(),
  pacmap_params = params_pacmap(n_epochs = 300L),
  .verbose = FALSE
)

expect_equal(
  current = prep_user_epochs$n_epochs,
  target = 300L,
  info = "user-defined n_epochs is respected"
)
expect_true(
  current = is.integer(prep_user_epochs$n_epochs),
  info = "user-defined n_epochs is coerced to integer"
)

prep_null_epochs <- .prepare_pacmap_params(
  knn_method = "hnsw",
  nn_params = params_nn(),
  pacmap_params = params_pacmap(),
  .verbose = FALSE
)

expect_null(
  current = prep_null_epochs$n_epochs,
  info = "NULL n_epochs is passed through unchanged"
)

prep_phases <- .prepare_pacmap_params(
  knn_method = "hnsw",
  nn_params = params_nn(),
  pacmap_params = params_pacmap(phase1_end = 150L, phase2_end = 250L),
  .verbose = FALSE
)

expect_true(
  current = is.integer(prep_phases$phase1_end),
  info = "user-defined phase1_end is coerced to integer"
)
expect_equal(
  current = prep_phases$phase1_end,
  target = 150L,
  info = "user-defined phase1_end is respected"
)
expect_true(
  current = is.integer(prep_phases$phase2_end),
  info = "user-defined phase2_end is coerced to integer"
)
expect_equal(
  current = prep_phases$phase2_end,
  target = 250L,
  info = "user-defined phase2_end is respected"
)

prep_null_phases <- .prepare_pacmap_params(
  knn_method = "hnsw",
  nn_params = params_nn(),
  pacmap_params = params_pacmap(),
  .verbose = FALSE
)

expect_null(
  current = prep_null_phases$phase1_end,
  info = "NULL phase1_end is passed through unchanged"
)
expect_null(
  current = prep_null_phases$phase2_end,
  info = "NULL phase2_end is passed through unchanged"
)

### parameter composition ------------------------------------------------------

prep_composed <- .prepare_pacmap_params(
  knn_method = "annoy",
  nn_params = params_nn(dist_metric = "euclidean", m = 32L),
  pacmap_params = params_pacmap(lr = 0.05, init = "random", n_mid_near = 3L),
  .verbose = FALSE
)

expect_equal(
  current = prep_composed$knn_method,
  target = "annoy",
  info = "knn_method is set correctly in final params"
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
  target = 0.05,
  info = "pacmap_params fields are present in final params"
)
expect_equal(
  current = prep_composed$init,
  target = "random",
  info = "pacmap_params overrides are present in final params"
)
expect_equal(
  current = prep_composed$n_mid_near,
  target = 3L,
  info = "n_mid_near override is present in final params"
)
