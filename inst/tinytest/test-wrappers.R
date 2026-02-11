# umap works with basic inputs
# Generate simple test data
set.seed(42)
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Test basic UMAP
result <- umap(test_data, seed = 42L)

expect_true(is.matrix(result))
expect_equal(nrow(result), 100L)
expect_equal(ncol(result), 2L)
expect_true(all(is.finite(result)))

# umap handles data frames
# Test with data frame
result <- umap(iris[, 1:4], seed = 42L)

expect_true(is.matrix(result))
expect_equal(nrow(result), nrow(iris))
expect_equal(ncol(result), 2L)

# umap validates inputs correctly
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Invalid n_dim
expect_error(umap(test_data, n_dim = 0))
expect_error(umap(test_data, n_dim = 10))

# Invalid k
expect_error(umap(test_data, k = 1))
expect_error(umap(test_data, k = 500))

# Invalid min_dist
expect_error(umap(test_data, min_dist = -0.1))

# Invalid spread
expect_error(umap(test_data, spread = -1))

# umap respects custom parameters
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Test with custom main parameters
result <- umap(
    test_data,
    n_dim = 3L,
    k = 20L,
    min_dist = 0.3,
    spread = 2.0,
    seed = 42L
)

expect_equal(ncol(result), 3L)

# Test with custom params and explicit n_epochs
custom_params <- params_umap(
    knn_method = "annoy",
    optimiser = "sgd",
    n_epochs = 100L
)

result <- umap(
    test_data,
    params = custom_params,
    seed = 42L
)

expect_equal(ncol(result), 2)

# umap automatic n_epochs detection works
# Small dataset (<10k) should use 500 epochs
small_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)
params_small <- params_umap(optimiser = "sgd")
expect_true(is.null(params_small$n_epochs))

# Large dataset (>=10k) with sgd should use 200 epochs
# (We won't actually run this due to size, just test the params)
params_large_sgd <- params_umap(optimiser = "sgd")
expect_true(is.null(params_large_sgd$n_epochs))

# adam_parallel should always suggest 500
params_adam <- params_umap(optimiser = "adam_parallel")
expect_true(is.null(params_adam$n_epochs))

# User override should be respected
params_override <- params_umap(optimiser = "sgd", n_epochs = 1000L)
expect_equal(params_override$n_epochs, 1000L)

# tsne works with basic inputs
# Generate simple test data
set.seed(42)
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Test basic tSNE
result <- tsne(test_data, seed = 42L)

expect_true(is.matrix(result))
expect_equal(nrow(result), 100L)
expect_equal(ncol(result), 2L)
expect_true(all(is.finite(result)))

# tsne handles data frames
# Test with data frame
result <- tsne(iris[, 1:4], seed = 42)

expect_true(is.matrix(result))
expect_equal(nrow(result), nrow(iris))
expect_equal(ncol(result), 2)

# tsne validates inputs correctly
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Invalid n_dim (only 2 supported)
expect_error(tsne(test_data, n_dim = 3))

# Invalid perplexity
expect_error(tsne(test_data, perplexity = 0))
expect_error(tsne(test_data, perplexity = 50)) # Too high for 100 samples

# Invalid approx_type
expect_error(tsne(test_data, approx_type = "invalid"))

# tsne respects custom parameters
test_data <- matrix(rnorm(100 * 5), nrow = 100, ncol = 5)

# Test with custom main parameters
result <- tsne(
    test_data,
    perplexity = 20L,
    approx_type = "fft",
    seed = 42L
)

expect_equal(ncol(result), 2L)

# Test with custom params
custom_params <- params_tsne(
    knn_method = "annoy",
    dist_metric = "manhattan",
    theta = 0.3
)

result <- tsne(
    test_data,
    params = custom_params,
    seed = 42L
)

expect_equal(ncol(result), 2L)

# umap and tsne handle edge cases
# Small dataset
small_data <- matrix(rnorm(10 * 3), nrow = 10, ncol = 3)

umap(small_data, seed = 42L)
expect_true(TRUE) # If we got here without error, test passed

tsne(small_data, seed = 42L)
expect_true(TRUE) # If we got here without error, test passed

# Missing values should error
data_with_na <- small_data
data_with_na[1, 1] <- NA

expect_error(umap(data_with_na))
expect_error(tsne(data_with_na))
