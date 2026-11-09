# diffusion map tests ----------------------------------------------------------

source("./utils_test.R")

n_samples <- 200L

## helpers ---------------------------------------------------------------------

#' Check for a finite embedding of the right shape. testMatrix() lets Inf pass.
is_embedding <- function(x, n_dim = 2L) {
  checkmate::testMatrix(
    x = x,
    mode = "numeric",
    any.missing = FALSE,
    ncols = n_dim,
    nrow = n_samples
  ) &&
    all(is.finite(x))
}

#' Dense diffusion map in base R, as the reference for the full operator
#'
#' `width` neighbours join the kernel, the `k`-th sets the bandwidth. Only for
#' symmetric kernels, as the eigenvectors would not be orthogonal otherwise.
dm_reference <- function(
  x,
  k,
  t,
  n_dim = 2L,
  width = k,
  bandwidth_scale = 1,
  thresh = 1e-4,
  alpha_norm = 1,
  symmetry = "additive"
) {
  dists <- as.matrix(stats::dist(x))
  n <- nrow(dists)

  kernel <- matrix(0, n, n)
  for (i in seq_len(n)) {
    neighbours <- order(dists[i, ])
    neighbours <- neighbours[neighbours != i][seq_len(width)]
    sigma <- dists[i, neighbours[k]] * bandwidth_scale
    affinity <- exp(-(dists[i, neighbours] / sigma)^2)
    keep <- affinity >= thresh
    kernel[i, neighbours[keep]] <- affinity[keep]
  }

  kernel <- switch(
    symmetry,
    additive = (kernel + t(kernel)) / 2,
    multiplicative = kernel * t(kernel),
    mnn = pmin(kernel, t(kernel))
  )

  q_alpha <- rowSums(kernel)^alpha_norm
  kernel <- kernel / outer(q_alpha, q_alpha)

  sqrt_degrees <- sqrt(rowSums(kernel))
  eig <- eigen(kernel / outer(sqrt_degrees, sqrt_degrees), symmetric = TRUE)

  # the first eigenvector is the trivial one
  vapply(
    seq_len(n_dim) + 1L,
    \(j) {
      u <- eig$vectors[, j]
      eig$values[j]^t * u * sign(u[which.max(abs(u))]) / sqrt_degrees
    },
    numeric(n)
  )
}

## synthetic data --------------------------------------------------------------

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

branch_pairs <- list(c(0L, 1L), c(1L, 2L), c(1L, 3L), c(3L, 4L), c(3L, 5L))

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = trajectory_data,
  k = 15L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

# tests ------------------------------------------------------------------------

## general wrapper -------------------------------------------------------------

dm_full <- diffusion_maps(
  data = trajectory_data,
  k = 15L,
  dm_params = params_diffusion_maps(n_landmarks = NULL),
  .verbose = FALSE
)

dm_full_sep <- check_cluster_separation(
  embd = dm_full,
  cluster_membership = branch_membership
)

expect_true(
  current = is_embedding(dm_full),
  info = "dm result is a finite numeric matrix of correct shape"
)

expect_true(
  current = mean(dm_full_sep$within_dists) < mean(dm_full_sep$between_dists),
  info = "dm correctly separates branches"
)

expect_true(
  current = check_branch_topology(
    embd = dm_full,
    membership = branch_membership,
    connected_pairs = branch_pairs
  )$preserved,
  info = "dm places connected branches closer together than unconnected ones"
)

expect_equal(
  current = diffusion_maps(
    data = trajectory_data_df,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = NULL),
    .verbose = FALSE
  ),
  target = dm_full,
  info = "dm df input gives same result as matrix input"
)

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = NULL),
    .verbose = FALSE
  ),
  target = dm_full,
  info = "dm is reproducible per seed"
)

## dense reference -------------------------------------------------------------

# f32 in Rust against f64 here
reference_tolerance <- 1e-3

dm_exact <- function(
  k = 15L,
  t_custom = 5L,
  n_dim = 2L,
  knn = exhaustive,
  ...
) {
  diffusion_maps(
    data = trajectory_data,
    knn = knn,
    n_dim = n_dim,
    k = k,
    dm_params = params_diffusion_maps(
      n_landmarks = NULL,
      t_custom = t_custom,
      ...
    ),
    .verbose = FALSE
  )
}

### diffusion time -------------------------------------------------------------

for (t_custom in c(1L, 5L, 20L)) {
  expect_equal(
    current = dm_exact(t_custom = t_custom),
    target = dm_reference(trajectory_data, k = 15L, t = t_custom),
    tolerance = reference_tolerance,
    check.attributes = FALSE,
    info = sprintf("dm with t_custom = %i matches the reference", t_custom)
  )
}

expect_equal(
  current = dm_exact(t_custom = 5L, t_max = 3L),
  target = dm_exact(t_custom = 5L),
  info = "dm t_custom takes precedence over t_max"
)

### kernel parameters ----------------------------------------------------------

for (alpha_norm in c(0, 0.5, 1)) {
  expect_equal(
    current = dm_exact(alpha_norm = alpha_norm),
    target = dm_reference(
      trajectory_data,
      k = 15L,
      t = 5L,
      alpha_norm = alpha_norm
    ),
    tolerance = reference_tolerance,
    check.attributes = FALSE,
    info = sprintf("dm with alpha_norm = %s matches the reference", alpha_norm)
  )
}

expect_equal(
  current = dm_exact(bandwidth_scale = 2),
  target = dm_reference(trajectory_data, k = 15L, t = 5L, bandwidth_scale = 2),
  tolerance = reference_tolerance,
  check.attributes = FALSE,
  info = "dm with bandwidth_scale = 2 matches the reference"
)

# within k the affinity cannot fall below exp(-1), so a threshold needs to be
# above that to drop anything
expect_equal(
  current = dm_exact(thresh = 0.4),
  target = dm_reference(trajectory_data, k = 15L, t = 5L, thresh = 0.4),
  tolerance = reference_tolerance,
  check.attributes = FALSE,
  info = "dm with thresh = 0.4 matches the reference"
)

expect_false(
  current = isTRUE(all.equal(dm_exact(thresh = 0.4), dm_exact())),
  info = "dm thresh = 0.4 drops edges"
)

### number of dimensions -------------------------------------------------------

expect_equal(
  current = dm_exact(n_dim = 4L),
  target = dm_reference(trajectory_data, k = 15L, t = 5L, n_dim = 4L),
  tolerance = reference_tolerance,
  check.attributes = FALSE,
  info = "dm with n_dim = 4L matches the reference"
)

### graph symmetry -------------------------------------------------------------

# Multiplicative and MNN drop one-sided edges. Without a diagonal in the kernel,
# a point with no mutual neighbour has degree zero and goes to Inf at smaller k.
exhaustive_wide <- generate_knn_graph(
  data = trajectory_data,
  k = 150L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

for (symmetry in c("multiplicative", "mnn")) {
  expect_equal(
    current = dm_exact(
      k = 150L,
      knn = exhaustive_wide,
      graph_symmetry = symmetry
    ),
    target = dm_reference(
      trajectory_data,
      k = 150L,
      t = 5L,
      symmetry = symmetry
    ),
    tolerance = reference_tolerance,
    check.attributes = FALSE,
    info = sprintf(
      "dm with graph_symmetry = '%s' matches the reference",
      symmetry
    )
  )
}

expect_true(
  current = is_embedding(dm_exact(graph_symmetry = "none")),
  info = "dm with graph_symmetry = 'none' returns a finite embedding"
)

### precomputed knn ------------------------------------------------------------

expect_equal(
  current = dm_exact(),
  target = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    knn_method = "exhaustive",
    dm_params = params_diffusion_maps(n_landmarks = NULL, t_custom = 5L),
    .verbose = FALSE
  ),
  info = "dm from a precomputed knn matches the internal search"
)

# unlike UMAP, a wider graph is not cut to k
exhaustive_30 <- generate_knn_graph(
  data = trajectory_data,
  k = 30L,
  knn_method = "exhaustive",
  .verbose = FALSE
)

expect_equal(
  current = dm_exact(knn = exhaustive_30),
  target = dm_reference(trajectory_data, k = 15L, t = 5L, width = 30L),
  tolerance = reference_tolerance,
  check.attributes = FALSE,
  info = "dm uses every neighbour of a wider graph, the k-th sets the bandwidth"
)

## other parameters ------------------------------------------------------------

### knn methods ----------------------------------------------------------------

for (knn_method in c(
  "kmknn",
  "hnsw",
  "annoy",
  "balltree",
  "ivf",
  "nndescent"
)) {
  res <- diffusion_maps(
    data = trajectory_data,
    k = 15L,
    knn_method = knn_method,
    dm_params = params_diffusion_maps(n_landmarks = NULL),
    .verbose = FALSE
  )
  expect_true(
    current = is_embedding(res),
    info = sprintf("dm with knn_method = '%s' returns an embedding", knn_method)
  )
}

### distance metric ------------------------------------------------------------

expect_true(
  current = is_embedding(
    diffusion_maps(
      data = trajectory_data,
      k = 15L,
      nn_params = params_nn(dist_metric = "cosine"),
      dm_params = params_diffusion_maps(n_landmarks = NULL),
      .verbose = FALSE
    )
  ),
  info = "dm with cosine distance returns an embedding"
)

### automatic diffusion time ---------------------------------------------------

expect_error(
  current = diffusion_maps(
    data = trajectory_data,
    k = 15L,
    dm_params = params_diffusion_maps(n_landmarks = NULL, t_max = 2L),
    .verbose = FALSE
  ),
  info = "dm errors if t_max is too small to find a knee point"
)

## input validation ------------------------------------------------------------

expect_error(
  current = params_diffusion_maps(alpha_norm = 2),
  info = "dm alpha_norm above 1 is rejected"
)

expect_error(
  current = params_diffusion_maps(bandwidth_scale = 0),
  info = "dm bandwidth_scale of 0 is rejected"
)

expect_error(
  current = params_diffusion_maps(thresh = -1),
  info = "dm negative thresh is rejected"
)

expect_error(
  current = diffusion_maps(trajectory_data, k = 1L, .verbose = FALSE),
  info = "dm k below 2 is rejected"
)

expect_error(
  current = diffusion_maps(trajectory_data, n_dim = 33L, .verbose = FALSE),
  info = "dm n_dim above the number of features is rejected"
)

expect_error(
  current = diffusion_maps(trajectory_data, knn = list(), .verbose = FALSE),
  info = "dm knn of the wrong class is rejected"
)

expect_error(
  current = diffusion_maps(
    trajectory_data,
    dm_params = list(alpha_norm = 1),
    .verbose = FALSE
  ),
  info = "dm malformed dm_params are rejected"
)

## landmarks -------------------------------------------------------------------

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
    current = is_embedding(res),
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
  current = is_embedding(
    diffusion_maps(
      data = trajectory_data,
      n_dim = 3L,
      k = 15L,
      dm_params = params_diffusion_maps(n_landmarks = 50L),
      .verbose = FALSE
    ),
    n_dim = 3L
  ),
  info = "dm with landmarks returns the requested number of dimensions"
)

### precomputed knn ------------------------------------------------------------

expect_equal(
  current = diffusion_maps(
    data = trajectory_data,
    knn = exhaustive,
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
