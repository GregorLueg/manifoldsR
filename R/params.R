# param wrappers ---------------------------------------------------------------

## nearest neighbours ----------------------------------------------------------

#' Wrapper function to generate nearest neighbour parameters
#'
#' @param dist_metric Character. The distance metric to use. Defaults to
#' `"euclidean"`.
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
#' @param n_list Optional integer. Number of clusters to use for IVF. If `NULL`,
#' will default to `sqrt(n)`.
#' @param n_probes Optional integer. Number of clusters to probe for IVF. If
#' `NULL`, will default to `sqrt(n_list)`.
#'
#' @returns A list with the nearest neighbour parameters.
#'
#' @export
#'
#'
params_nn <- function(
  dist_metric = c("euclidean", "cosine"),
  n_tree = 50L,
  search_budget = NULL,
  m = 16L,
  ef_construction = 100L,
  ef_search = 100L,
  diversify_prob = 0.0,
  delta = 0.001,
  ef_budget = NULL,
  bt_budget = 0.1,
  n_list = NULL,
  n_probes = NULL
) {
  dist_metric <- match.arg(dist_metric)

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
  checkmate::qassert(ef_budget, c("I1", "0"))
  checkmate::qassert(bt_budget, "N1")
  checkmate::qassert(n_list, c("I1", "0"))
  checkmate::qassert(n_probes, c("I1", "0"))

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
    bt_budget = bt_budget,
    n_list = n_list,
    n_probes = n_probes
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
#' Defaults to `TRUE`.
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
  optimiser = c("adam_parallel", "sgd", "adam"),
  init = c("spectral", "pca", "random"),
  randomised = TRUE
) {
  optimiser <- match.arg(optimiser)
  init <- match.arg(init)

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
#' @param lr Optional numeric. Learning rate. If `NULL` (the default), the Rust
#' backend sets it to `max((n_samples / 12), 200)`, following the N-dependent
#' heuristic of Belkina et al. (2019).
#' @param n_epochs Integer. Number of optimisation epochs. Defaults to `1000L`.
#' @param early_exag_iter Integer. Number of early exaggeration iterations.
#' Defaults to `250L`.
#' @param early_exag_factor Numeric. Early exaggeration factor. Defaults to
#' `12.0`.
#' @param late_exag_factor Optional numeric. If you wish to also use late
#' exaggerations. Can be useful on large data sets (set it to `2.0` to `4.0`).
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
#'
#' @references Belkina, et al., Nat. Commun., 2019
params_tsne <- function(
  lr = NULL,
  n_epochs = 1000L,
  early_exag_iter = 250L,
  early_exag_factor = 12.0,
  late_exag_factor = NULL,
  theta = 0.5,
  n_interp_points = 3L,
  init = c("pca", "spectral", "random"),
  randomised = TRUE
) {
  init <- match.arg(init)

  # checks
  checkmate::qassert(lr, c("N1", "0"))
  checkmate::qassert(n_epochs, "I1[1,)")
  checkmate::qassert(early_exag_iter, "I1[1,)")
  checkmate::qassert(early_exag_factor, "N1")
  checkmate::qassert(late_exag_factor, c("N1", "0"))
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
    late_exag_factor = late_exag_factor,
    theta = theta,
    n_interp_points = n_interp_points,
    init = init,
    randomised = randomised
  )
}

## density-preserving ----------------------------------------------------------

#' Wrapper function to generate densMAP parameters
#'
#' @description
#' The density-preservation knobs on top of the usual UMAP parameters. densMAP
#' adds `-lambda * Corr(log Ro, log Re)` to the UMAP loss, where `Ro` is the
#' local radius in the input space and `Re` the matching radius in the
#' embedding. Setting `lambda` to `0` recovers plain UMAP.
#'
#' @param lambda Numeric. Weight of the density term. `0` disables it. Defaults
#' to `2.0`, the densMAP reference value.
#' @param frac Numeric between 0 and 1. Fraction of the total epochs, at the
#' end of the run, over which the density term is active. Defaults to `0.3`.
#' @param var_shift Numeric. Additive shift on the variance of the embedding
#' log-radii. Defaults to `0.1`.
#'
#' @returns A list with the density-preservation parameters.
#'
#' @export
#'
#' @references Narayan, Berger & Cho, Nat. Biotechnol., 2021
params_densmap <- function(
  lambda = 2.0,
  frac = 0.3,
  var_shift = 0.1
) {
  # checks
  checkmate::qassert(lambda, "N1[0,)")
  checkmate::qassert(frac, "N1[0,1]")
  checkmate::qassert(var_shift, "N1[0,)")

  # return
  list(
    lambda = lambda,
    frac = frac,
    var_shift = var_shift
  )
}

#' Wrapper function to generate den-SNE parameters
#'
#' @description
#' The density-preservation knobs on top of the usual t-SNE parameters. den-SNE
#' adds `-lambda * Corr(log Ro, log Re)` to the t-SNE loss, where `Ro` is the
#' local radius in the input space and `Re` the matching radius in the
#' embedding. Setting `lambda` to `0` recovers plain t-SNE. The default weight
#' is twenty times smaller than the densMAP one, matching the reference
#' implementations.
#'
#' @param lambda Numeric. Weight of the density term. `0` disables it. Defaults
#' to `0.5`, higher than the den-SNE reference value (original: `0.1`).
#' @param frac Numeric between 0 and 1. Fraction of the total epochs, at the
#' end of the run, over which the density term is active. Defaults to `0.3`.
#' @param var_shift Numeric. Additive shift on the variance of the embedding
#' log-radii. Defaults to `0.1`.
#'
#' @returns A list with the density-preservation parameters.
#'
#' @export
#'
#' @references Narayan, Berger & Cho, Nat. Biotechnol., 2021
params_densne <- function(
  lambda = 0.5,
  frac = 0.3,
  var_shift = 0.1
) {
  # checks
  checkmate::qassert(lambda, "N1[0,)")
  checkmate::qassert(frac, "N1[0,1]")
  checkmate::qassert(var_shift, "N1[0,)")

  # return
  list(
    lambda = lambda,
    frac = frac,
    var_shift = var_shift
  )
}

## phate -----------------------------------------------------------------------

#' Wrapper function to generate PHATE parameters
#'
#' @param decay Numeric. Alpha decay parameter controlling the kernel
#' bandwidth. Higher values create sharper transitions. Defaults to `40.0`.
#' @param bandwidth_scale Numeric or `NULL`. Scaling factor applied to the
#' kernel bandwidth. When `NULL`, the library selects a sensible default.
#' Defaults to `NULL`.
#' @param t_max Integer. Maximum diffusion time considered during automatic
#' selection via Von Neumann entropy knee point detection. Defaults to `100L`.
#' @param t_custom Integer or `NULL`. Fixed diffusion time. When set, overrides
#' automatic time selection. Defaults to `NULL`.
#' @param gamma Numeric. Informational distance parameter for the diffusion
#' potential. Defaults to `1.0`.
#' @param n_landmarks Integer or `NULL`. Number of landmarks for compressed
#' diffusion. When `NULL`, the full N x N diffusion operator is used.
#' Defaults to `2048L`.
#' @param landmark_method Character. Method used to select landmarks. One of
#' `"spectral"`, `"random"`, or `"density"`. Defaults to `"spectral"`.
#' @param n_svd Integer or `NULL`. Number of SVD components used in landmark
#' construction. When `NULL`, the library selects a sensible default. Defaults
#' to `NULL`.
#' @param mds_method Character. MDS algorithm used for the final embedding.
#' One of `"sgd_dense"` or `"classic"`. Defaults to `"sgd_dense"`.
#' @param graph_symmetry Character. Method used to symmetrise the affinity
#' graph. One of `"additive"`, `"multiplicative"`, `"mnn"`, or `"none"`.
#' Defaults to `"additive"`.
#'
#' @returns A list with the PHATE parameters.
#'
#' @export
params_phate <- function(
  decay = 40.0,
  bandwidth_scale = NULL,
  t_max = 100L,
  t_custom = NULL,
  gamma = 1.0,
  n_landmarks = 2024L,
  landmark_method = "spectral",
  n_svd = NULL,
  mds_method = "sgd_dense",
  graph_symmetry = "additive"
) {
  checkmate::qassert(decay, "N1(0,)")
  checkmate::assert(
    checkmate::testNull(bandwidth_scale),
    checkmate::qtest(bandwidth_scale, "N1(0,)")
  )
  checkmate::qassert(t_max, "I1[1,)")
  checkmate::assert(
    checkmate::testNull(t_custom),
    checkmate::qtest(t_custom, "I1[1,)")
  )
  checkmate::qassert(gamma, "N1")
  checkmate::assert(
    checkmate::testNull(n_landmarks),
    checkmate::qtest(n_landmarks, "I1[1,)")
  )
  checkmate::assertChoice(landmark_method, c("spectral", "random", "density"))
  checkmate::assert(
    checkmate::testNull(n_svd),
    checkmate::qtest(n_svd, "I1[1,)")
  )
  checkmate::assertChoice(mds_method, c("sgd_dense", "classic"))
  checkmate::assertChoice(
    graph_symmetry,
    c("additive", "multiplicative", "mnn", "none")
  )

  list(
    decay = decay,
    bandwidth_scale = bandwidth_scale,
    t_max = as.integer(t_max),
    t_custom = if (!is.null(t_custom)) as.integer(t_custom) else NULL,
    gamma = gamma,
    n_landmarks = if (!is.null(n_landmarks)) as.integer(n_landmarks) else NULL,
    landmark_method = landmark_method,
    n_svd = if (!is.null(n_svd)) as.integer(n_svd) else NULL,
    mds_method = mds_method,
    graph_symmetry = graph_symmetry
  )
}

## pacmap ----------------------------------------------------------------------

#' Wrapper function to generate PaCMAP parameters
#'
#' @param n_near Integer. Near pairs per point (attractive). Defaults to `10L`.
#' @param n_mid_near Integer. Mid-near pairs per point. Defaults to `5L`.
#' @param n_further Integer. Further (random) pairs per point. Defaults to
#' `20L`.
#' @param mn_candidate_start Integer. Start index into kNN list for mid-near
#' candidate window. Defaults to `4L`.
#' @param mn_candidate_end Integer. End index into kNN list for mid-near
#' candidate window. Also determines the kNN search size. Defaults to `50L`.
#' @param init Character. Embedding initialisation. One of `"pca"` or
#' `"random"`. Defaults to `"pca"`.
#' @param optimiser Character. One of `"adam"` or `"adam_parallel"`. Defaults
#' to `"adam_parallel"`.
#' @param lr Numeric. Adam learning rate. Defaults to `1.0`.
#' @param n_epochs Integer or `NULL`. Total optimisation epochs. Defaults to
#' `NULL`, resolved downstream to `450`.
#' @param beta1 Numeric. Adam first moment decay. Defaults to `0.9`.
#' @param beta2 Numeric. Adam second moment decay. Defaults to `0.999`.
#' @param eps Numeric. Adam numerical stability constant. Defaults to `1e-7`.
#' @param phase1_end Integer or `NULL`. Epoch at which phase 1 ends. Defaults
#' to `NULL`, resolved downstream to `100`.
#' @param phase2_end Integer or `NULL`. Epoch at which phase 2 ends. Defaults
#' to `NULL`, resolved downstream to `200`.
#'
#' @returns A list with the PaCMAP parameters.
#'
#' @export
params_pacmap <- function(
  n_near = 10L,
  n_mid_near = 5L,
  n_further = 20L,
  mn_candidate_start = 4L,
  mn_candidate_end = 50L,
  init = "pca",
  optimiser = "adam_parallel",
  lr = 1.0,
  n_epochs = NULL,
  beta1 = 0.9,
  beta2 = 0.999,
  eps = 1e-7,
  phase1_end = NULL,
  phase2_end = NULL
) {
  checkmate::qassert(n_near, "I1")
  checkmate::qassert(n_mid_near, "I1")
  checkmate::qassert(n_further, "I1")
  checkmate::qassert(mn_candidate_start, "I1")
  checkmate::qassert(mn_candidate_end, "I1")
  checkmate::assertChoice(init, c("pca", "random"))
  checkmate::assertChoice(optimiser, c("adam", "adam_parallel"))
  checkmate::qassert(lr, "N1")
  checkmate::assert(
    checkmate::checkNull(n_epochs),
    checkmate::checkInt(n_epochs, lower = 1L)
  )
  checkmate::qassert(beta1, "N1")
  checkmate::qassert(beta2, "N1")
  checkmate::qassert(eps, "N1")
  checkmate::assert(
    checkmate::checkNull(phase1_end),
    checkmate::checkInt(phase1_end, lower = 1L)
  )
  checkmate::assert(
    checkmate::checkNull(phase2_end),
    checkmate::checkInt(phase2_end, lower = 1L)
  )

  list(
    n_near = n_near,
    n_mid_near = n_mid_near,
    n_further = n_further,
    mn_candidate_start = mn_candidate_start,
    mn_candidate_end = mn_candidate_end,
    init = init,
    optimiser = optimiser,
    lr = lr,
    n_epochs = n_epochs,
    beta1 = beta1,
    beta2 = beta2,
    eps = eps,
    phase1_end = phase1_end,
    phase2_end = phase2_end
  )
}

## diffusion maps --------------------------------------------------------------

#' Wrapper function to generate diffusion maps parameters
#'
#' @param bandwidth_scale Numeric. Multiplicative factor applied to the
#' adaptive kernel bandwidth. Defaults to `1.0`.
#' @param thresh Numeric. Sparsity threshold applied to kernel entries.
#' Defaults to `1e-4`.
#' @param graph_symmetry Character. Method used to symmetrise the affinity
#' graph. One of `"additive"`, `"multiplicative"`, `"mnn"`, or `"none"`.
#' Defaults to `"additive"`.
#' @param alpha_norm Numeric. Anisotropic density-correction exponent in
#' `[0, 1]`. `0` gives the normalised graph Laplacian, `0.5` the
#' Fokker-Planck operator, `1` the Laplace-Beltrami operator. Defaults to
#' `1.0`.
#' @param t_max Integer. Maximum diffusion time considered during automatic
#' selection via Von Neumann entropy knee point detection. Defaults to
#' `100L`.
#' @param t_custom Integer or `NULL`. Fixed diffusion time. When set,
#' overrides automatic time selection. Defaults to `NULL`.
#' @param n_landmarks Integer or `NULL`. Number of landmarks for compressed
#' diffusion. When `NULL`, the full N x N diffusion operator is used.
#' Defaults to `2048L`.
#' @param landmark_method Character. Method used to select landmarks. One of
#' `"spectral"`, `"random"`, or `"density"`. Defaults to `"spectral"`.
#' @param n_svd Integer or `NULL`. Number of SVD components used in landmark
#' construction. When `NULL`, the library selects a sensible default.
#' Defaults to `NULL`.
#'
#' @returns A list with the diffusion maps parameters.
#'
#' @export
params_diffusion_maps <- function(
  bandwidth_scale = 1.0,
  thresh = 1e-4,
  graph_symmetry = "additive",
  alpha_norm = 1.0,
  t_max = 100L,
  t_custom = NULL,
  n_landmarks = 2048L,
  landmark_method = "spectral",
  n_svd = NULL
) {
  checkmate::qassert(bandwidth_scale, "N1(0,)")
  checkmate::qassert(thresh, "N1[0,)")
  checkmate::assertChoice(
    graph_symmetry,
    c("additive", "multiplicative", "mnn", "none")
  )
  checkmate::qassert(alpha_norm, "N1[0,1]")
  checkmate::qassert(t_max, "I1[1,)")
  checkmate::assert(
    checkmate::testNull(t_custom),
    checkmate::qtest(t_custom, "I1[1,)")
  )
  checkmate::assert(
    checkmate::testNull(n_landmarks),
    checkmate::qtest(n_landmarks, "I1[1,)")
  )
  checkmate::assertChoice(landmark_method, c("spectral", "random", "density"))
  checkmate::assert(
    checkmate::testNull(n_svd),
    checkmate::qtest(n_svd, "I1[1,)")
  )

  list(
    bandwidth_scale = bandwidth_scale,
    thresh = thresh,
    graph_symmetry = graph_symmetry,
    alpha_norm = alpha_norm,
    t_max = as.integer(t_max),
    t_custom = if (!is.null(t_custom)) as.integer(t_custom) else NULL,
    n_landmarks = if (!is.null(n_landmarks)) as.integer(n_landmarks) else NULL,
    landmark_method = landmark_method,
    n_svd = if (!is.null(n_svd)) as.integer(n_svd) else NULL
  )
}

## synthetic data --------------------------------------------------------------

### swiss roles ----------------------------------------------------------------

#' Parameters for swiss roll data generation
#'
#' @param noise Numeric. Amount of noise to add. Must be a positive non-zero
#' value. Defaults to `0.1`.
#'
#' @return A list of parameters for use with [manifold_synthetic_data()].
#'
#' @export
params_swiss_role <- function(noise = 0.1) {
  # checks
  checkmate::qassert(noise, "N1(0,)")
  # return
  list(noise = noise)
}

#' Parameters for swiss roll data generation
#'
#' @param noise Numeric. Amount of noise to add. Must be a positive non-zero
#' value. Defaults to `0.1`.
#' @param bias Numeric. The sampling bias across the manifold. Defaults to
#' `2.5`.
#'
#' @return A list of parameters for use with [manifold_synthetic_data()].
#'
#' @export
params_swiss_role_biased <- function(noise = 0.1, bias = 2.5) {
  # checks
  checkmate::qassert(noise, "N1(0,)")
  checkmate::qassert(bias, "N1(0,)")

  # return
  list(noise = noise, bias = bias)
}

### clustered data -------------------------------------------------------------

#' Parameters for clustered data generation
#'
#' @param n_clusters Integer. Number of clusters to generate. Defaults to
#' `15L`.
#'
#' @return A list of parameters for use with [manifold_synthetic_data()].
#'
#' @export
params_clusters <- function(n_clusters = 15L) {
  # checks
  checkmate::qassert(n_clusters, "I1(1,)")
  # return
  list(n_clusters = n_clusters)
}

#' Parameters for hierarchical cluster data generation
#'
#' @param n_supergroups Integer. Number of top-level groups. Defaults to `3L`.
#' @param n_subclusts Integer. Number of subclusters per supergroup. Defaults
#' to `3L`.
#' @param supergroup_spread Numeric. Spread of supergroup centres in the
#' ambient space. Defaults to `15.0`.
#' @param subcluster_spread Numeric. Spread of subcluster centres around their
#' supergroup centre. Defaults to `2.0`.
#' @param point_std Numeric. Within-subcluster Gaussian noise. Defaults to
#' `0.4`.
#'
#' @return A list of parameters for use with [manifold_synthetic_data()].
#'
#' @export
params_hierarchical <- function(
  n_supergroups = 3L,
  n_subclusts = 3L,
  supergroup_spread = 15.0,
  subcluster_spread = 2.0,
  point_std = 0.4
) {
  # checks
  checkmate::qassert(n_supergroups, "I1(1,)")
  checkmate::qassert(n_subclusts, "I1(1,)")
  checkmate::qassert(supergroup_spread, "N1(0,)")
  checkmate::qassert(subcluster_spread, "N1(0,)")
  checkmate::qassert(point_std, "N1(0,)")

  # return
  list(
    n_supergroups = n_supergroups,
    n_subclusts = n_subclusts,
    supergroup_spread = supergroup_spread,
    subcluster_spread = subcluster_spread,
    point_std = point_std
  )
}

### trajectory -----------------------------------------------------------------

#' Parameters for trajectory data generation
#'
#' @param topology Character. One of `c("bifurcation", "linear",
#' "combination")`. Ignored if `cell_trajectories` is not `NULL`. Defaults to
#' `"bifurcation"`.
#' @param cell_trajectories Optional list. Named list with three equal-length
#' vectors: `parent` (integer, `NA` for root, zero-indexed), `split_at`
#' (numeric, fraction along parent where branch starts), and `length` (numeric,
#' length of the branch). If `NULL`, `topology` is used instead. Defaults to
#' `NULL`.
#' @param noise Numeric. Amount of noise to add. Must be a positive non-zero
#' value. Defaults to `0.1`.
#'
#' @return A list of parameters for use with [manifold_synthetic_data()].
#'
#' @export
params_trajectory <- function(
  topology = c("bifurcation", "linear", "combination"),
  cell_trajectories = NULL,
  noise = 0.1
) {
  topology <- match.arg(topology)

  # checks
  checkmate::assertChoice(topology, c("bifurcation", "linear", "combination"))
  if (!is.null(cell_trajectories)) {
    assertCellTrajectories(cell_trajectories)
  }
  checkmate::qassert(noise, "N1(0,)")

  # return
  list(
    topology = topology,
    cell_trajectories = cell_trajectories,
    noise = noise
  )
}


## evoc ------------------------------------------------------------------------

#' Wrapper function to generate EVoC parameters
#'
#' @param noise_level Numeric. Noise level for the embedding gradient.
#' `0.0` = aggressive, `1.0` = conservative. Defaults to `0.5`.
#' @param n_epochs Integer. Number of embedding optimisation epochs. Defaults
#' to `50L`.
#' @param embedding_dim Integer or `NULL`. Embedding dimensionality. If `NULL`,
#' defaults to `min(max(n_neighbours / 4, 4), 16)`. Defaults to `NULL`.
#' @param neighbour_scale Numeric. Multiplier on effective neighbours for
#' fuzzy graph construction. Defaults to `1.0`.
#' @param symmetrise Logical. Whether to symmetrise the fuzzy graph. Defaults
#' to `TRUE`.
#' @param min_samples Integer. Minimum samples for core distance in MST
#' density estimation. Defaults to `5L`.
#' @param base_min_cluster_size Integer. Base minimum cluster size for the
#' finest layer. Defaults to `5L`.
#' @param approx_n_clusters Integer or `NULL`. If set, binary-searches for
#' approximately this many clusters (single layer output). Defaults to `NULL`.
#' @param min_similarity_threshold Numeric. Jaccard similarity threshold for
#' filtering redundant layers. Defaults to `0.2`.
#' @param max_layers Integer. Maximum number of cluster layers to return.
#' Defaults to `10L`.
#'
#' @returns A list with the EVoC parameters.
#'
#' @export
params_evoc <- function(
  noise_level = 0.5,
  n_epochs = 50L,
  embedding_dim = NULL,
  neighbour_scale = 1.0,
  symmetrise = TRUE,
  min_samples = 5L,
  base_min_cluster_size = 5L,
  approx_n_clusters = NULL,
  min_similarity_threshold = 0.2,
  max_layers = 10L
) {
  # checks
  checkmate::qassert(noise_level, "N1[0,1]")
  checkmate::qassert(n_epochs, "I1[1,)")
  checkmate::assert(
    checkmate::checkNull(embedding_dim),
    checkmate::checkInt(embedding_dim, lower = 2L)
  )
  checkmate::qassert(neighbour_scale, "N1(0,)")
  checkmate::qassert(symmetrise, "B1")
  checkmate::qassert(min_samples, "I1[1,)")
  checkmate::qassert(base_min_cluster_size, "I1[2,)")
  checkmate::assert(
    checkmate::checkNull(approx_n_clusters),
    checkmate::checkInt(approx_n_clusters, lower = 2L)
  )
  checkmate::qassert(min_similarity_threshold, "N1[0,1]")
  checkmate::qassert(max_layers, "I1[1,)")

  list(
    noise_level = noise_level,
    n_epochs = n_epochs,
    embedding_dim = embedding_dim,
    neighbour_scale = neighbour_scale,
    symmetrise = symmetrise,
    min_samples = min_samples,
    base_min_cluster_size = base_min_cluster_size,
    approx_n_clusters = approx_n_clusters,
    min_similarity_threshold = min_similarity_threshold,
    max_layers = max_layers
  )
}

## k-means ---------------------------------------------------------------------

#' Wrapper function to generate k-means parameters
#'
#' @param metric Character. Distance metric to use. One of `"euclidean"` or
#' `"cosine"`. Defaults to `"euclidean"`.
#' @param max_iters Integer. Maximum number of iterations. Defaults to `1000L`.
#' @param batch_size Integer. Mini-batch size. Only used when
#' `method = "minibatch"`. Defaults to `4096L`.
#' @param drift_threshold Float. Below which centroid drift the mini-batch
#' k-means is considered converged. Defaults to `1e-4`. Only used when
#' `method = "minibatch"`
#' @param lr_alpha Float. Learning rate decay for the mini-batch k-means.
#' Original paper uses `1.0`.
#' @param init String. One of `c("parallel", "random")`. The initialisation of
#' the centroids.
#' @param use_gemm Optional boolean. Shall the GEMM path be used. Useful on
#' high dimensional data. If `NULL`, choice will be based on heuristics.
#' @param use_hamerly Optional boolean. Shall Hamerly's method be used (only
#' available if `metric == "euclidean"`).
#'
#' @return A named list with the k-means parameters.
#'
#' @export
params_kmeans <- function(
  metric = c("euclidean", "cosine"),
  max_iters = 1000L,
  batch_size = 4096L,
  drift_threshold = 1e-4,
  lr_alpha = 1.0,
  init = c("parallel", "random"),
  use_hamerly = NULL,
  use_gemm = NULL
) {
  metric <- match.arg(metric)
  init <- match.arg(init)

  checkmate::qassert(max_iters, "I1[1,)")
  checkmate::qassert(batch_size, "I1[1,)")
  checkmate::qassert(drift_threshold, "N1")
  checkmate::qassert(lr_alpha, "N1")
  checkmate::assertChoice(init, c("parallel", "random"))
  checkmate::qassert(use_hamerly, c("0", "B1"))
  checkmate::qassert(use_gemm, c("0", "B1"))

  list(
    metric = metric,
    max_iters = max_iters,
    batch_size = batch_size,
    drift_threshold = drift_threshold,
    lr_alpha = lr_alpha,
    init = init,
    use_hamerly = use_hamerly,
    use_gemm = use_gemm
  )
}
