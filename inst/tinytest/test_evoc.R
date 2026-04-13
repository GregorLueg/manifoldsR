# evoc tests -------------------------------------------------------------------

## synthetic data --------------------------------------------------------------

n_samples <- 200L
n_clusters <- 3L

zeallot::`%<-%`(
  c(cluster_data, cluster_membership),
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = n_clusters,
    seed = 42L
  )
)

cluster_data_df <- as.data.frame(cluster_data)

## knn graph -------------------------------------------------------------------

exhaustive <- generate_knn_graph(
  data = cluster_data,
  k = 5L,
  knn_method = "exhaustive"
)

## evoc ------------------------------------------------------------------------

### basics ---------------------------------------------------------------------

evoc_res <- evoc(
  data = cluster_data,
  n_neighbours = 5L,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testClass(evoc_res, "Evoc"),
  info = "evoc returns Evoc S3 class"
)

expect_true(
  current = checkmate::testNames(
    x = names(evoc_res),
    must.include = c(
      "cluster_layers",
      "membership_strengths",
      "persistence_scores",
      "knn"
    )
  ),
  info = "evoc result has expected names"
)

expect_true(
  current = length(evoc_res$cluster_layers) >= 1L,
  info = "evoc returns at least one cluster layer"
)

# best layer should recover the known structure
best <- best_membership(evoc_res)
expect_true(
  current = checkmate::qtest(best$labels, sprintf("I%d", n_samples)),
  info = "best_membership returns integer vector of correct length"
)

# well-separated synthetic data: best layer should have high ARI
ari_evoc <- calc_ari(as.integer(cluster_membership), best$labels)
expect_true(
  current = ari_evoc > 0.8,
  info = "evoc recovers known clusters on well-separated data"
)

### data frame input -----------------------------------------------------------

evoc_res_df <- evoc(
  data = cluster_data_df,
  n_neighbours = 5L,
  seed = 42L,
  .verbose = FALSE
)

expect_equal(
  current = best_membership(evoc_res_df),
  target = best,
  info = "data frame input matches matrix input"
)

### from pre-computed kNN ----------------------------------------------------

evoc_res_knn <- evoc(
  data = cluster_data,
  knn = exhaustive,
  n_neighbours = 5L,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testClass(evoc_res_knn, "Evoc"),
  info = "evoc from pre-computed kNN returns Evoc class"
)

ari_evoc_knn <- calc_ari(
  as.integer(cluster_membership),
  best_membership(evoc_res_knn)$labels
)
expect_true(
  current = ari_evoc_knn > 0.8,
  info = "evoc from pre-computed kNN recovers known clusters"
)

### return_knn -----------------------------------------------------------------

evoc_res_with_knn <- evoc(
  data = cluster_data,
  n_neighbours = 5L,
  return_knn = TRUE,
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testClass(evoc_res_with_knn$knn, "NearestNeighbours"),
  info = "return_knn returns NearestNeighbours object"
)

expect_true(
  current = is.null(evoc_res$knn),
  info = "knn is NULL when return_knn = FALSE"
)

### reproducibility ------------------------------------------------------------

evoc_a <- evoc(cluster_data, n_neighbours = 5L, seed = 99L, .verbose = FALSE)
evoc_b <- evoc(cluster_data, n_neighbours = 5L, seed = 99L, .verbose = FALSE)

expect_equal(
  current = best_membership(evoc_a),
  target = best_membership(evoc_b),
  info = "evoc is deterministic with same seed"
)

### get_layer ------------------------------------------------------------------

layer_1 <- get_layer(evoc_res, 1L)

expect_true(
  current = checkmate::testList(layer_1, names = "named"),
  info = "get_layer returns list"
)
expect_true(
  current = checkmate::testNames(
    names(layer_1),
    must.include = c("labels", "membership", "persistence")
  ),
  info = "get_layer returns right elements"
)

### persistence scores ---------------------------------------------------------

expect_true(
  current = checkmate::testNumeric(
    evoc_res$persistence_scores,
    lower = 0,
    min.len = 1L
  ),
  info = "persistence scores are non-negative numerics"
)

expect_equal(
  current = length(evoc_res$persistence_scores),
  target = length(evoc_res$cluster_layers),
  info = "persistence scores match number of layers"
)

### approx_n_clusters ----------------------------------------------------------

evoc_approx <- evoc(
  data = cluster_data,
  n_neighbours = 5L,
  evoc_params = params_evoc(approx_n_clusters = 2L),
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testClass(evoc_approx, "Evoc"),
  info = "evoc with approx_n_clusters runs without error"
)

n_found <- length(unique(best_membership(evoc_approx)$labels))

expect_true(
  current = n_found == 2L,
  info = "approx_n_clusters produces roughly the requested number of clusters"
)

## .prepare_evoc_params --------------------------------------------------------

prep <- .prepare_evoc_params(
  knn_method = "hnsw",
  nn_params = params_nn(dist_metric = "cosine"),
  evoc_params = params_evoc(noise_level = 0.3, min_samples = 10L)
)

expect_equal(
  current = prep$knn_method,
  target = "hnsw",
  info = "knn_method is set in prepared params"
)

expect_equal(
  current = prep$dist_metric,
  target = "cosine",
  info = "nn_params fields are present in prepared params"
)

expect_equal(
  current = prep$noise_level,
  target = 0.3,
  info = "evoc_params fields are present in prepared params"
)

expect_equal(
  current = prep$min_samples,
  target = 10L,
  info = "evoc_params overrides are present in prepared params"
)
