# test manifold_synthetic_data -------------------------------------------------

n_samples <- 1000L

## swiss role ------------------------------------------------------------------

swiss <- manifold_synthetic_data(
  type = "swiss_role",
  n_samples = n_samples,
  seed = 42L
)

expect_true(
  current = checkmate::testMatrix(
    swiss$data,
    mode = "numeric",
    nrow = n_samples
  ),
  info = "swiss_role returns numeric matrix with correct number of rows"
)

expect_null(
  current = swiss$membership,
  info = "swiss_role membership is NULL"
)

## clusters --------------------------------------------------------------------

n_clusters <- 5L

clusters <- manifold_synthetic_data(
  type = "clusters",
  n_samples = n_samples,
  dim = 10L,
  n_clusters = n_clusters,
  seed = 42L
)

expect_true(
  current = checkmate::testMatrix(
    clusters$data,
    mode = "numeric",
    nrow = n_samples,
    ncol = 10L
  ),
  info = "clusters returns numeric matrix with correct dimensions"
)

expect_true(
  current = checkmate::testInteger(clusters$membership, len = n_samples),
  info = "clusters membership is integer vector of correct length"
)

expect_equal(
  current = length(unique(clusters$membership)),
  target = n_clusters,
  info = "clusters membership has correct number of unique clusters"
)

## trajectory ------------------------------------------------------------------

### pre-defined topologies -----------------------------------------------------

topologies <- c("bifurcation", "linear", "combination")

for (topo in topologies) {
  traj <- manifold_synthetic_data(
    type = "trajectory",
    n_samples = n_samples,
    dim = 10L,
    topology = topo,
    seed = 42L
  )

  expect_true(
    current = checkmate::testMatrix(
      traj$data,
      mode = "numeric",
      nrow = n_samples,
      ncol = 10L
    ),
    info = sprintf(
      "%s topology returns numeric matrix with correct dimensions",
      topo
    )
  )

  expect_true(
    current = checkmate::testInteger(traj$membership, len = n_samples),
    info = sprintf(
      "%s topology membership is integer vector of correct length",
      topo
    )
  )
}

### custom cell_trajectories ---------------------------------------------------

custom_trajectories <- list(
  parent = c(NA_integer_, 0L, 0L),
  split_at = c(0.0, 0.5, 0.5),
  length = c(1.0, 1.0, 1.0)
)

traj_custom <- manifold_synthetic_data(
  type = "trajectory",
  n_samples = n_samples,
  dim = 10L,
  cell_trajectories = custom_trajectories,
  seed = 42L
)

expect_true(
  current = checkmate::testMatrix(
    traj_custom$data,
    mode = "numeric",
    nrow = n_samples,
    ncol = 10L
  ),
  info = "custom cell_trajectories returns numeric matrix with correct dimensions"
)

expect_true(
  current = checkmate::testInteger(traj_custom$membership, len = n_samples),
  info = "custom cell_trajectories membership is integer vector of correct length"
)

### input validation -----------------------------------------------------------

expect_error(
  current = manifold_synthetic_data(type = "swiss_role", n_samples = -1L),
  info = "negative n_samples raises error"
)

expect_error(
  current = manifold_synthetic_data(
    type = "clusters",
    n_samples = n_samples,
    dim = 0L
  ),
  info = "dim of 0 raises error"
)

expect_error(
  current = manifold_synthetic_data(
    type = "trajectory",
    n_samples = n_samples,
    cell_trajectories = list(parent = NA_integer_, split_at = 0.5)
  ),
  info = "malformed cell_trajectories missing 'length' raises error"
)

expect_error(
  current = manifold_synthetic_data(
    type = "trajectory",
    n_samples = n_samples,
    cell_trajectories = list(
      parent = c(NA_integer_, 0L),
      split_at = c(0.0),
      length = c(1.0, 1.0)
    )
  ),
  info = "cell_trajectories with unequal vector lengths raises error"
)
