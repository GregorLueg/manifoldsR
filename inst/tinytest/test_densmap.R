# densmap tests ----------------------------------------------------------------

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

## densmap general -------------------------------------------------------------

### general wrapper ------------------------------------------------------------

densmap_res <- densmap(
  data = cluster_data,
  seed = 42L,
  .verbose = FALSE
)

densmap_res_tests <- check_cluster_separation(
  embd = densmap_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = densmap_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "densmap result correctly returned"
)

expect_true(
  current = mean(densmap_res_tests$within_dists) <
    mean(densmap_res_tests$between_dists),
  info = "densmap correctly separates clusters"
)

densmap_res_from_df <- densmap(
  data = cluster_data_df,
  seed = 42L,
  .verbose = FALSE
)

expect_equal(
  current = densmap_res,
  target = densmap_res_from_df,
  info = "densmap df is the same as densmap matrix return results"
)

### over provided knn ----------------------------------------------------------

densmap_res_knn <- densmap(
  data = cluster_data,
  knn = exhaustive,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = densmap_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "densmap from pre-computed knn correctly returned"
)

densmap_res_knn_tests <- check_cluster_separation(
  embd = densmap_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(densmap_res_knn_tests$within_dists) <
    mean(densmap_res_knn_tests$between_dists),
  info = "densmap from pre-computed knn correctly separates clusters"
)

### reproducibility ------------------------------------------------------------

expect_equal(
  current = densmap_res,
  target = densmap(data = cluster_data, seed = 42L, .verbose = FALSE),
  info = "densmap is reproducible with the same seed"
)

### zero lambda recovers umap --------------------------------------------------

expect_equal(
  current = densmap(
    data = cluster_data,
    dens_params = params_densmap(lambda = 0),
    seed = 42L,
    .verbose = FALSE
  ),
  target = umap(data = cluster_data, seed = 42L, .verbose = FALSE),
  info = "densmap with lambda = 0 recovers plain umap"
)

### density preservation -------------------------------------------------------

umap_dens <- umap(data = dens_data, seed = 42L, .verbose = FALSE)
densmap_dens <- densmap(data = dens_data, seed = 42L, .verbose = FALSE)

expect_true(
  current = density_preservation(dens_data, densmap_dens) >
    density_preservation(dens_data, umap_dens),
  info = "densmap preserves local density better than umap"
)

expect_true(
  current = density_preservation(dens_data, densmap_dens) > 0.5,
  info = "densmap local radii correlate with the original ones"
)

### optimisers -----------------------------------------------------------------

for (optimiser in c("sgd", "adam", "adam_parallel")) {
  densmap_res_optim <- densmap(
    data = cluster_data,
    umap_params = params_umap(optimiser = optimiser),
    seed = 42L,
    .verbose = FALSE
  )

  expect_true(
    current = checkmate::testMatrix(
      x = densmap_res_optim,
      mode = "numeric",
      ncols = 2L,
      nrow = n_samples
    ),
    info = sprintf("densmap result correctly returned (%s)", optimiser)
  )

  densmap_res_optim_tests <- check_cluster_separation(
    embd = densmap_res_optim,
    cluster_membership = cluster_membership
  )

  expect_true(
    current = mean(densmap_res_optim_tests$within_dists) <
      mean(densmap_res_optim_tests$between_dists),
    info = sprintf("densmap correctly separates clusters (%s)", optimiser)
  )
}

### parameter validation -------------------------------------------------------

expect_error(
  densmap(
    data = cluster_data,
    dens_params = params_densmap(lambda = -1),
    .verbose = FALSE
  ),
  info = "densmap rejects a negative lambda"
)

expect_error(
  densmap(
    data = cluster_data,
    dens_params = list(lambda = 2.0),
    .verbose = FALSE
  ),
  info = "densmap rejects incomplete density params"
)

## .prepare_densmap_params -----------------------------------------------------

### parameter composition ------------------------------------------------------

prep_composed <- .prepare_densmap_params(
  n = 1000L,
  min_dist = 0.1,
  spread = 2.0,
  knn_method = "annoy",
  nn_params = params_nn(dist_metric = "euclidean", m = 32L),
  umap_params = params_umap(optimiser = "sgd", init = "pca"),
  dens_params = params_densmap(lambda = 3.0, frac = 0.5, var_shift = 0.2),
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
  current = prep_composed$min_dist,
  target = 0.1,
  info = "min_dist is set correctly in final params"
)

expect_equal(
  current = prep_composed$optimiser,
  target = "sgd",
  info = "umap_params overrides are present in final params"
)

expect_equal(
  current = prep_composed$lambda,
  target = 3.0,
  info = "dens_params lambda is present in final params"
)

expect_equal(
  current = prep_composed$frac,
  target = 0.5,
  info = "dens_params frac is present in final params"
)

expect_equal(
  current = prep_composed$var_shift,
  target = 0.2,
  info = "dens_params var_shift is present in final params"
)

### n_epochs resolution is inherited from umap ---------------------------------

expect_equal(
  current = .prepare_densmap_params(
    n = 50000L,
    min_dist = 0.5,
    spread = 1.0,
    knn_method = "kmknn",
    nn_params = params_nn(),
    umap_params = params_umap(optimiser = "sgd"),
    dens_params = params_densmap(),
    .verbose = FALSE
  )$n_epochs,
  target = 200L,
  info = "n_epochs resolution is inherited from .prepare_umap_params"
)

expect_equal(
  current = prep_composed$n_epochs,
  target = 500L,
  info = "n_epochs defaults to 500 for the adam_parallel/small data case"
)

### defaults -------------------------------------------------------------------

expect_equal(
  current = params_densmap()$lambda,
  target = 2.0,
  info = "densmap default lambda matches the reference implementation"
)
