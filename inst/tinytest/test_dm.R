# diffusion map tests ----------------------------------------------------------

source("./utils_test.R")

n_samples <- 200L

## synthetic data --------------------------------------------------------------

# trajectory data for PHATE
zeallot::`%<-%`(
  c(trajectory_data, branch_membership),
  rs_data_trajectory(
    n_samples = n_samples,
    dim = 32L,
    cell_trajectories = NULL,
    topology = "bifurcation",
    noise = 0.1,
    seed = 42L
  )
)

trajectory_data_df <- as.data.frame(trajectory_data)

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = trajectory_data,
  k = 5L,
  knn_method = "exhaustive"
)

# tests ------------------------------------------------------------------------

## phate general ---------------------------------------------------------------

### general wrapper ------------------------------------------------------------

phate_res <- phate(data = trajectory_data, k = 5L, .verbose = FALSE)

phate_res_sep <- check_cluster_separation(
  embd = phate_res,
  cluster_membership = branch_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = phate_res,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "phate result is a numeric matrix of correct shape"
)

expect_true(
  current = !anyNA(phate_res),
  info = "phate result contains no NAs"
)

expect_true(
  current = mean(phate_res_sep$within_dists) <
    mean(phate_res_sep$between_dists),
  info = "phate correctly separates branches"
)

### topology preservation ------------------------------------------------------

topology <- check_branch_topology(
  embd = phate_res,
  membership = branch_membership,
  connected_pairs = list(c(0L, 1L), c(1L, 2L), c(1L, 3L), c(3L, 4L), c(3L, 5L))
)

expect_true(
  current = topology$preserved,
  info = "phate places connected branches closer together than unconnected ones"
)

### data frame input -----------------------------------------------------------

phate_res_from_df <- phate(data = trajectory_data_df, k = 5L, .verbose = FALSE)

expect_equal(
  current = phate_res,
  target = phate_res_from_df,
  info = "phate df input gives same result as matrix input"
)

### precomputed knn ------------------------------------------------------------

phate_res_knn <- phate(
  data = trajectory_data,
  knn = exhaustive,
  k = 5L,
  .verbose = FALSE
)

phate_res_knn_sep <- check_cluster_separation(
  embd = phate_res_knn,
  cluster_membership = branch_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = phate_res_knn,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "phate from precomputed knn returns correct shape"
)

expect_true(
  current = mean(phate_res_knn_sep$within_dists) <
    mean(phate_res_knn_sep$between_dists),
  info = "phate from precomputed knn correctly separates branches"
)

## params_phate ----------------------------------------------------------------

### landmarks ------------------------------------------------------------------

phate_res_landmarks <- phate(
  data = trajectory_data,
  k = 5L,
  phate_params = params_phate(n_landmarks = 50L),
  .verbose = FALSE
)

phate_res_landmarks_sep <- check_cluster_separation(
  embd = phate_res_landmarks,
  cluster_membership = branch_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = phate_res_landmarks,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "phate with landmarks returns correct shape"
)

expect_true(
  current = mean(phate_res_landmarks_sep$within_dists) <
    mean(phate_res_landmarks_sep$between_dists),
  info = "phate with landmarks correctly separates branches"
)

### mds methods ----------------------------------------------------------------

phate_res_classic <- phate(
  data = trajectory_data,
  k = 5L,
  phate_params = params_phate(mds_method = "classic"),
  .verbose = FALSE
)

phate_res_classic_sep <- check_cluster_separation(
  embd = phate_res_classic,
  cluster_membership = branch_membership
)

expect_true(
  current = checkmate::testMatrix(
    x = phate_res_classic,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "phate with classic MDS returns correct shape"
)

expect_true(
  current = mean(phate_res_classic_sep$within_dists) <
    mean(phate_res_classic_sep$between_dists),
  info = "phate with classic MDS correctly separates branches"
)

### fixed diffusion time -------------------------------------------------------

phate_res_fixed_t <- phate(
  data = trajectory_data,
  k = 5L,
  phate_params = params_phate(t_custom = 10L),
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = phate_res_fixed_t,
    mode = "numeric",
    ncols = 2L,
    nrow = n_samples
  ),
  info = "phate with fixed t returns correct shape"
)

### graph symmetry methods -----------------------------------------------------

symmetry_methods <- c("additive", "multiplicative", "mnn", "none")

for (method in symmetry_methods) {
  res <- phate(
    data = trajectory_data,
    k = 5L,
    phate_params = params_phate(graph_symmetry = method),
    .verbose = FALSE
  )
  expect_true(
    current = checkmate::testMatrix(
      x = res,
      mode = "numeric",
      ncols = 2L,
      nrow = n_samples
    ),
    info = sprintf(
      "phate with graph_symmetry = '%s' returns correct shape",
      method
    )
  )
}

## diffusion maps landmarks ----------------------------------------------------

dm_full <- diffusion_maps(
  data = trajectory_data,
  k = 15L,
  dm_params = params_diffusion_maps(n_landmarks = NULL),
  .verbose = FALSE
)

### full operator fallback -----------------------------------------------------

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = n_samples),
    .verbose = FALSE
  ),
  target = dm_full,
  info = "dm with n_landmarks = n falls back to the full operator"
)

expect_equal(
  current = diffusion_maps(data = trajectory_data, k = 15L, .verbose = FALSE),
  target = dm_full,
  info = "dm default landmarks above n fall back to the full operator"
)

### landmark methods -----------------------------------------------------------

branch_pairs <- list(c(0L, 1L), c(1L, 2L), c(1L, 3L), c(3L, 4L), c(3L, 5L))

for (method in c("spectral", "random", "density")) {
  landmark_params <- params_diffusion_maps(
    n_landmarks = 50L,
    landmark_method = method
  )

  res <- diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = landmark_params,
    seed = 42L,
    .verbose = FALSE
  )

  res_sep <- check_cluster_separation(
    embd = res,
    cluster_membership = branch_membership
  )

  expect_true(
    current = checkmate::testMatrix(
      x = res,
      mode = "numeric",
      any.missing = FALSE,
      ncols = 2L,
      nrow = n_samples
    ),
    info = sprintf("dm with '%s' landmarks returns correct shape", method)
  )

  expect_true(
    current = mean(res_sep$within_dists) < mean(res_sep$between_dists),
    info = sprintf("dm with '%s' landmarks separates branches", method)
  )

  expect_true(
    current = check_branch_topology(
      embd = res,
      membership = branch_membership,
      connected_pairs = branch_pairs
    )$preserved,
    info = sprintf("dm with '%s' landmarks preserves the topology", method)
  )

  expect_false(
    current = isTRUE(all.equal(res, dm_full)),
    info = sprintf("dm with '%s' landmarks differs from the full run", method)
  )

  expect_equal(
    current = diffusion_maps(
      data = trajectory_data,
      k = 15L,
      dm_params = landmark_params,
      seed = 42L,
      .verbose = FALSE
    ),
    target = res,
    info = sprintf("dm with '%s' landmarks is reproducible per seed", method)
  )

  expect_false(
    current = isTRUE(all.equal(
      diffusion_maps(
        data = trajectory_data,
        k = 15L,
        dm_params = landmark_params,
        seed = 7L,
        .verbose = FALSE
      ),
      res
    )),
    info = sprintf("dm with '%s' landmarks depends on the seed", method)
  )
}

### n_svd ----------------------------------------------------------------------

dm_spectral <- diffusion_maps(
  data = trajectory_data,
  k = 15L,
  dm_params = params_diffusion_maps(n_landmarks = 50L),
  .verbose = FALSE
)

expect_false(
  current = isTRUE(all.equal(
    diffusion_maps(
      data = trajectory_data,
      k = 15L,
      dm_params = params_diffusion_maps(n_landmarks = 50L, n_svd = 5L),
      .verbose = FALSE
    ),
    dm_spectral
  )),
  info = "dm honours n_svd with spectral landmarks"
)

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = 50L, n_svd = 100L),
    .verbose = FALSE
  ),
  target = dm_spectral,
  info = "dm n_svd = NULL takes 100 singular vectors"
)

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(
      n_landmarks = 50L,
      landmark_method = "random",
      n_svd = 5L
    ),
    .verbose = FALSE
  ),
  target = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(
      n_landmarks = 50L,
      landmark_method = "random"
    ),
    .verbose = FALSE
  ),
  info = "dm ignores n_svd with random landmarks"
)

### number of dimensions -------------------------------------------------------

expect_true(
  current = checkmate::testMatrix(
    x = diffusion_maps(
      data = trajectory_data,
      n_dim = 3L,
      k = 15L,
      dm_params = params_diffusion_maps(n_landmarks = 50L),
      .verbose = FALSE
    ),
    mode = "numeric",
    any.missing = FALSE,
    ncols = 3L,
    nrow = n_samples
  ),
  info = "dm with landmarks returns the requested number of dimensions"
)

### precomputed knn ------------------------------------------------------------

exhaustive_dm <- generate_knn_graph(
  data = trajectory_data,
  k = 15L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    knn = exhaustive_dm,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = 50L),
    .verbose = FALSE
  ),
  target = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    knn_method = "exhaustive",
    dm_params = params_diffusion_maps(n_landmarks = 50L),
    .verbose = FALSE
  ),
  info = "dm landmarks from a precomputed knn match the internal search"
)
