# generate nearest neighbour graphs --------------------------------------------

#' Generate a k-nearest neighbour graph.
#'
#' @description
#' This function generates a kNN graph based on a given numeric matrix. Four
#' different algorithms are implemented with different speed and accuracy
#' trade-offs:
#' \itemize{
#'   \item `"hnsw"` - Hierarchical Navigable Small Worlds vector search with
#'   slower index generation (which ammortises on larger data sets) and high
#'   precision.
#'   \item `"annoy"` - Approximate Nearest Neighbours Oh Yeah algorithm, faster
#'   to index but querying on large data sets can be slow.
#'   \item `"nndescent"` - Rust-based implementation of the PyNNDescent
#'   algorithm, a good all-rounder that performs well on very large data sets.
#'   \item `"balltree"` - Ball tree structure for exact search with a
#'   configurable budget.
#'   \item `"ivf"` - Inverted file index that leverages k-means clustering
#'   and probing a few of the clusters.
#'   \item `"exhaustive"` - Exact nearest neighbour search.
#' }
#'
#' @param data Numeric matrix. The embedding or feature matrix to compute
#' neighbours on. Rows are observations, columns are features.
#' @param k Integer. The number of nearest neighbours to compute.
#' @param knn_method Character. The algorithm to use for nearest neighbour
#' search. One of
#' `c("hnsw", "annoy", "nndescent", "balltree", "ivf", "exhaustive")`. Defaults
#' to `"hnsw"`.
#' @param nn_params List. Output of [manifoldsR::params_nn()]. Controls
#' algorithm-specific parameters.
#' @param seed Integer. For reproducibility. Defaults to `42L`.
#' @param .verbose Boolean. Controls verbosity.
#'
#' @return A nearest neighbours class object with 1-indexed neighbour indices
#' and distances.
#'
#' @export
generate_knn_graph <- function(
  data,
  k,
  knn_method = c("hnsw", "annoy", "nndescent", "balltree", "exhaustive", "ivf"),
  nn_params = params_nn(),
  seed = 42L,
  .verbose = TRUE
) {
  knn_method <- match.arg(knn_method)

  # checks
  checkmate::assertMatrix(data, mode = "numeric")
  checkmate::qassert(k, "I1")
  checkmate::assertChoice(
    knn_method,
    c("hnsw", "annoy", "nndescent", "balltree", "exhaustive", "ivf")
  )
  assertNnParams(nn_params)
  checkmate::qassert(seed, "I1")
  checkmate::qassert(.verbose, "B1")

  # rust
  nn_data <- rs_approx_nearest_neighbours(
    data = data,
    k = k,
    ann_method = knn_method,
    ann_params = nn_params,
    seed = seed,
    verbose = .verbose
  )

  res <- with(
    nn_data,
    new_nearest_neighbour(
      indices = indices + 1L, # 1-index
      dist = dist,
      k = as.integer(k),
      n = as.integer(n)
    )
  )

  res
}
