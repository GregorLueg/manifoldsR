#' Construct UMAP parameters list
#'
#' @description Creates a validated named list of parameters to pass to the
#' `umap_params` argument of `rs_umap`.
#'
#' @param knn_method Character. K-nearest neighbors method to use. One of:
#' \itemize{
#'  \item "annoy" - Approximate Nearest Neighbors Oh Yeah (default)
#'  \item "hnsw" - Hierarchical Navigable Small World (fast, approximate)
#'  \item "NNDescent" - Exact nearest neighbors using NNDescent algorithm
#' }
#' @param optimiser Character. Optimization method. One of:
#' \itemize{
#'  \item "sgd" - Stochastic Gradient Descent (default)
#'  \item "adam_parallel" - Adam optimiser with parallelization
#'  \item "adam" - Standard Adam optimiser without parallelization
#'  \item "random" - Generates Random noise
#' }
#' @param init Character. Initialization method. One of:
#' \itemize{
#'  \item "spectral" - Spectral initialization (recommended for most cases, default)
#'  \item "pca" - PCA-based initialization
#' }
#' @param n_epochs Integer or NULL. Number of optimization epochs. Higher values may
#' improve quality but take longer. If NULL (default), automatically determined:
#' 500 epochs for datasets <10,000 samples or when using "adam_parallel",
#' 200 epochs for datasets >=10,000 samples with "sgd" or "adam".
#' User-provided values override automatic detection.
#' @param randomised Logical. Whether to use randomized behavior. Default is FALSE.
#'
#' @return A named list containing the UMAP parameters ready to pass to
#' `rs_umap`.
#'
#' @examples
#' \dontrun{
#' # Standard parameters with automatic epoch detection
#' params <- params_umap(
#'   knn_method = "annoy",
#'   optimiser = "sgd",
#'   init = "spectral"
#' )
#'
#' # Override automatic epoch detection
#' params <- params_umap(
#'   knn_method = "annoy",
#'   optimiser = "sgd",
#'   n_epochs = 1000L
#' )
#'
#' # Use with rs_umap
#' embedding <- rs_umap(
#'   embd = data_matrix,
#'   n_dim = 2,
#'   min_dist = 0.1,
#'   spread = 1,
#'   k = 15L,
#'   umap_params = params,
#'   seed = 42L,
#'   verbose = TRUE
#' )
#' }
#'
#' @export
params_umap <- function(
    knn_method = "annoy",
    optimiser = "sgd",
    init = "spectral",
    # Annoy
    n_trees = 50L,
    search_budget = NULL,
    # NNDescent
    delta = 0.001,
    diversify_prob = 0.0,
    ef_budget = NULL,
    # HNSW
    m = 16L,
    ef_construction = 200L,
    ef_search = 100L,
    n_epochs = NULL,
    randomised = FALSE
) {
    # Validate parameters
    checkmate::assert_choice(knn_method, c("hnsw", "annoy", "NNDescent"))
    checkmate::assert_choice(
        optimiser,
        c("sgd", "adam_parallel", "adam", "random")
    )
    checkmate::assert_choice(init, c("spectral", "pca"))
    checkmate::qassert(n_trees, "I1[1,)")

    if (!is.null(search_budget)) {
        checkmate::qassert(search_budget, "I1[1,)")
        search_budget <- as.integer(search_budget)
    }
    checkmate::qassert(delta, "N1[0,)")
    checkmate::qassert(diversify_prob, "N1[0,1]")
    if (!is.null(ef_budget)) {
        checkmate::qassert(ef_budget, "I1[1,)")
        ef_budget <- as.integer(ef_budget)
    }
    checkmate::qassert(m, "I1[1,)")
    checkmate::qassert(ef_construction, "I1[1,)")
    checkmate::qassert(ef_search, "I1[1,)")

    if (!is.null(n_epochs)) {
        checkmate::qassert(n_epochs, "I1[1,)")
        n_epochs <- as.integer(n_epochs)
    }
    checkmate::qassert(randomised, "B1")

    # Build parameter list
    params <- list(
        knn_method = knn_method,
        optimiser = optimiser,
        init = init,
        n_epochs = n_epochs, # Can be NULL for automatic detection
        randomised = randomised
    )

    return(params)
}

#' Construct tSNE parameters list
#'
#' @description Creates a validated named list of parameters to pass to the
#' `tsne_params` argument of `rs_tsne`.
#'
#' @param knn_method Character. K-nearest neighbors method to use. One of:
#' \itemize{
#'  \item "hnsw" - Hierarchical Navigable Small World (fast, approximate, default)
#'  \item "annoy" - Approximate Nearest Neighbors Oh Yeah
#'  \item "NNDescent" - Exact nearest neighbors using NNDescent algorithm
#' }
#' @param dist_metric Character. Distance metric to use. One of:
#' \itemize{
#'  \item "euclidean" - Euclidean distance (recommended for most cases, default)
#'  \item "cosine" - Cosine distance
#'  \item "manhattan" - Manhattan distance
#' }
#' @param theta Numeric. Theta parameter for Barnes-Hut approximation.
#' Controls the speed-accuracy tradeoff. Lower values are more accurate but
#' slower. Typical range is 0.1 to 1.0. Default is 0.5.
#'
#' @return A named list containing the tSNE parameters ready to pass to
#' `rs_tsne`.
#'
#' @examples
#' \dontrun{
#' # Standard parameters for tSNE
#' params <- params_tsne()
#'
#' # Customize parameters
#' params <- params_tsne(
#'   knn_method = "hnsw",
#'   dist_metric = "euclidean",
#'   theta = 0.3
#' )
#'
#' # Use with rs_tsne
#' embedding <- rs_tsne(
#'   embd = data_matrix,
#'   n_dim = 2,
#'   perplexity = 50,
#'   approx_type = "bh",
#'   tsne_params = params,  # Use the constructed params
#'   seed = 42L,
#'   verbose = TRUE
#' )
#' }
#'
#' @export
params_tsne <- function(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
) {
    # Validate parameters
    checkmate::assert_choice(knn_method, c("hnsw", "annoy", "NNDescent"))
    checkmate::assert_choice(dist_metric, c("euclidean", "cosine", "manhattan"))

    checkmate::qassert(theta, "N1[0,1]") # Theta should be between 0 and 1

    # Build parameter list
    params <- list(
        knn_method = knn_method,
        dist_metric = dist_metric,
        theta = theta
    )

    return(params)
}
