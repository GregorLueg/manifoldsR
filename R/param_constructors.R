#' Construct UMAP parameters list
#'
#' @description Creates a validated named list of parameters to pass to the
#' `umap_params` argument of `rs_umap`.
#'
#' @param knn_method Character. K-nearest neighbors method to use. One of:
#' \itemize{
#'  \item "hnsw" - Hierarchical Navigable Small World (fast, approximate, default)
#'  \item "annoy" - Approximate Nearest Neighbors Oh Yeah
#' }
#' @param optimiser Character. Optimization method. One of:
#' \itemize{
#'  \item "adam_parallel" - Adam optimizer with parallelization (default)
#'  \item "sgd" - Stochastic Gradient Descent
#' }
#' @param init Character. Initialization method. One of:
#' \itemize{
#'  \item "spectral" - Spectral initialization (recommended for most cases, default)
#'  \item "pca" - PCA-based initialization
#' }
#' @param n_epochs Integer. Number of optimization epochs. Higher values may
#' improve quality but take longer. Default is 500.
#' @param randomised Logical. Whether to use randomized behavior. Optional,
#' defaults to NULL (not included in params).
#'
#' @return A named list containing the UMAP parameters ready to pass to
#' `rs_umap`.
#'
#' @examples
#' \dontrun{
#' # Standard parameters for fast, high-quality embedding
#' params <- params_umap(
#'   knn_method = "hnsw",
#'   optimiser = "adam_parallel",
#'   init = "spectral",
#'   n_epochs = 500
#' )
#'
#' # Use with rs_umap
#' embedding <- rs_umap(
#'   embd = data_matrix,
#'   n_dim = 2,
#'   min_dist = 0.1,
#'   spread = 1,
#'   k = 15,
#'   umap_params = params,
#'   seed = 42,
#'   verbose = TRUE
#' )
#' }
#'
#' @export
params_umap <- function(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "spectral",
    n_epochs = 500L,
    randomised = FALSE
) {
    # Validate parameters
    checkmate::assert_choice(knn_method, c("hnsw", "annoy"))
    checkmate::assert_choice(optimiser, c("adam_parallel", "sgd"))
    checkmate::assert_choice(init, c("spectral", "pca"))
    checkmate::assert_int(n_epochs, lower = 1)
    checkmate::qassert(randomised, "B1")

    # Build parameter list
    params <- list(
        knn_method = knn_method,
        optimiser = optimiser,
        init = init,
        n_epochs = as.integer(n_epochs),
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
#'   seed = 42,
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
    checkmate::assert_choice(knn_method, c("hnsw", "annoy"))
    checkmate::assert_choice(dist_metric, c("euclidean", "cosine", "manhattan"))

    checkmate::assert_number(theta, lower = 0, upper = 1)

    # Build parameter list
    params <- list(
        knn_method = knn_method,
        dist_metric = dist_metric,
        theta = theta
    )

    return(params)
}
