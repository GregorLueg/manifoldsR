#' UMAP: Uniform Manifold Approximation and Projection
#'
#' @description Performs UMAP dimensionality reduction on the input data.
#' This function provides a user-friendly interface with input validation
#' before calling the Rust implementation.
#'
#' @param data Numerical matrix or data frame. The data to embed.
#' Should be of dimensions samples x features. Will be coerced to a matrix.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Default is 2.
#' @param min_dist Numeric. Minimum distance between points in the embedding.
#' Controls how tightly points are packed. Smaller values result in more
#' clustered embeddings. Must be >= 0. Default is 0.1.
#' @param spread Numeric. Effective scale of embedded points. Determines the
#' scale at which embedded points will be spread out. Default is 1.0.
#' @param k Integer. Number of nearest neighbors to consider for
#' manifold approximation. Larger values result in more global structure being
#' preserved. Default is 15.
#' @param params Named list. Advanced UMAP parameters created by
#' \code{\link{params_umap}}. Default uses standard settings.
#' @param seed Integer. Random seed for reproducibility. Default is NULL
#' (random seed).
#' @param verbose Logical. Whether to print progress messages. Default is FALSE.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the UMAP embedding.
#'
#' @examples
#' \dontrun{
#' # Basic usage with defaults
#' embedding <- umap(iris[, 1:4])
#'
#' # Customize main parameters
#' embedding <- umap(
#'   data = iris[, 1:4],
#'   n_dim = 3,
#'   k = 30,
#'   min_dist = 0.3,
#'   seed = 42
#' )
#'
#' # Customize advanced parameters via params
#' custom_params <- params_umap(
#'   knn_method = "annoy",
#'   optimiser = "sgd",
#'   n_epochs = 1000
#' )
#' embedding <- umap(
#'   data = iris[, 1:4],
#'   params = custom_params,
#'   verbose = TRUE
#' )
#' }
#'
#' @export
umap <- function(
    data,
    n_dim = 2L,
    min_dist = 0.1,
    spread = 1.0,
    k = 15L,
    params = params_umap(),
    seed = NULL,
    verbose = FALSE
) {
    # Input validation
    if (is.data.frame(data)) {
        data <- as.matrix(data)
    }

    checkmate::assert_matrix(
        data,
        mode = "numeric",
        any.missing = FALSE,
        min.rows = 2,
        min.cols = 1
    )

    checkmate::assert_int(n_dim, lower = 1, upper = ncol(data))
    checkmate::qassert(min_dist, "N1[0,)")
    checkmate::qassert(spread, "N1[0,)")
    checkmate::qassert(k, "I1[2,)")
    checkmate::assert_list(params, names = "unique")
    checkmate::qassert(verbose, "B1")

    # Handle seed
    if (is.null(seed)) {
        seed <- as.integer(sample.int(.Machine$integer.max, 1))
    } else {
        checkmate::assert_int(seed)
        seed <- as.integer(seed)
    }

    # Ensure integers are proper integer type
    n_dim <- as.integer(n_dim)
    k <- as.integer(k)

    # Determine n_epochs if not specified
    if (is.null(params$n_epochs)) {
        n_samples <- nrow(data)
        if (params$optimiser == "adam_parallel" || n_samples < 10000) {
            params$n_epochs <- 500L
            if (verbose) {
                message("Using n_epochs = 500 (dataset <10k samples or adam_parallel optimizer)")
            }
        } else {
            params$n_epochs <- 200L
            if (verbose) {
                message("Using n_epochs = 200 (dataset >=10k samples with sgd/adam optimizer)")
            }
        }
    } else {
        params$n_epochs <- as.integer(params$n_epochs)
    }

    # Call Rust implementation
    tryCatch(
        {
            result <- rs_umap(
                embd = data,
                n_dim = n_dim,
                min_dist = min_dist,
                spread = spread,
                k = k,
                umap_params = params,
                seed = seed,
                verbose = verbose
            )
            return(result)
        },
        error = function(e) {
            stop("UMAP computation failed: ", e$message, call. = FALSE)
        }
    )
}


#' t-SNE: t-Distributed Stochastic Neighbor Embedding
#'
#' @description Performs t-SNE dimensionality reduction on the input data.
#' This function provides a user-friendly interface with input validation
#' before calling the Rust implementation.
#'
#' @param data Numerical matrix or data frame. The data to embed.
#' Should be of dimensions samples x features. Will be coerced to a matrix.
#' @param n_dim Integer. Number of dimensions in the embedding space.
#' Currently only 2 is supported. Default is 2.
#' @param perplexity Numeric. The perplexity parameter. Related to the number
#' of nearest neighbors used in manifold learning. Typical values are between
#' 5 and 50. Default is 30.
#' @param approx_type Character. Approximation method for computing repulsive
#' forces. One of:
#' \itemize{
#'  \item "bh" - Barnes-Hut approximation (recommended for most datasets)
#'  \item "fft" - FFT-accelerated interpolation (faster for large datasets)
#' }
#' Default is "bh".
#' @param params Named list. Advanced t-SNE parameters created by
#' \code{\link{params_tsne}}. Default uses standard settings.
#' @param seed Integer. Random seed for reproducibility. Default is NULL
#' (random seed).
#' @param verbose Logical. Whether to print progress messages. Default is FALSE.
#'
#' @return A numerical matrix with dimensions samples x n_dim containing
#' the t-SNE embedding.
#'
#' @examples
#' \dontrun{
#' # Basic usage with defaults
#' embedding <- tsne(iris[, 1:4])
#'
#' # Customize main parameters
#' embedding <- tsne(
#'   data = iris[, 1:4],
#'   perplexity = 50,
#'   approx_type = "fft",
#'   seed = 42
#' )
#'
#' # Customize advanced parameters via params
#' custom_params <- params_tsne(
#'   knn_method = "annoy",
#'   dist_metric = "cosine",
#'   theta = 0.3
#' )
#' embedding <- tsne(
#'   data = iris[, 1:4],
#'   params = custom_params,
#'   verbose = TRUE
#' )
#' }
#'
#' @export
tsne <- function(
    data,
    n_dim = 2L,
    perplexity = 30L,
    approx_type = "bh",
    params = params_tsne(),
    seed = NULL,
    verbose = FALSE
) {
    # Input validation
    if (is.data.frame(data)) {
        data <- as.matrix(data)
    }

    checkmate::assert_matrix(
        data,
        mode = "numeric",
        any.missing = FALSE,
        min.rows = 2,
        min.cols = 1
    )
    checkmate::qassert(n_dim, "I1[2,2]") # Only 2D supported
    checkmate::qassert(
        perplexity,
        "I1[1,)"
    )
    checkmate::assert_choice(approx_type, c("bh", "fft"))
    checkmate::assert_list(params, names = "unique")
    checkmate::qassert(verbose, "B1")

    # Handle seed
    if (is.null(seed)) {
        seed <- as.integer(sample.int(.Machine$integer.max, 1))
    } else {
        checkmate::assert_int(seed)
        seed <- as.integer(seed)
    }

    # Ensure integers are proper integer type
    n_dim <- as.integer(n_dim)
    perplexity <- as.integer(perplexity)

    # Call Rust implementation
    tryCatch(
        {
            result <- rs_tsne(
                embd = data,
                n_dim = n_dim,
                perplexity = perplexity,
                approx_type = approx_type,
                tsne_params = params,
                seed = seed,
                verbose = verbose
            )
            return(result)
        },
        error = function(e) {
            stop("t-SNE computation failed: ", e$message, call. = FALSE)
        }
    )
}
