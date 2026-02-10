#' Generate synthetic data for manifold learning
#'
#' @description A unified wrapper function for generating various types of
#' synthetic data to test manifold learning techniques.
#'
#' @param type Character. Type of synthetic data to generate. One of:
#' \itemize{
#'  \item "swiss_role" - Swiss role manifold
#'  \item "clusters" - Clustered data
#'  \item "tree" - Tree-like/branching data
#' }
#' @param n_samples Integer. Number of data points to generate.
#' @param dim Integer. Dimensionality of the data (used for "clusters" and "tree").
#' @param n_clusters Integer. Number of clusters (used for "clusters" type). Default is 3.
#' @param n_branches Integer. Number of branches (used for "tree" type). Default is 3.
#' @param noise Numeric. Amount of noise to add (used for "swiss_role" and "tree"). must be any non 0 positive value. Default is 0.1.
#' @param seed Integer. Random seed for reproducibility. Default is NULL (no seed).
#'
#' @return A list with the following elements:
#' \itemize{
#'  \item data - Numerical matrix with the generated data
#'  \item membership - Vector of cluster/branch assignments (NULL for swiss_role)
#' }
#'
#' @examples
#' \dontrun{
#' # Generate Swiss role data
#' swiss <- rs_synthetic_data("swiss_role", n_samples = 1000, noise = 0.1, seed = 42)
#'
#' # Generate clustered data
#' clusters <- rs_synthetic_data("clusters", n_samples = 500, dim = 10,
#'                               n_clusters = 5, seed = 42)
#'
#' # Generate tree-like data
#' tree <- rs_synthetic_data("tree", n_samples = 800, dim = 10,
#'                           n_branches = 4, noise = 0.05, seed = 42)
#' }
#'
#' @export
rs_synthetic_data <- function(
    type = c("swiss_role", "clusters", "tree"),
    n_samples,
    dim = 2L,
    n_clusters = 3L,
    n_branches = 3L,
    noise = 0.1,
    seed = 42L
) {
    type <- match.arg(type)

    # parameter checks
    checkmate::qassert(n_samples, "X1(0,)")
    checkmate::qassert(dim, "X1(1,)")
    checkmate::qassert(n_clusters, "X1(1,)")
    checkmate::qassert(n_branches, "X1(1,)")
    checkmate::qassert(noise, "R1(0,)")
    checkmate::qassert(seed, "X1(1,)")

    result <- switch(
        type,
        swiss_role = {
            data <- rs_data_swiss_role(
                n_samples = n_samples,
                noise = noise,
                seed = seed
            )
            list(data = data, membership = NULL)
        },
        clusters = {
            result <- rs_data_clusters(
                n_samples = n_samples,
                dim = dim,
                n_clusters = n_clusters,
                seed = seed
            )
            list(data = result$data, membership = result$clusters)
        },
        tree = {
            result <- rs_data_tree(
                n_samples = n_samples,
                dim = dim,
                n_branches = n_branches,
                noise = noise,
                seed = seed
            )
            list(data = result$data, membership = result$clusters)
        }
    )

    return(result)
}
