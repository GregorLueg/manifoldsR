# k means tests ----------------------------------------------------------------

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

# full k-means -----------------------------------------------------------------

res_full <- kmeans_cluster(
  data = cluster_data,
  k = n_clusters,
  method = "full",
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testList(x = res_full, len = 5),
  info = "full kmeans returns expected list length"
)
expect_true(
  current = checkmate::testNames(
    x = names(res_full),
    must.include = c("centroids", "assignments")
  ),
  info = "full kmeans returns expected names"
)
expect_true(
  current = checkmate::testMatrix(
    x = res_full$centroids,
    mode = "numeric",
    nrows = n_clusters,
    ncols = 32L
  ),
  info = "full kmeans centroids have correct dimensions"
)
expect_true(
  current = checkmate::qtest(
    x = res_full$assignments,
    sprintf("I%d[0,%d]", n_samples, n_clusters - 1)
  ),
  info = "full kmeans assignments are valid indices"
)
expect_equal(
  current = length(unique(res_full$assignments)),
  target = n_clusters,
  info = "full kmeans uses all clusters"
)

# well-separated data should yield high ARI
ari_full <- calc_ari(as.integer(cluster_membership), res_full$assignments)
expect_true(
  current = ari_full > 0.9,
  info = "full kmeans recovers known clusters"
)

# mini-batch k-means -----------------------------------------------------------

res_mb <- kmeans_cluster(
  data = cluster_data,
  k = n_clusters,
  method = "minibatch",
  seed = 42L,
  .verbose = FALSE
)

expect_true(
  current = checkmate::testMatrix(
    x = res_mb$centroids,
    mode = "numeric",
    nrows = n_clusters,
    ncols = 32L
  ),
  info = "minibatch centroids have correct dimensions"
)
expect_true(
  current = checkmate::qtest(
    x = res_mb$assignments,
    sprintf("I%d[0,%d]", n_samples, n_clusters - 1)
  ),
  info = "minibatch assignments are valid indices"
)

ari_mb <- calc_ari(as.integer(cluster_membership), res_mb$assignments)
expect_true(
  current = ari_mb > 0.9,
  info = "minibatch recovers known clusters"
)

## reproducibility -------------------------------------------------------------

res_a <- kmeans_cluster(
  cluster_data,
  k = n_clusters,
  method = "full",
  seed = 99L,
  .verbose = FALSE
)
res_b <- kmeans_cluster(
  cluster_data,
  k = n_clusters,
  method = "full",
  seed = 99L,
  .verbose = FALSE
)
expect_equal(
  current = res_a$assignments,
  target = res_b$assignments,
  info = "full kmeans is deterministic with same seed"
)

res_c <- kmeans_cluster(
  cluster_data,
  k = n_clusters,
  method = "minibatch",
  seed = 99L,
  .verbose = FALSE
)
res_d <- kmeans_cluster(
  cluster_data,
  k = n_clusters,
  method = "minibatch",
  seed = 99L,
  .verbose = FALSE
)
expect_equal(
  current = res_c$assignments,
  target = res_d$assignments,
  info = "minibatch is deterministic with same seed"
)

## data frame input ------------------------------------------------------------

df_input <- as.data.frame(cluster_data)
res_df <- kmeans_cluster(
  df_input,
  k = n_clusters,
  method = "full",
  seed = 42L,
  .verbose = FALSE
)
expect_equal(
  current = res_df$assignments,
  target = res_full$assignments,
  info = "data frame input matches matrix input"
)

## both methods agree on easy data ---------------------------------------------

expect_true(
  current = calc_ari(res_full$assignments, res_mb$assignments) > 0.9,
  info = "full and minibatch agree on well-separated data"
)
