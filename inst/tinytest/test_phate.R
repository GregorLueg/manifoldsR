# phate tests ------------------------------------------------------------------

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
