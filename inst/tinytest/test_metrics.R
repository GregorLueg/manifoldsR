# metrics ----------------------------------------------------------------------

## ARI -------------------------------------------------------------------------

expect_equal(
  current = calc_ari(c(1L, 1L, 2L, 2L, 3L, 3L), c(1L, 1L, 2L, 2L, 3L, 3L)),
  target = 1.0,
  info = "ARI score behaves with perfect data"
)

expect_equal(
  current = calc_ari(c(1L, 1L, 2L, 2L, 3L, 3L), c(3L, 3L, 1L, 1L, 2L, 2L)),
  target = 1.0,
  info = "ARI score behaves with perfect, permuted data data"
)

# random data

set.seed(42)
fixed <- rep(1:5, each = 200)
random <- sample(1:5, 1000, replace = TRUE)
ari_random <- calc_ari(fixed, random)

expect_true(
  abs(ari_random) < 0.1,
  info = "ARI on random data is low"
)

# All points in one cluster vs real structure gives low/zero ARI
expect_true(
  current = calc_ari(c(1L, 1L, 2L, 2L, 3L, 3L), rep(1L, 6)) < 0.01,
  info = "single cluster yields low scores"
)

a <- c(1L, 1L, 2L, 2L, 3L, 3L)
b <- c(1L, 2L, 2L, 3L, 3L, 3L)

expect_equal(
  current = calc_ari(a, b),
  target = calc_ari(b, a),
  info = "symmetry behaving"
)

# silhouette -------------------------------------------------------------------

## well-separated clusters -----------------------------------------------------

set.seed(123)
clust1 <- matrix(rnorm(100 * 2, mean = 0, sd = 0.1), ncol = 2)
clust2 <- matrix(rnorm(100 * 2, mean = 10, sd = 0.1), ncol = 2)
data_sep <- rbind(clust1, clust2)
membership_sep <- c(rep(1L, 100), rep(2L, 100))

res_sep <- calc_silhouette_score(data_sep, membership_sep)

expect_true(
  current = checkmate::testList(x = res_sep, len = 2),
  info = "silhouette score returns list"
)
expect_true(
  current = checkmate::testNames(
    x = names(res_sep),
    must.include = c("mean_silhouette", "silhouette_scores")
  ),
  info = "silhouette score returns expected names"
)
expect_true(
  current = checkmate::qtest(x = res_sep$silhouette_scores, "N200[-1, 1]"),
  info = "silhouette scores of correct type/length"
)

expect_true(
  current = res_sep$mean_silhouette > 0.9,
  info = "average silhouette scores are high for well-separated data"
)

## badly-separated clusters -----------------------------------------------------

set.seed(246)
clust_a <- matrix(rnorm(100 * 2, mean = 0, sd = 2), ncol = 2)
clust_b <- matrix(rnorm(100 * 2, mean = 0, sd = 2), ncol = 2)
data_overlap <- rbind(clust_a, clust_b)
membership_overlap <- c(rep(1L, 100), rep(2L, 100))

res_overlap <- calc_silhouette_score(data_overlap, membership_overlap)

expect_true(
  current = res_overlap$mean_silhouette < 0.3,
  info = "low silhouette score for bad data"
)

## single cluster --------------------------------------------------------------

# should return NAs, as it's undefined
data_single <- matrix(rnorm(50 * 2), ncol = 2)
res_single <- calc_silhouette_score(data_single, rep(1L, 50))

expect_true(
  current = is.na(res_single$mean_silhouette),
  info = "NA for single clusters in average silhouette score"
)
expect_true(
  current = all(is.na(res_single$silhouette_scores)),
  info = "NA for single clusters in all silhouette scores"
)
