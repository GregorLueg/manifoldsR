# param wrappers ---------------------------------------------------------------

## nearest neighbours ----------------------------------------------------------

#' Wrapper function to generate nearest neighbour parameters
#'
#' @param dist_metric Character. The distance metric to use. Defaults to
#' `"cosine"`.
#' @param n_tree Integer. Number of trees for Annoy. Defaults to `50L`.
#' @param search_budget Integer or `NULL`. Search budget for Annoy. Defaults
#' to `NULL`.
#' @param m Integer. Number of bidirectional links for HNSW. Defaults to `16L`.
#' @param ef_construction Integer. Size of the dynamic candidate list during
#' HNSW construction. Defaults to `100L`.
#' @param ef_search Integer. Size of the dynamic candidate list during HNSW
#' search. Defaults to `100L`.
#' @param diversify_prob Float. Diversification probability for NN descent.
#' Defaults to `0.0`.
#' @param delta Float. Precision parameter for NN descent. Defaults to `0.001`.
#' @param ef_budget Integer or `NULL`. Effort budget for NN descent. Defaults
#' to `NULL`.
#' @param bt_budget Float. Budget for ball tree search. Defaults to `0.1`.
#'
#' @returns A list with the nearest neighbour parameters.
#'
#' @export
#'
#'
params_nn <- function(
  dist_metric = "cosine",
  n_tree = 50L,
  search_budget = NULL,
  m = 16L,
  ef_construction = 100L,
  ef_search = 100L,
  diversify_prob = 0.0,
  delta = 0.001,
  ef_budget = NULL,
  bt_budget = 0.1
) {
  # checks
  checkmate::assertChoice(dist_metric, c("cosine", "euclidean"))
  checkmate::qassert(n_tree, "I1")
  checkmate::assert(
    checkmate::checkNull(search_budget),
    checkmate::checkInt(search_budget)
  )
  checkmate::qassert(m, "I1")
  checkmate::qassert(ef_construction, "I1")
  checkmate::qassert(ef_search, "I1")
  checkmate::qassert(diversify_prob, "N1")
  checkmate::qassert(delta, "N1")
  checkmate::assert(
    checkmate::checkNull(ef_budget),
    checkmate::checkInt(ef_budget)
  )
  checkmate::qassert(bt_budget, "N1")

  # results
  list(
    dist_metric = dist_metric,
    n_tree = n_tree,
    search_budget = search_budget,
    m = m,
    ef_construction = ef_construction,
    ef_search = ef_search,
    diversify_prob = diversify_prob,
    delta = delta,
    ef_budget = ef_budget,
    bt_budget = bt_budget
  )
}

## umap ------------------------------------------------------------------------

#' Wrapper function to generate UMAP parameters
#'
#' @param local_connectivity Numeric. Number of nearest neighbours assumed to
#' be at distance zero. Defaults to `1.0`.
#' @param bandwidth Numeric. Convergence tolerance for smooth kNN distance
#' binary search. Defaults to `1e-5`.
#' @param mix_weight Numeric. Balance between fuzzy union and directed graph
#' during symmetrisation. Defaults to `1.0`.
#' @param lr Numeric. Learning rate. Defaults to `1.0`.
#' @param n_epochs Integer or `NULL`. Number of optimisation epochs. Defaults
#' to `NULL`, resolved downstream based on data size.
#' @param neg_sample_rate Integer. Number of negative samples per positive
#' sample. Defaults to `5L`.
#' @param gamma Numeric. Repulsion strength. Defaults to `1.0`.
#' @param optimiser Character. One of `"sgd"`, `"adam"`, or
#' `"adam_parallel"`. Defaults to `"adam_parallel"`.
#' @param init Character. Embedding initialisation method. One of `"spectral"`,
#' `"pca"`, or `"random"`. Defaults to `"spectral"`.
#' @param randomised Logical. Use randomised SVD for PCA initialisation.
#' Defaults to `FALSE`.
#'
#' @returns A list with the UMAP parameters.
#'
#' @export
params_umap <- function(
  local_connectivity = 1.0,
  bandwidth = 1e-5,
  mix_weight = 1.0,
  lr = 1.0,
  n_epochs = NULL,
  neg_sample_rate = 5L,
  gamma = 1.0,
  optimiser = "adam_parallel",
  init = "spectral",
  randomised = FALSE
) {
  checkmate::qassert(local_connectivity, "N1")
  checkmate::qassert(bandwidth, "N1")
  checkmate::qassert(mix_weight, "N1")
  checkmate::qassert(lr, "N1")
  checkmate::assert(
    checkmate::checkNull(n_epochs),
    checkmate::checkInt(n_epochs, lower = 1L)
  )
  checkmate::qassert(neg_sample_rate, "I1")
  checkmate::qassert(gamma, "N1")
  checkmate::assertChoice(optimiser, c("sgd", "adam", "adam_parallel"))
  checkmate::assertChoice(init, c("spectral", "pca", "random"))
  checkmate::qassert(randomised, "B1")

  list(
    local_connectivity = local_connectivity,
    bandwidth = bandwidth,
    mix_weight = mix_weight,
    lr = lr,
    n_epochs = n_epochs,
    neg_sample_rate = neg_sample_rate,
    gamma = gamma,
    optimiser = optimiser,
    init = init,
    randomised = randomised
  )
}

## tsne ------------------------------------------------------------------------

#' Wrapper function to generate t-SNE parameters
#'
#' @param lr Numeric. Learning rate. Defaults to `200.0`.
#' @param n_epochs Integer. Number of optimisation epochs. Defaults to `1000L`.
#' @param early_exag_iter Integer. Number of early exaggeration iterations.
#' Defaults to `250L`.
#' @param early_exag_factor Numeric. Early exaggeration factor. Defaults to
#' `12.0`.
#' @param theta Numeric. Barnes-Hut approximation angle. Lower values increase
#' accuracy at the cost of speed. Defaults to `0.5`.
#' @param n_interp_points Integer. Number of interpolation points per grid cell
#' for FFT acceleration. Defaults to `3L`.
#' @param init Character. Embedding initialisation method. One of `"spectral"`,
#' `"pca"`, or `"random"`. Defaults to `"pca"`.
#' @param randomised Logical. Use randomised SVD for PCA initialisation.
#' Defaults to `TRUE`.
#'
#' @returns A list with the t-SNE parameters.
#'
#' @export
params_tsne <- function(
  lr = 200.0,
  n_epochs = 1000L,
  early_exag_iter = 250L,
  early_exag_factor = 12.0,
  theta = 0.5,
  n_interp_points = 3L,
  init = "pca",
  randomised = TRUE
) {
  # checks
  checkmate::qassert(lr, "N1")
  checkmate::qassert(n_epochs, "I1[1,)")
  checkmate::qassert(early_exag_iter, "I1[1,)")
  checkmate::qassert(early_exag_factor, "N1")
  checkmate::qassert(theta, "N1[0,1]")
  checkmate::qassert(n_interp_points, "I1[1,)")
  checkmate::assertChoice(init, c("spectral", "pca", "random"))
  checkmate::qassert(randomised, "B1")

  # return
  list(
    lr = lr,
    n_epochs = n_epochs,
    early_exag_iter = early_exag_iter,
    early_exag_factor = early_exag_factor,
    theta = theta,
    n_interp_points = n_interp_points,
    init = init,
    randomised = randomised
  )
}
