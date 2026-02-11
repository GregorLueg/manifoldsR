# Test params_umap function =================================================

# Basic functionality tests --------------------------------------------------

test_that("params_umap creates valid parameter list with defaults", {
    params <- params_umap()

    expect_type(params, "list")
    expect_named(
        params,
        c("knn_method", "optimiser", "init", "n_epochs", "randomised")
    )
    expect_equal(params$knn_method, "annoy")
    expect_equal(params$optimiser, "sgd")
    expect_equal(params$init, "spectral")
    expect_null(params$n_epochs)
})

test_that("params_umap accepts all valid knn_method values", {
    params_hnsw <- params_umap(knn_method = "hnsw")
    expect_equal(params_hnsw$knn_method, "hnsw")

    params_annoy <- params_umap(knn_method = "annoy")
    expect_equal(params_annoy$knn_method, "annoy")
})

test_that("params_umap accepts all valid optimiser values", {
    params_adam <- params_umap(optimiser = "adam_parallel")
    expect_equal(params_adam$optimiser, "adam_parallel")

    params_sgd <- params_umap(optimiser = "sgd")
    expect_equal(params_sgd$optimiser, "sgd")
})

test_that("params_umap accepts all valid init values", {
    params_spectral <- params_umap(init = "spectral")
    expect_equal(params_spectral$init, "spectral")

    params_pca <- params_umap(init = "pca")
    expect_equal(params_pca$init, "pca")
})

test_that("params_umap handles custom n_epochs", {
    params <- params_umap(n_epochs = 1000L)
    expect_equal(params$n_epochs, 1000L)
})

test_that("params_umap handles randomised parameter", {
    params_true <- params_umap(randomised = TRUE)
    expect_named(
        params_true,
        c("knn_method", "optimiser", "init", "n_epochs", "randomised")
    )
    expect_true(params_true$randomised)

    params_false <- params_umap(randomised = FALSE)
    expect_named(
        params_false,
        c("knn_method", "optimiser", "init", "n_epochs", "randomised")
    )
    expect_false(params_false$randomised)
})

# Parameter combination tests ------------------------------------------------

test_that("params_umap works with all parameters specified", {
    params <- params_umap(
        knn_method = "annoy",
        optimiser = "sgd",
        init = "pca",
        n_epochs = 200L,
        randomised = TRUE
    )

    expect_equal(params$knn_method, "annoy")
    expect_equal(params$optimiser, "sgd")
    expect_equal(params$init, "pca")
    expect_equal(params$n_epochs, 200L)
    expect_true(params$randomised)
})

# Validation tests -----------------------------------------------------------

test_that("params_umap validates knn_method parameter", {
    expect_error(
        params_umap(knn_method = "invalid"),
        "knn_method"
    )
})

test_that("params_umap validates optimiser parameter", {
    expect_error(
        params_umap(optimiser = "invalid"),
        "optimiser"
    )
})

test_that("params_umap validates init parameter", {
    expect_error(
        params_umap(init = "invalid"),
        "init"
    )
})

test_that("params_umap validates n_epochs parameter", {
    expect_error(
        params_umap(n_epochs = 0),
        "n_epochs"
    )

    expect_error(
        params_umap(n_epochs = -10),
        "n_epochs"
    )

    expect_error(
        params_umap(n_epochs = 1.5),
        "n_epochs"
    )

    expect_error(
        params_umap(n_epochs = "500"),
        "n_epochs"
    )
})

test_that("params_umap validates randomised parameter", {
    expect_error(
        params_umap(randomised = "true"),
        "randomised"
    )

    expect_error(
        params_umap(randomised = 1),
        "randomised"
    )

    expect_error(
        params_umap(randomised = c(TRUE, FALSE)),
        "randomised"
    )
})

# Type coercion tests --------------------------------------------------------

test_that("params_umap coerces n_epochs to integer", {
    params <- params_umap(n_epochs = 250L)
    expect_type(params$n_epochs, "integer")
    expect_equal(params$n_epochs, 250L)
})

# Practical usage tests ------------------------------------------------------

test_that("params_umap output can be used in list context", {
    params <- params_umap(
        knn_method = "hnsw",
        optimiser = "adam_parallel",
        init = "spectral",
        n_epochs = 500L
    )

    # Should be able to access all elements
    expect_no_error({
        knn <- params$knn_method
        opt <- params$optimiser
        ini <- params$init
        epochs <- params$n_epochs
    })
})

# Test params_tsne function ==================================================

# Basic functionality tests --------------------------------------------------

test_that("params_tsne creates valid parameter list with defaults", {
    params <- params_tsne()

    expect_type(params, "list")
    expect_named(params, c("knn_method", "dist_metric", "theta"))
    expect_equal(params$knn_method, "hnsw")
    expect_equal(params$dist_metric, "euclidean")
    expect_equal(params$theta, 0.5)
})

test_that("params_tsne accepts all valid knn_method values", {
    params_hnsw <- params_tsne(knn_method = "hnsw")
    expect_equal(params_hnsw$knn_method, "hnsw")

    params_annoy <- params_tsne(knn_method = "annoy")
    expect_equal(params_annoy$knn_method, "annoy")
})

test_that("params_tsne accepts all valid dist_metric values", {
    params_euclidean <- params_tsne(dist_metric = "euclidean")
    expect_equal(params_euclidean$dist_metric, "euclidean")

    params_cosine <- params_tsne(dist_metric = "cosine")
    expect_equal(params_cosine$dist_metric, "cosine")

    params_manhattan <- params_tsne(dist_metric = "manhattan")
    expect_equal(params_manhattan$dist_metric, "manhattan")
})

test_that("params_tsne handles custom theta", {
    params <- params_tsne(theta = 0.3)
    expect_equal(params$theta, 0.3)
})

# Parameter combination tests ------------------------------------------------

test_that("params_tsne works with all parameters specified", {
    params <- params_tsne(
        knn_method = "annoy",
        dist_metric = "cosine",
        theta = 0.7
    )

    expect_equal(params$knn_method, "annoy")
    expect_equal(params$dist_metric, "cosine")
    expect_equal(params$theta, 0.7)
})

# Validation tests -----------------------------------------------------------

test_that("params_tsne validates knn_method parameter", {
    expect_error(
        params_tsne(knn_method = "invalid"),
        "knn_method"
    )
})

test_that("params_tsne validates dist_metric parameter", {
    expect_error(
        params_tsne(dist_metric = "invalid"),
        "dist_metric"
    )
})

test_that("params_tsne validates theta parameter", {
    expect_error(
        params_tsne(theta = -0.1),
        "theta"
    )

    expect_error(
        params_tsne(theta = 1.5),
        "theta"
    )

    expect_error(
        params_tsne(theta = "0.5"),
        "theta"
    )
})

test_that("params_tsne accepts theta boundary values", {
    params_zero <- params_tsne(theta = 0)
    expect_equal(params_zero$theta, 0)

    params_one <- params_tsne(theta = 1)
    expect_equal(params_one$theta, 1)
})

# Practical usage tests ------------------------------------------------------

test_that("params_tsne output can be used in list context", {
    params <- params_tsne(
        knn_method = "hnsw",
        dist_metric = "euclidean",
        theta = 0.5
    )

    # Should be able to access all elements
    expect_no_error({
        knn <- params$knn_method
        dist <- params$dist_metric
        th <- params$theta
    })
})

# Integration tests ----------------------------------------------------------

test_that("params_tsne creates appropriate params for different approximation types", {
    # For FFT approximation
    params_fft <- params_tsne(
        knn_method = "hnsw",
        dist_metric = "euclidean",
        theta = 0.5
    )
    expect_type(params_fft, "list")

    # For Barnes-Hut approximation with different theta
    params_bh <- params_tsne(
        knn_method = "hnsw",
        dist_metric = "euclidean",
        theta = 0.3
    )
    expect_equal(params_bh$theta, 0.3)
})
