# Test rs_synthetic_data function ============================================

# Swiss role tests -----------------------------------------------------------

test_that("rs_synthetic_data generates swiss_role data correctly", {
  result <- rs_synthetic_data(
    type = "swiss_role",
    n_samples = 100,
    noise = 0.1,
    seed = 42
  )

  expect_type(result, "list")
  expect_named(result, c("data", "membership"))
  expect_true(is.matrix(result$data))
  expect_equal(nrow(result$data), 100)
  expect_equal(ncol(result$data), 3)
  expect_null(result$membership)
})

test_that("rs_synthetic_data swiss_role is reproducible with seed", {
  result1 <- rs_synthetic_data(
    "swiss_role",
    n_samples = 50,
    noise = 0.1,
    seed = 123
  )
  result2 <- rs_synthetic_data(
    "swiss_role",
    n_samples = 50,
    noise = 0.1,
    seed = 123
  )

  expect_equal(result1$data, result2$data)
})

# Clusters tests -------------------------------------------------------------

test_that("rs_synthetic_data generates clusters data correctly", {
  result <- rs_synthetic_data(
    type = "clusters",
    n_samples = 100,
    dim = 10,
    n_clusters = 5,
    seed = 42
  )

  expect_type(result, "list")
  expect_named(result, c("data", "membership"))
  expect_true(is.matrix(result$data))
  expect_equal(nrow(result$data), 100)
  expect_equal(ncol(result$data), 10)
  expect_type(result$membership, "double")
  expect_length(result$membership, 100)
  expect_true(all(result$membership >= 0))
  expect_true(all(result$membership < 5))
})

test_that("rs_synthetic_data clusters is reproducible with seed", {
  result1 <- rs_synthetic_data(
    "clusters",
    n_samples = 50,
    dim = 5,
    n_clusters = 3,
    seed = 123
  )
  result2 <- rs_synthetic_data(
    "clusters",
    n_samples = 50,
    dim = 5,
    n_clusters = 3,
    seed = 123
  )

  expect_equal(result1$data, result2$data)
  expect_equal(result1$membership, result2$membership)
})


# Tree tests -----------------------------------------------------------------

test_that("rs_synthetic_data generates tree data correctly", {
  result <- rs_synthetic_data(
    type = "tree",
    n_samples = 100,
    dim = 10,
    n_branches = 4,
    noise = 0.05,
    seed = 42
  )

  expect_type(result, "list")
  expect_named(result, c("data", "membership"))
  expect_true(is.matrix(result$data))
  expect_equal(nrow(result$data), 100)
  expect_equal(ncol(result$data), 10)
  expect_null(result$membership)
  expect_true(all(result$membership >= 0))
  expect_true(all(result$membership < 4))
})

test_that("rs_synthetic_data tree is reproducible with seed", {
  result1 <- rs_synthetic_data(
    "tree",
    n_samples = 50,
    dim = 5,
    n_branches = 3,
    noise = 0.1,
    seed = 123
  )
  result2 <- rs_synthetic_data(
    "tree",
    n_samples = 50,
    dim = 5,
    n_branches = 3,
    noise = 0.1,
    seed = 123
  )

  expect_equal(result1$data, result2$data)
  expect_equal(result1$membership, result2$membership)
})

# Parameter validation tests -------------------------------------------------

test_that("rs_synthetic_data validates n_samples parameter", {
  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 0, noise = 0.1, seed = 42),
    "n_samples"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = -10, noise = 0.1, seed = 42),
    "n_samples"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 1.5, noise = 0.1, seed = 42),
    "n_samples"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = "100", noise = 0.1, seed = 42),
    "n_samples"
  )
})

test_that("rs_synthetic_data validates dim parameter", {
  expect_error(
    rs_synthetic_data(
      "clusters",
      n_samples = 100,
      dim = 1,
      n_clusters = 3,
      seed = 42
    ),
    "dim"
  )

  expect_error(
    rs_synthetic_data(
      "clusters",
      n_samples = 100,
      dim = 2.5,
      n_clusters = 3,
      seed = 42
    ),
    "dim"
  )
})

test_that("rs_synthetic_data validates n_clusters parameter", {
  expect_error(
    rs_synthetic_data(
      "clusters",
      n_samples = 100,
      dim = 10,
      n_clusters = 1,
      seed = 42
    ),
    "n_clusters"
  )

  expect_error(
    rs_synthetic_data(
      "clusters",
      n_samples = 100,
      dim = 10,
      n_clusters = 2.5,
      seed = 42
    ),
    "n_clusters"
  )
})

test_that("rs_synthetic_data validates n_branches parameter", {
  expect_error(
    rs_synthetic_data(
      "tree",
      n_samples = 100,
      dim = 10,
      n_branches = 1,
      noise = 0.1,
      seed = 42
    ),
    "n_branches"
  )

  expect_error(
    rs_synthetic_data(
      "tree",
      n_samples = 100,
      dim = 10,
      n_branches = 2.5,
      noise = 0.1,
      seed = 42
    ),
    "n_branches"
  )
})

test_that("rs_synthetic_data validates noise parameter", {
  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100, noise = -0.1, seed = 42),
    "noise"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100, noise = 0, seed = 42),
    "noise"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100, noise = "0.1", seed = 42),
    "noise"
  )
})

test_that("rs_synthetic_data validates seed parameter", {
  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100, noise = 0.1, seed = 1.5),
    "seed"
  )

  expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100, noise = 0.1, seed = "42"),
    "seed"
  )
})

test_that("rs_synthetic_data validates type parameter", {
  expect_error(
    rs_synthetic_data("invalid_type", n_samples = 100),
    "'arg' should be one of"
  )
})

# Edge cases and defaults ----------------------------------------------------

test_that("rs_synthetic_data works with default parameters", {
  result <- rs_synthetic_data("swiss_role", n_samples = 1000L)
  expect_type(result, "list")
  expect_true(is.matrix(result$data))
})
