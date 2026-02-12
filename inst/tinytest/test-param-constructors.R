# Test params_umap function =================================================

# Basic functionality tests --------------------------------------------------

# params_umap creates valid parameter list with defaults
params <- params_umap()
expect_equal(typeof(params), "list")
expect_equal(
    names(params),
    c("knn_method", "optimiser", "init", "n_epochs", "randomised")
)
expect_equal(params$knn_method, "annoy")
expect_equal(params$optimiser, "sgd")
expect_equal(params$init, "spectral")
expect_true(is.null(params$n_epochs))

# params_umap accepts all valid knn_method values
params_hnsw <- params_umap(knn_method = "hnsw")
expect_equal(params_hnsw$knn_method, "hnsw")

params_annoy <- params_umap(knn_method = "annoy")
expect_equal(params_annoy$knn_method, "annoy")

# params_umap accepts all valid optimiser values
params_adam <- params_umap(optimiser = "adam_parallel")
expect_equal(params_adam$optimiser, "adam_parallel")

params_sgd <- params_umap(optimiser = "sgd")
expect_equal(params_sgd$optimiser, "sgd")

# params_umap accepts all valid init values
params_spectral <- params_umap(init = "spectral")
expect_equal(params_spectral$init, "spectral")

params_pca <- params_umap(init = "pca")
expect_equal(params_pca$init, "pca")

# params_umap handles custom n_epochs
params <- params_umap(n_epochs = 1000L)
expect_equal(params$n_epochs, 1000L)

# params_umap handles randomised parameter
params_true <- params_umap(randomised = TRUE)
expect_equal(
    names(params_true),
    c("knn_method", "optimiser", "init", "n_epochs", "randomised")
)
expect_true(params_true$randomised)

params_false <- params_umap(randomised = FALSE)
expect_equal(
    names(params_false),
    c("knn_method", "optimiser", "init", "n_epochs", "randomised")
)
expect_false(params_false$randomised)

# Parameter combination tests ------------------------------------------------

# params_umap works with all parameters specified
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

# Validation tests -----------------------------------------------------------

# params_umap validates knn_method parameter
expect_error(
    params_umap(knn_method = "invalid"),
    pattern = "knn_method"
)

# params_umap validates optimiser parameter
expect_error(
    params_umap(optimiser = "invalid"),
    pattern = "optimiser"
)

# params_umap validates init parameter
expect_error(
    params_umap(init = "invalid"),
    pattern = "init"
)

# params_umap validates n_epochs parameter
expect_error(
    params_umap(n_epochs = 0),
    pattern = "n_epochs"
)

expect_error(
    params_umap(n_epochs = -10),
    pattern = "n_epochs"
)

expect_error(
    params_umap(n_epochs = 1.5),
    pattern = "n_epochs"
)

expect_error(
    params_umap(n_epochs = "500"),
    pattern = "n_epochs"
)

# params_umap validates randomised parameter
expect_error(
    params_umap(randomised = "true"),
    pattern = "randomised"
)

expect_error(
    params_umap(randomised = 1),
    pattern = "randomised"
)

expect_error(
    params_umap(randomised = c(TRUE, FALSE)),
    pattern = "randomised"
)

# Type coercion tests --------------------------------------------------------

# params_umap coerces n_epochs to integer
params <- params_umap(n_epochs = 250L)
expect_equal(typeof(params$n_epochs), "integer")
expect_equal(params$n_epochs, 250L)

# Practical usage tests ------------------------------------------------------

# params_umap output can be used in list context
params <- params_umap(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "spectral",
    n_epochs = 500L
)

# Should be able to access all elements
knn <- params$knn_method
opt <- params$optimiser
ini <- params$init
epochs <- params$n_epochs
expect_true(TRUE) # If we got here without error, test passed

# Test params_tsne function ==================================================

# Basic functionality tests --------------------------------------------------

# params_tsne creates valid parameter list with defaults
params <- params_tsne()
expect_equal(typeof(params), "list")
expect_equal(names(params), c("knn_method", "dist_metric", "theta"))
expect_equal(params$knn_method, "hnsw")
expect_equal(params$dist_metric, "euclidean")
expect_equal(params$theta, 0.5)

# params_tsne accepts all valid knn_method values
params_hnsw <- params_tsne(knn_method = "hnsw")
expect_equal(params_hnsw$knn_method, "hnsw")

params_annoy <- params_tsne(knn_method = "annoy")
expect_equal(params_annoy$knn_method, "annoy")

# params_tsne accepts all valid dist_metric values
params_euclidean <- params_tsne(dist_metric = "euclidean")
expect_equal(params_euclidean$dist_metric, "euclidean")

params_cosine <- params_tsne(dist_metric = "cosine")
expect_equal(params_cosine$dist_metric, "cosine")

params_manhattan <- params_tsne(dist_metric = "manhattan")
expect_equal(params_manhattan$dist_metric, "manhattan")

# params_tsne handles custom theta
params <- params_tsne(theta = 0.3)
expect_equal(params$theta, 0.3)

# Parameter combination tests ------------------------------------------------

# params_tsne works with all parameters specified
params <- params_tsne(
    knn_method = "annoy",
    dist_metric = "cosine",
    theta = 0.7
)
expect_equal(params$knn_method, "annoy")
expect_equal(params$dist_metric, "cosine")
expect_equal(params$theta, 0.7)

# Validation tests -----------------------------------------------------------

# params_tsne validates knn_method parameter
expect_error(
    params_tsne(knn_method = "invalid"),
    pattern = "knn_method"
)

# params_tsne validates dist_metric parameter
expect_error(
    params_tsne(dist_metric = "invalid"),
    pattern = "dist_metric"
)

# params_tsne validates theta parameter
expect_error(
    params_tsne(theta = -0.1),
    pattern = "theta"
)

expect_error(
    params_tsne(theta = 1.5),
    pattern = "theta"
)

expect_error(
    params_tsne(theta = "0.5"),
    pattern = "theta"
)

# params_tsne accepts theta boundary values
params_zero <- params_tsne(theta = 0)
expect_equal(params_zero$theta, 0)

params_one <- params_tsne(theta = 1)
expect_equal(params_one$theta, 1)

# Practical usage tests ------------------------------------------------------

# params_tsne output can be used in list context
params <- params_tsne(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
)

# Should be able to access all elements
knn <- params$knn_method
dist <- params$dist_metric
th <- params$theta
expect_true(TRUE) # If we got here without error, test passed

# Integration tests ----------------------------------------------------------

# params_tsne creates appropriate params for different approximation types

# For FFT approximation
params_fft <- params_tsne(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
)
expect_equal(typeof(params_fft), "list")

# For Barnes-Hut approximation with different theta
params_bh <- params_tsne(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.3
)
expect_equal(params_bh$theta, 0.3)
