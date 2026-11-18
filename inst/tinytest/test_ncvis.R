# ncvis tests ------------------------------------------------------------------

# NCVis runs Hogwild! SGD, so runs are not compared coordinate by coordinate.

source("./utils_test.R")

n_samples <- 300L

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

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = 15L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

# tests ------------------------------------------------------------------------

## general wrapper -------------------------------------------------------------

ncvis_res <- ncvis(
  data = cluster_data,
  .verbose = FALSE
)

ncvis_res_tests <- check_cluster_separation(
  embd = ncvis_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = ncvis_res,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "ncvis result correctly returned"
)

expect_true(
  current = mean(ncvis_res_tests$within_dists) <
    mean(ncvis_res_tests$between_dists),
  info = "ncvis correctly separates clusters"
)

## over provided knn -----------------------------------------------------------

ncvis_res_knn <- ncvis(
  data = cluster_data,
  knn = exhaustive,
  .verbose = FALSE
)

ncvis_res_tests_knn <- check_cluster_separation(
  embd = ncvis_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = ncvis_res_knn,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "ncvis result correctly returned from knn"
)

expect_true(
  current = mean(ncvis_res_tests_knn$within_dists) <
    mean(ncvis_res_tests_knn$between_dists),
  info = "ncvis correctly separates clusters from knn"
)

## random initialisation -------------------------------------------------------

ncvis_res_random <- ncvis(
  data = cluster_data,
  ncvis_params = params_ncvis(init = "random"),
  .verbose = FALSE
)

ncvis_res_tests_random <- check_cluster_separation(
  embd = ncvis_res_random,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(ncvis_res_tests_random$within_dists) <
    mean(ncvis_res_tests_random$between_dists),
  info = "ncvis with random init separates clusters"
)

## params ----------------------------------------------------------------------

expect_error(
  current = params_ncvis(n_negative = 0.5),
  info = "ncvis n_negative must be at least 1"
)
