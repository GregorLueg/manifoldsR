# densne tests -----------------------------------------------------------------

source("./utils_test.R")

n_samples <- 100L
n_samples_dens <- 500L

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

# larger set for the density checks - the correlation is noise at n = 100
zeallot::`%<-%`(
  c(dens_data, dens_membership),
  rs_data_clusters(
    n_samples = n_samples_dens,
    dim = 32L,
    n_clusters = 5L,
    seed = 42L
  )
)

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = 15L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## densne general --------------------------------------------------------------

### general wrapper ------------------------------------------------------------

densne_res <- densne(
  data = cluster_data,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

densne_res_tests <- check_cluster_separation(
  embd = densne_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = densne_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "densne result correctly returned"
)

expect_true(
  current = mean(densne_res_tests$within_dists) <
    mean(densne_res_tests$between_dists),
  info = "densne correctly separates clusters"
)

densne_res_from_df <- densne(
  data = cluster_data_df,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_equal(
  current = densne_res,
  target = densne_res_from_df,
  info = "densne df is the same as densne matrix return results"
)

### over provided knn ----------------------------------------------------------

densne_res_knn <- densne(
  data = cluster_data,
  knn = exhaustive,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = densne_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "densne from pre-computed knn correctly returned"
)

densne_res_knn_tests <- check_cluster_separation(
  embd = densne_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(densne_res_knn_tests$within_dists) <
    mean(densne_res_knn_tests$between_dists),
  info = "densne from pre-computed knn correctly separates clusters"
)

### reproducibility ------------------------------------------------------------

expect_equal(
  current = densne_res,
  target = densne(
    data = cluster_data,
    perplexity = 10,
    seed = 42L,
    .verbose = FALSE
  ),
  info = "densne is reproducible with the same seed"
)

### zero lambda recovers tsne --------------------------------------------------

expect_equal(
  current = densne(
    data = cluster_data,
    perplexity = 10,
    dens_params = params_densne(lambda = 0),
    seed = 42L,
    .verbose = FALSE
  ),
  target = tsne(
    data = cluster_data,
    perplexity = 10,
    seed = 42L,
    .verbose = FALSE
  ),
  info = "densne with lambda = 0 recovers plain tsne"
)

### density preservation -------------------------------------------------------

tsne_dens <- tsne(
  data = dens_data,
  perplexity = 20,
  seed = 42L,
  .verbose = FALSE
)
densne_dens <- densne(
  data = dens_data,
  perplexity = 20,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = density_preservation(dens_data, densne_dens) >
    density_preservation(dens_data, tsne_dens),
  info = "densne preserves local density better than tsne"
)

expect_true(
  current = density_preservation(dens_data, densne_dens) > 0.5,
  info = "densne local radii correlate with the original ones"
)

### bh approximation -----------------------------------------------------------

densne_res_bh <- densne(
  data = cluster_data,
  perplexity = 10,
  approx_type = "bh",
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = densne_res_bh,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "densne bh approximation correctly returned"
)

densne_res_bh_tests <- check_cluster_separation(
  embd = densne_res_bh,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(densne_res_bh_tests$within_dists) <
    mean(densne_res_bh_tests$between_dists),
  info = "densne bh approximation correctly separates clusters"
)

### fft approximation ----------------------------------------------------------

if (.Platform$OS.type == "unix") {
  densne_res_fft <- densne(
    data = cluster_data,
    perplexity = 10,
    approx_type = "fft",
    seed = 42L,
    .verbose = FALSE
  )

  expect_true(
    current = checkmate::testMatrix(
      x = densne_res_fft,
      mode = "numeric",
      ncols = 2L,
      nrow = n_samples
    ),
    info = "densne fft approximation correctly returned"
  )

  densne_res_fft_tests <- check_cluster_separation(
    embd = densne_res_fft,
    cluster_membership = cluster_membership
  )

  expect_true(
    current = mean(densne_res_fft_tests$within_dists) <
      mean(densne_res_fft_tests$between_dists),
    info = "densne fft approximation correctly separates clusters"
  )
}

### fft error on non-unix ------------------------------------------------------

if (.Platform$OS.type != "unix") {
  expect_error(
    densne(
      data = cluster_data,
      perplexity = 10,
      approx_type = "fft",
      .verbose = FALSE
    ),
    info = "densne fft correctly errors on non-unix systems"
  )
}

### parameter validation -------------------------------------------------------

expect_error(
  densne(
    data = cluster_data,
    perplexity = 10,
    dens_params = params_densne(frac = 1.5),
    .verbose = FALSE
  ),
  info = "densne rejects a frac outside of [0, 1]"
)

expect_error(
  densne(
    data = cluster_data,
    perplexity = 10,
    dens_params = list(lambda = 0.1),
    .verbose = FALSE
  ),
  info = "densne rejects incomplete density params"
)

## .prepare_densne_params ------------------------------------------------------

### parameter composition ------------------------------------------------------

prep_composed <- .prepare_densne_params(
  knn_method = "annoy",
  nn_params = params_nn(dist_metric = "euclidean", m = 32L),
  tsne_params = params_tsne(lr = 100.0, init = "pca"),
  dens_params = params_densne(lambda = 0.5, frac = 0.4, var_shift = 0.3)
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

expect_equal(
  current = prep_composed$lambda,
  target = 0.5,
  info = "dens_params lambda is present in final params"
)

expect_equal(
  current = prep_composed$frac,
  target = 0.4,
  info = "dens_params frac is present in final params"
)

expect_equal(
  current = prep_composed$var_shift,
  target = 0.3,
  info = "dens_params var_shift is present in final params"
)

### defaults -------------------------------------------------------------------

expect_equal(
  current = params_densne()$lambda,
  target = 0.1,
  info = "densne default lambda matches the reference implementation"
)
