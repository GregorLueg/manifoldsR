# Test rs_synthetic_data function ============================================

# Swiss role tests -----------------------------------------------------------

# rs_synthetic_data generates swiss_role data correctly
result <- rs_synthetic_data(
    type = "swiss_role",
    n_samples = 100L,
    noise = 0.1,
    seed = 42L
)

expect_equal(typeof(result), "list")
expect_equal(names(result), c("data", "membership"))
expect_true(is.matrix(result$data))
expect_equal(nrow(result$data), 100L)
expect_equal(ncol(result$data), 3L)
expect_true(is.null(result$membership))

# rs_synthetic_data swiss_role is reproducible with seed
result1 <- rs_synthetic_data(
    "swiss_role",
    n_samples = 50L,
    noise = 0.1,
    seed = 123L
)
result2 <- rs_synthetic_data(
    "swiss_role",
    n_samples = 50L,
    noise = 0.1,
    seed = 123L
)

expect_equal(result1$data, result2$data)

# Clusters tests -------------------------------------------------------------

# rs_synthetic_data generates clusters data correctly
result <- rs_synthetic_data(
    type = "clusters",
    n_samples = 100L,
    dim = 10L,
    n_clusters = 5L,
    seed = 42L
)

expect_equal(typeof(result), "list")
expect_equal(names(result), c("data", "membership"))
expect_true(is.matrix(result$data))
expect_equal(nrow(result$data), 100)
expect_equal(ncol(result$data), 10)
expect_equal(typeof(result$membership), "double")
expect_equal(length(result$membership), 100)
expect_true(all(result$membership >= 0))
expect_true(all(result$membership < 5))

# rs_synthetic_data clusters is reproducible with seed
result1 <- rs_synthetic_data(
    "clusters",
    n_samples = 50L,
    dim = 5L,
    n_clusters = 3L,
    seed = 123L
)
result2 <- rs_synthetic_data(
    "clusters",
    n_samples = 50L,
    dim = 5L,
    n_clusters = 3L,
    seed = 123L
)

expect_equal(result1$data, result2$data)
expect_equal(result1$membership, result2$membership)


# Tree tests -----------------------------------------------------------------

# rs_synthetic_data generates tree data correctly
result <- rs_synthetic_data(
    type = "tree",
    n_samples = 100L,
    dim = 10L,
    n_branches = 4L,
    noise = 0.05,
    seed = 42L
)

expect_equal(typeof(result), "list")
expect_equal(names(result), c("data", "membership"))
expect_true(is.matrix(result$data))
expect_equal(nrow(result$data), 100L)
expect_equal(ncol(result$data), 10L)
expect_true(is.null(result$membership))
expect_true(all(result$membership >= 0L))
expect_true(all(result$membership < 4L))

# rs_synthetic_data tree is reproducible with seed
result1 <- rs_synthetic_data(
    "tree",
    n_samples = 50L,
    dim = 5L,
    n_branches = 3L,
    noise = 0.1,
    seed = 123L
)
result2 <- rs_synthetic_data(
    "tree",
    n_samples = 50L,
    dim = 5L,
    n_branches = 3L,
    noise = 0.1,
    seed = 123L
)

expect_equal(result1$data, result2$data)
expect_equal(result1$membership, result2$membership)

# Parameter validation tests -------------------------------------------------

# rs_synthetic_data validates n_samples parameter
expect_error(
    rs_synthetic_data("swiss_role", n_samples = 0, noise = 0.1, seed = 42),
    pattern = "n_samples"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = -10, noise = 0.1, seed = 42),
    pattern = "n_samples"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = 1.5, noise = 0.1, seed = 42),
    pattern = "n_samples"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = "100", noise = 0.1, seed = 42),
    pattern = "n_samples"
)

# rs_synthetic_data validates dim parameter
expect_error(
    rs_synthetic_data(
        "clusters",
        n_samples = 100L,
        dim = 1L,
        n_clusters = 3L,
        seed = 42L
    ),
    pattern = "dim"
)

expect_error(
    rs_synthetic_data(
        "clusters",
        n_samples = 100L,
        dim = 2.5,
        n_clusters = 3L,
        seed = 42L
    ),
    pattern = "dim"
)

# rs_synthetic_data validates n_clusters parameter
expect_error(
    rs_synthetic_data(
        "clusters",
        n_samples = 100L,
        dim = 10L,
        n_clusters = 1L,
        seed = 42
    ),
    pattern = "n_clusters"
)

expect_error(
    rs_synthetic_data(
        "clusters",
        n_samples = 100L,
        dim = 10L,
        n_clusters = 2.5,
        seed = 42
    ),
    pattern = "n_clusters"
)

# rs_synthetic_data validates n_branches parameter
expect_error(
    rs_synthetic_data(
        "tree",
        n_samples = 100L,
        dim = 10L,
        n_branches = 1L,
        noise = 0.1,
        seed = 42
    ),
    pattern = "n_branches"
)

expect_error(
    rs_synthetic_data(
        "tree",
        n_samples = 100L,
        dim = 10L,
        n_branches = 2.5,
        noise = 0.1,
        seed = 42
    ),
    pattern = "n_branches"
)

# rs_synthetic_data validates noise parameter
expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100L, noise = -0.1, seed = 42),
    pattern = "noise"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100L, noise = 0, seed = 42),
    pattern = "noise"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100L, noise = "0.1", seed = 42),
    pattern = "noise"
)

# rs_synthetic_data validates seed parameter
expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100L, noise = 0.1, seed = 1.5),
    pattern = "seed"
)

expect_error(
    rs_synthetic_data("swiss_role", n_samples = 100L, noise = 0.1, seed = "42"),
    pattern = "seed"
)

# rs_synthetic_data validates type parameter
expect_error(
    rs_synthetic_data("invalid_type", n_samples = 100L),
    pattern = "'arg' should be one of"
)

# Edge cases and defaults ----------------------------------------------------

# rs_synthetic_data works with default parameters
result <- rs_synthetic_data("swiss_role", n_samples = 1000L)
expect_equal(typeof(result), "list")
expect_true(is.matrix(result$data))
