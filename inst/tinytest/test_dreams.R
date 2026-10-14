# dreams tests -----------------------------------------------------------------

source("./utils_test.R")

n_samples <- 100L
n_samples_global <- 600L

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

# subclusters within supergroups - the global layout is what DREAMS keeps
hierarchical_data <- rs_data_hierarchical(
  n_samples = n_samples_global,
  dim = 32L,
  n_supergroups = 4L,
  n_subclusts = 3L,
  supergroup_spread = 15.0,
  subcluster_spread = 2.0,
  point_std = 0.4,
  seed = 42L
)

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = 15L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## dreams general --------------------------------------------------------------

### general wrapper ------------------------------------------------------------

dreams_res <- dreams(
  data = cluster_data,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

dreams_res_tests <- check_cluster_separation(
  embd = dreams_res,
  cluster_membership = cluster_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = dreams_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "dreams result correctly returned"
)

expect_true(
  current = mean(dreams_res_tests$within_dists) <
    mean(dreams_res_tests$between_dists),
  info = "dreams correctly separates clusters"
)

dreams_res_from_df <- dreams(
  data = cluster_data_df,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_equal(
  current = dreams_res,
  target = dreams_res_from_df,
  info = "dreams df is the same as dreams matrix return results"
)

### over provided knn ----------------------------------------------------------

dreams_res_knn <- dreams(
  data = cluster_data,
  knn = exhaustive,
  perplexity = 10,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = dreams_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "dreams from pre-computed knn correctly returned"
)

dreams_res_knn_tests <- check_cluster_separation(
  embd = dreams_res_knn,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(dreams_res_knn_tests$within_dists) <
    mean(dreams_res_knn_tests$between_dists),
  info = "dreams from pre-computed knn correctly separates clusters"
)

### reproducibility ------------------------------------------------------------

expect_equal(
  current = dreams_res,
  target = dreams(
    data = cluster_data,
    perplexity = 10,
    seed = 42L,
    .verbose = FALSE
  ),
  info = "dreams is reproducible with the same seed"
)

### high precision -------------------------------------------------------------

dreams_res_fp64 <- dreams(
  data = cluster_data,
  perplexity = 10,
  seed = 42L,
  use_high_precision = TRUE,
  .verbose = FALSE
)

dreams_res_fp64_tests <- check_cluster_separation(
  embd = dreams_res_fp64,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(dreams_res_fp64_tests$within_dists) <
    mean(dreams_res_fp64_tests$between_dists),
  info = "dreams fp64 path correctly separates clusters"
)

### fft approximation ----------------------------------------------------------

dreams_res_fft <- dreams(
  data = cluster_data,
  perplexity = 10,
  approx_type = "fft_3k",
  seed = 42L,
  .verbose = FALSE
)

dreams_res_fft_tests <- check_cluster_separation(
  embd = dreams_res_fft,
  cluster_membership = cluster_membership
)

expect_true(
  current = mean(dreams_res_fft_tests$within_dists) <
    mean(dreams_res_fft_tests$between_dists),
  info = "dreams fft_3k approximation correctly separates clusters"
)

## global structure ------------------------------------------------------------

pca_global <- stats::prcomp(hierarchical_data$data, rank. = 2)$x

tsne_global <- tsne(
  data = hierarchical_data$data,
  perplexity = 20,
  seed = 42L,
  .verbose = FALSE
)
dreams_global <- dreams(
  data = hierarchical_data$data,
  perplexity = 20,
  seed = 42L,
  .verbose = FALSE
)

# measured: tsne 0.52 - 0.63, dreams 0.88 - 0.96 over three data seeds
expect_true(
  current = global_preservation(
    hierarchical_data$data,
    dreams_global,
    hierarchical_data$subgroup
  ) >
    global_preservation(
      hierarchical_data$data,
      tsne_global,
      hierarchical_data$subgroup
    ) +
      0.2,
  info = "dreams preserves the subcluster layout better than tsne"
)

### lambda = 1 recovers the reference ------------------------------------------

dreams_lambda_one <- dreams(
  data = hierarchical_data$data,
  perplexity = 20,
  dreams_params = params_dreams(lambda = 1),
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = stats::cor(
    as.vector(stats::dist(pca_global)),
    as.vector(stats::dist(dreams_lambda_one))
  ) >
    0.99,
  info = "dreams with lambda = 1 recovers the PCA layout"
)

expect_equal(
  current = dreams(
    data = hierarchical_data$data,
    perplexity = 20,
    dreams_params = params_dreams(lambda = 1L),
    seed = 42L,
    .verbose = FALSE
  ),
  target = dreams_lambda_one,
  info = "dreams treats an integer lambda like a double"
)

### custom reference -----------------------------------------------------------

# the first two raw features: a layout distinct from PCA
custom_reference <- hierarchical_data$data[, 1:2]

dreams_custom <- dreams(
  data = hierarchical_data$data,
  reference = custom_reference,
  perplexity = 20,
  dreams_params = params_dreams(lambda = 1),
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = stats::cor(
    as.vector(stats::dist(custom_reference)),
    as.vector(stats::dist(dreams_custom))
  ) >
    0.99,
  info = "dreams with lambda = 1 recovers a supplied reference"
)

## errors ----------------------------------------------------------------------

expect_error(
  current = params_dreams(lambda = 1.5),
  info = "dreams lambda outside [0, 1] errors"
)

expect_error(
  current = dreams(
    data = cluster_data,
    reference = matrix(0, nrow = n_samples - 1L, ncol = 2L),
    .verbose = FALSE
  ),
  info = "dreams reference with the wrong number of rows errors"
)

expect_error(
  current = dreams(
    data = cluster_data,
    reference = matrix(0, nrow = n_samples, ncol = 3L),
    .verbose = FALSE
  ),
  info = "dreams reference with the wrong number of columns errors"
)
