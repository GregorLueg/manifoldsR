# tsne tests -------------------------------------------------------------------

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
  k = 15L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## tsne general ----------------------------------------------------------------

### general wrapper ------------------------------------------------------------

tsne_res <- tsne(
  data = cluster_data,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

tsne_res_tests <- check_cluster_separation(
  embd = tsne_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = tsne_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "tsne result correctly returned"
)

expect_true(
  current = mean(tsne_res_tests$within_dists) <
    mean(tsne_res_tests$between_dists),
  info = "tsne correctly separates clusters"
)

tsne_res_from_df <- tsne(
  data = cluster_data_df,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_equal(
  current = tsne_res,
  target = tsne_res_from_df,
  info = "tsne df is the same as tsne matrix return results"
)

### over provided knn ----------------------------------------------------------

tsne_res_knn <- tsne(
  data = cluster_data,
  knn = exhaustive,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = tsne_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "tsne from pre-computed knn correctly returned"
)

tsne_res_knn_tests <- check_cluster_separation(
  embd = tsne_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(tsne_res_knn_tests$within_dists) <
    mean(tsne_res_knn_tests$between_dists),
  info = "tsne from pre-computed knn correctly separates clusters"
)

### bh approximation -----------------------------------------------------------

tsne_res_bh <- tsne(
  data = cluster_data,
  perplexity = 10,
  approx_type = "bh",
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = tsne_res_bh,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "tsne bh approximation correctly returned"
)

tsne_res_bh_tests <- check_cluster_separation(
  embd = tsne_res_bh,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(tsne_res_bh_tests$within_dists) <
    mean(tsne_res_bh_tests$between_dists),
  info = "tsne bh approximation correctly separates clusters"
)

### bh_qd approximation --------------------------------------------------------

tsne_res_bh_qd <- tsne(
  data = cluster_data,
  perplexity = 10,
  approx_type = "bh_qd",
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = tsne_res_bh_qd,
    mode = "numeric",
    any.missing = FALSE,
    ncols = 2L,
    nrow = n_samples
  ),
  info = "tsne bh_qd approximation correctly returned"
)

tsne_res_bh_qd_tests <- check_cluster_separation(
  embd = tsne_res_bh_qd,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(tsne_res_bh_qd_tests$within_dists) <
    mean(tsne_res_bh_qd_tests$between_dists),
  info = "tsne bh_qd approximation correctly separates clusters"
)

tsne_res_bh_qd_knn <- tsne(
  data = cluster_data,
  knn = exhaustive,
  perplexity = 10,
  approx_type = "bh_qd",
  tsne_params = params_tsne(max_depth = 5L),
  seed = 42L,
  .verbose = FALSE
)

tsne_res_bh_qd_knn_tests <- check_cluster_separation(
  embd = tsne_res_bh_qd_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(tsne_res_bh_qd_knn_tests$within_dists) <
    mean(tsne_res_bh_qd_knn_tests$between_dists),
  info = "tsne bh_qd with max_depth = 5 from pre-computed knn separates clusters"
)

expect_equal(
  current = tsne(
    data = cluster_data,
    perplexity = 10,
    approx_type = "bh_qd",
    seed = 42L,
    .verbose = FALSE
  ),
  target = tsne_res_bh_qd,
  info = "tsne bh_qd is deterministic for a fixed seed"
)

### fft approximation ----------------------------------------------------------

if (.Platform$OS.type == "unix") {
  tsne_res_fft <- tsne(
    data = cluster_data,
    perplexity = 10,
    approx_type = "fft",
    seed = 42L,
    .verbose = FALSE
  )

  expect_true(
    current = checkmate::testMatrix(
      x = tsne_res_fft,
      mode = "numeric",
      ncols = 2L,
      nrow = n_samples
    ),
    info = "tsne fft approximation correctly returned"
  )

  tsne_res_fft_tests <- check_cluster_separation(
    embd = tsne_res_fft,
    cluster_membership = cluster_membership
  )

  expect_true(
    current = mean(tsne_res_fft_tests$within_dists) <
      mean(tsne_res_fft_tests$between_dists),
    info = "tsne fft approximation correctly separates clusters"
  )
}

### fft_3k approximation -------------------------------------------------------

if (.Platform$OS.type == "unix") {
  tsne_res_fft_3k <- tsne(
    data = cluster_data,
    perplexity = 10,
    approx_type = "fft_3k",
    seed = 42L,
    .verbose = FALSE
  )

  expect_true(
    current = checkmate::testMatrix(
      x = tsne_res_fft_3k,
      mode = "numeric",
      any.missing = FALSE,
      ncols = 2L,
      nrow = n_samples
    ),
    info = "tsne fft_3k approximation correctly returned"
  )

  tsne_res_fft_3k_tests <- check_cluster_separation(
    embd = tsne_res_fft_3k,
    cluster_membership = cluster_membership
  )

  expect_true(
    current = mean(tsne_res_fft_3k_tests$within_dists) <
      mean(tsne_res_fft_3k_tests$between_dists),
    info = "tsne fft_3k approximation correctly separates clusters"
  )

  tsne_res_fft_3k_knn <- tsne(
    data = cluster_data,
    knn = exhaustive,
    perplexity = 10,
    approx_type = "fft_3k",
    seed = 42L,
    .verbose = FALSE
  )

  tsne_res_fft_3k_knn_tests <- check_cluster_separation(
    embd = tsne_res_fft_3k_knn,
    cluster_membership = cluster_membership
  )

  expect_true(
    current = mean(tsne_res_fft_3k_knn_tests$within_dists) <
      mean(tsne_res_fft_3k_knn_tests$between_dists),
    info = "tsne fft_3k from pre-computed knn correctly separates clusters"
  )

  expect_equal(
    current = tsne(
      data = cluster_data,
      perplexity = 10,
      approx_type = "fft_3k",
      seed = 42L,
      .verbose = FALSE
    ),
    target = tsne_res_fft_3k,
    info = "tsne fft_3k is deterministic for a fixed seed"
  )
}

### fft error on non-unix ------------------------------------------------------

if (.Platform$OS.type != "unix") {
  expect_error(
    tsne(
      data = cluster_data,
      perplexity = 10,
      approx_type = "fft",
      .verbose = FALSE
    ),
    info = "tsne fft correctly errors on non-unix systems"
  )
  expect_error(
    tsne(
      data = cluster_data,
      perplexity = 10,
      approx_type = "fft_3k",
      .verbose = FALSE
    ),
    info = "tsne fft_3k correctly errors on non-unix systems"
  )
}

## .prepare_tsne_params --------------------------------------------------------

### parameter composition ------------------------------------------------------

prep_composed <- .prepare_tsne_params(
  knn_method = "annoy",
  nn_params = params_nn(dist_metric = "euclidean", m = 32L),
  tsne_params = params_tsne(lr = 100.0, init = "pca")
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
  target = 100.0,
  info = "tsne_params fields are present in final params"
)

expect_equal(
  current = prep_composed$init,
  target = "pca",
  info = "tsne_params overrides are present in final params"
)

expect_equal(
  current = prep_composed$n_epochs,
  target = 1000L,
  info = "tsne_params default n_epochs is present in final params"
)

expect_true(
  current = is.integer(prep_composed$n_epochs),
  info = "n_epochs is integer in final params"
)

### all tsne_params fields present ---------------------------------------------

prep_full <- .prepare_tsne_params(
  knn_method = "hnsw",
  nn_params = params_nn(),
  tsne_params = params_tsne(
    lr = 50.0,
    n_epochs = 500L,
    early_exag_iter = 100L,
    early_exag_factor = 6.0,
    theta = 0.3,
    n_interp_points = 5L,
    max_depth = 9L,
    init = "random",
    randomised = FALSE
  )
)

expect_equal(
  current = prep_full$lr,
  target = 50.0,
  info = "lr override present"
)
expect_equal(
  current = prep_full$n_epochs,
  target = 500L,
  info = "n_epochs override present"
)
expect_equal(
  current = prep_full$early_exag_iter,
  target = 100L,
  info = "early_exag_iter override present"
)
expect_equal(
  current = prep_full$early_exag_factor,
  target = 6.0,
  info = "early_exag_factor override present"
)
expect_equal(
  current = prep_full$theta,
  target = 0.3,
  info = "theta override present"
)
expect_equal(
  current = prep_full$n_interp_points,
  target = 5L,
  info = "n_interp_points override present"
)
expect_equal(
  current = prep_full$max_depth,
  target = 9L,
  info = "max_depth override present"
)
expect_equal(
  current = prep_full$init,
  target = "random",
  info = "init override present"
)
expect_equal(
  current = prep_full$randomised,
  target = FALSE,
  info = "randomised override present"
)
