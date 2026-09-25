# nearest neighbours -----------------------------------------------------------

spec_nn <- param_spec(
  name = "nn",
  title = "Wrapper function to generate nearest neighbour parameters",
  label = "nearest neighbour params",
  fields = list(
    dist_metric = p_choice(
      "euclidean",
      c("euclidean", "cosine"),
      doc = "The distance metric to use."
    ),
    n_tree = p_int(50L, doc = "Number of trees for Annoy."),
    search_budget = p_int(
      NULL,
      null_ok = TRUE,
      doc = "Search budget for Annoy."
    ),
    m = p_int(16L, doc = "Number of bidirectional links for HNSW."),
    ef_construction = p_int(
      100L,
      doc = "Size of the dynamic candidate list during HNSW construction."
    ),
    ef_search = p_int(
      100L,
      doc = "Size of the dynamic candidate list during HNSW search."
    ),
    diversify_prob = p_dbl(
      0.0,
      doc = "Diversification probability for NN descent."
    ),
    delta = p_dbl(0.001, doc = "Precision parameter for NN descent."),
    ef_budget = p_int(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Effort budget for NN descent. Ignored when `extract_knn` is `TRUE`,",
        "as no search runs."
      )
    ),
    extract_knn = p_lgl(
      TRUE,
      doc = paste(
        "Only affects the `\"nndescent\"` backend. If `TRUE`, the descent",
        "hands back the graph it just built instead of running a beam search",
        "over it. Faster, at a recall of roughly `0.98` rather than",
        "`0.99`-`1.00`."
      )
    ),
    bt_budget = p_dbl(0.1, doc = "Budget for ball tree search."),
    n_list = p_int(
      NULL,
      null_ok = TRUE,
      doc = "Number of clusters to use for IVF. If `NULL`, uses `sqrt(n)`."
    ),
    n_probes = p_int(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Number of clusters to probe for IVF. If `NULL`, uses",
        "`sqrt(n_list)`."
      )
    )
  )
)

# umap -------------------------------------------------------------------------

spec_umap <- param_spec(
  name = "umap",
  title = "Wrapper function to generate UMAP parameters",
  label = "UMAP params",
  fields = list(
    local_connectivity = p_dbl(
      1.0,
      doc = "Number of nearest neighbours assumed to be at distance zero."
    ),
    bandwidth = p_dbl(
      1e-5,
      doc = "Convergence tolerance for smooth kNN distance binary search."
    ),
    mix_weight = p_dbl(
      1.0,
      doc = paste(
        "Balance between fuzzy union and directed graph during",
        "symmetrisation."
      )
    ),
    lr = p_dbl(1.0, doc = "Learning rate."),
    n_epochs = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Number of optimisation epochs. If `NULL`, resolved downstream based",
        "on data size."
      )
    ),
    neg_sample_rate = p_int(
      5L,
      doc = "Number of negative samples per positive sample."
    ),
    gamma = p_dbl(1.0, doc = "Repulsion strength."),
    optimiser = p_choice(
      "adam_parallel",
      c("adam_parallel", "sgd", "adam"),
      doc = "The optimiser."
    ),
    init = p_choice(
      "spectral",
      c("spectral", "pca", "random"),
      doc = "Embedding initialisation method."
    ),
    randomised = p_lgl(
      TRUE,
      doc = "Use randomised SVD for PCA initialisation."
    )
  )
)

# forceatlas2 ------------------------------------------------------------------

spec_fa2 <- param_spec(
  name = "fa2",
  title = "Wrapper function to generate ForceAtlas2 parameters",
  description = paste(
    "The graph, initialisation and optimisation knobs for ForceAtlas2.",
    "`local_connectivity`, `bandwidth`, `init` and `randomised` only apply",
    "when the graph is built from the data via [forceatlas2()];",
    "[forceatlas2_from_graph()] ignores them."
  ),
  label = "ForceAtlas2 params",
  references = "Jacomy, et al., PLoS ONE, 2014",
  fields = list(
    local_connectivity = p_dbl(
      1.0,
      doc = "Number of nearest neighbours assumed to be at distance zero."
    ),
    bandwidth = p_dbl(
      1e-5,
      doc = "Convergence tolerance for smooth kNN distance binary search."
    ),
    n_epochs = p_int(
      500L,
      range = "[1,)",
      doc = "Number of optimisation epochs."
    ),
    scaling_ratio = p_dbl(
      2.0,
      range = "(0,)",
      doc = "Repulsion strength. Larger values spread the layout."
    ),
    gravity = p_dbl(
      1.0,
      range = "[0,)",
      doc = paste(
        "Pull towards the origin. Keeps disconnected components from",
        "drifting off."
      )
    ),
    strong_gravity = p_lgl(
      FALSE,
      doc = "Distance-independent gravity, scaled by `scaling_ratio`."
    ),
    lin_log = p_lgl(
      FALSE,
      doc = "Logarithmic attraction (LinLog). Gives tighter communities."
    ),
    dissuade_hubs = p_lgl(
      FALSE,
      doc = paste(
        "Divide the attraction by the node mass. Pushes hubs to the",
        "periphery."
      )
    ),
    edge_weight_influence = p_dbl(
      1.0,
      range = "[0,)",
      doc = "Exponent applied to the edge weights. `0` ignores the weights."
    ),
    jitter_tolerance = p_dbl(
      1.0,
      range = "(0,)",
      doc = "Tolerated swinging. Larger is faster but less precise."
    ),
    theta = p_dbl(
      1.2,
      range = "[0,)",
      doc = paste(
        "Barnes-Hut opening parameter on Gephi's scale. `0` gives the exact",
        "repulsion."
      )
    ),
    init = p_choice(
      "spectral",
      c("spectral", "pca", "random"),
      doc = "Embedding initialisation method."
    ),
    randomised = p_lgl(
      FALSE,
      doc = "Use randomised SVD for PCA initialisation."
    )
  )
)

# tsne -------------------------------------------------------------------------

spec_tsne <- param_spec(
  name = "tsne",
  title = "Wrapper function to generate t-SNE parameters",
  label = "t-SNE params",
  references = "Belkina, et al., Nat. Commun., 2019",
  fields = list(
    lr = p_dbl(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Learning rate. If `NULL`, the Rust backend sets it to",
        "`max((n_samples / 12), 200)`, following the N-dependent heuristic of",
        "Belkina et al. (2019)."
      )
    ),
    n_epochs = p_int(
      1000L,
      range = "[1,)",
      doc = "Number of optimisation epochs."
    ),
    early_exag_iter = p_int(
      250L,
      range = "[1,)",
      doc = "Number of early exaggeration iterations."
    ),
    early_exag_factor = p_dbl(12.0, doc = "Early exaggeration factor."),
    late_exag_factor = p_dbl(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Late exaggeration factor, if you wish to use one. Can be useful on",
        "large data sets (set it to `2.0` to `4.0`)."
      )
    ),
    theta = p_dbl(
      0.5,
      range = "[0,1]",
      doc = paste(
        "Barnes-Hut approximation angle. Lower values increase accuracy at",
        "the cost of speed."
      )
    ),
    n_interp_points = p_int(
      3L,
      range = "[1,)",
      doc = "Number of interpolation points per grid cell for FFT acceleration."
    ),
    init = p_choice(
      "pca",
      c("pca", "spectral", "random"),
      doc = "Embedding initialisation method."
    ),
    randomised = p_lgl(
      TRUE,
      doc = "Use randomised SVD for PCA initialisation."
    )
  )
)

# density-preserving -----------------------------------------------------------

spec_densmap <- param_spec(
  name = "densmap",
  title = "Wrapper function to generate densMAP parameters",
  description = paste(
    "The density-preservation knobs on top of the usual UMAP parameters.",
    "densMAP adds `-lambda * Corr(log Ro, log Re)` to the UMAP loss, where",
    "`Ro` is the local radius in the input space and `Re` the matching radius",
    "in the embedding. Setting `lambda` to `0` recovers plain UMAP."
  ),
  checker = "Dens",
  label = "density params",
  references = "Narayan, Berger & Cho, Nat. Biotechnol., 2021",
  fields = list(
    lambda = p_dbl(
      2.0,
      range = "[0,)",
      doc = paste(
        "Weight of the density term. `0` disables it. The default is the",
        "densMAP reference value."
      )
    ),
    frac = p_dbl(
      0.3,
      range = "[0,1]",
      doc = paste(
        "Fraction of the total epochs, at the end of the run, over which the",
        "density term is active."
      )
    ),
    var_shift = p_dbl(
      0.1,
      range = "[0,)",
      doc = "Additive shift on the variance of the embedding log-radii."
    )
  )
)

spec_densne <- param_spec(
  name = "densne",
  title = "Wrapper function to generate den-SNE parameters",
  description = paste(
    "The density-preservation knobs on top of the usual t-SNE parameters.",
    "den-SNE adds `-lambda * Corr(log Ro, log Re)` to the t-SNE loss, where",
    "`Ro` is the local radius in the input space and `Re` the matching radius",
    "in the embedding. Setting `lambda` to `0` recovers plain t-SNE."
  ),
  checker = "Dens",
  label = "density params",
  references = "Narayan, Berger & Cho, Nat. Biotechnol., 2021",
  fields = list(
    lambda = p_dbl(
      0.5,
      range = "[0,)",
      doc = paste(
        "Weight of the density term. `0` disables it. The default is higher",
        "than the den-SNE reference value (original: `0.1`)."
      )
    ),
    frac = p_dbl(
      0.3,
      range = "[0,1]",
      doc = paste(
        "Fraction of the total epochs, at the end of the run, over which the",
        "density term is active."
      )
    ),
    var_shift = p_dbl(
      0.1,
      range = "[0,)",
      doc = "Additive shift on the variance of the embedding log-radii."
    )
  )
)

# phate ------------------------------------------------------------------------

spec_phate <- param_spec(
  name = "phate",
  title = "Wrapper function to generate PHATE parameters",
  label = "PHATE params",
  fields = list(
    decay = p_dbl(
      40.0,
      range = "(0,)",
      doc = paste(
        "Alpha decay parameter controlling the kernel bandwidth. Higher values",
        "create sharper transitions."
      )
    ),
    bandwidth_scale = p_dbl(
      NULL,
      range = "(0,)",
      null_ok = TRUE,
      doc = paste(
        "Scaling factor applied to the kernel bandwidth. If `NULL`, the",
        "library selects a sensible default."
      )
    ),
    t_max = p_int(
      100L,
      range = "[1,)",
      doc = paste(
        "Maximum diffusion time considered during automatic selection via Von",
        "Neumann entropy knee point detection."
      )
    ),
    t_custom = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = "Fixed diffusion time. If set, overrides automatic time selection."
    ),
    gamma = p_dbl(
      1.0,
      doc = "Informational distance parameter for the diffusion potential."
    ),
    n_landmarks = p_int(
      2048L,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Number of landmarks for compressed diffusion. If `NULL`, the full",
        "N x N diffusion operator is used."
      )
    ),
    landmark_method = p_choice(
      "spectral",
      c("spectral", "random", "density"),
      doc = "Method used to select landmarks."
    ),
    n_svd = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Number of SVD components used in landmark construction. If `NULL`,",
        "the library selects a sensible default."
      )
    ),
    mds_method = p_choice(
      "sgd_dense",
      c("sgd_dense", "classic"),
      doc = "MDS algorithm used for the final embedding."
    ),
    graph_symmetry = p_choice(
      "additive",
      c("additive", "multiplicative", "mnn", "none"),
      doc = "Method used to symmetrise the affinity graph."
    )
  )
)

# pacmap -----------------------------------------------------------------------

spec_pacmap <- param_spec(
  name = "pacmap",
  title = "Wrapper function to generate PaCMAP parameters",
  label = "PaCMAP params",
  fields = list(
    n_near = p_int(10L, doc = "Near pairs per point (attractive)."),
    n_mid_near = p_int(5L, doc = "Mid-near pairs per point."),
    n_further = p_int(20L, doc = "Further (random) pairs per point."),
    mn_candidate_start = p_int(
      4L,
      doc = "Start index into kNN list for mid-near candidate window."
    ),
    mn_candidate_end = p_int(
      50L,
      doc = paste(
        "End index into kNN list for mid-near candidate window. Also",
        "determines the kNN search size."
      )
    ),
    init = p_choice(
      "pca",
      c("pca", "random"),
      doc = "Embedding initialisation."
    ),
    optimiser = p_choice(
      "adam_parallel",
      c("adam_parallel", "adam"),
      doc = "The optimiser."
    ),
    lr = p_dbl(1.0, doc = "Adam learning rate."),
    n_epochs = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Total optimisation epochs. If `NULL`, resolved downstream to",
        "`450`."
      )
    ),
    beta1 = p_dbl(0.9, doc = "Adam first moment decay."),
    beta2 = p_dbl(0.999, doc = "Adam second moment decay."),
    eps = p_dbl(1e-7, doc = "Adam numerical stability constant."),
    phase1_end = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Epoch at which phase 1 ends. If `NULL`, resolved downstream to",
        "`100`."
      )
    ),
    phase2_end = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Epoch at which phase 2 ends. If `NULL`, resolved downstream to",
        "`200`."
      )
    )
  )
)

# diffusion maps ---------------------------------------------------------------

spec_diffusion_maps <- param_spec(
  name = "diffusion_maps",
  title = "Wrapper function to generate diffusion maps parameters",
  label = "diffusion maps params",
  fields = list(
    bandwidth_scale = p_dbl(
      1.0,
      range = "(0,)",
      doc = "Multiplicative factor applied to the adaptive kernel bandwidth."
    ),
    thresh = p_dbl(
      1e-4,
      range = "[0,)",
      doc = "Sparsity threshold applied to kernel entries."
    ),
    graph_symmetry = p_choice(
      "additive",
      c("additive", "multiplicative", "mnn", "none"),
      doc = "Method used to symmetrise the affinity graph."
    ),
    alpha_norm = p_dbl(
      1.0,
      range = "[0,1]",
      doc = paste(
        "Anisotropic density-correction exponent. `0` gives the normalised",
        "graph Laplacian, `0.5` the Fokker-Planck operator, `1` the",
        "Laplace-Beltrami operator."
      )
    ),
    t_max = p_int(
      100L,
      range = "[1,)",
      doc = paste(
        "Maximum diffusion time considered during automatic selection via Von",
        "Neumann entropy knee point detection."
      )
    ),
    t_custom = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = "Fixed diffusion time. If set, overrides automatic time selection."
    ),
    n_landmarks = p_int(
      2048L,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Number of landmarks for compressed diffusion. If `NULL`, the full",
        "N x N diffusion operator is used."
      )
    ),
    landmark_method = p_choice(
      "spectral",
      c("spectral", "random", "density"),
      doc = "Method used to select landmarks."
    ),
    n_svd = p_int(
      NULL,
      range = "[1,)",
      null_ok = TRUE,
      doc = paste(
        "Number of SVD components used in landmark construction. If `NULL`,",
        "the library selects a sensible default."
      )
    )
  )
)

# synthetic data ---------------------------------------------------------------

spec_swiss_role <- param_spec(
  name = "swiss_role",
  title = "Parameters for swiss roll data generation",
  description = "For use with [manifold_synthetic_data()].",
  label = "swiss roll params",
  fields = list(
    noise = p_dbl(0.1, range = "(0,)", doc = "Amount of noise to add.")
  )
)

spec_swiss_role_biased <- param_spec(
  name = "swiss_role_biased",
  title = "Parameters for biased swiss roll data generation",
  description = "For use with [manifold_synthetic_data()].",
  label = "biased swiss roll params",
  fields = list(
    noise = p_dbl(0.1, range = "(0,)", doc = "Amount of noise to add."),
    bias = p_dbl(
      2.5,
      range = "(0,)",
      doc = "The sampling bias across the manifold."
    )
  )
)

spec_clusters <- param_spec(
  name = "clusters",
  title = "Parameters for clustered data generation",
  description = "For use with [manifold_synthetic_data()].",
  label = "cluster params",
  fields = list(
    n_clusters = p_int(
      15L,
      range = "(1,)",
      doc = "Number of clusters to generate."
    )
  )
)

spec_hierarchical <- param_spec(
  name = "hierarchical",
  title = "Parameters for hierarchical cluster data generation",
  description = "For use with [manifold_synthetic_data()].",
  label = "hierarchical cluster params",
  fields = list(
    n_supergroups = p_int(
      3L,
      range = "(1,)",
      doc = "Number of top-level groups."
    ),
    n_subclusts = p_int(
      3L,
      range = "(1,)",
      doc = "Number of subclusters per supergroup."
    ),
    supergroup_spread = p_dbl(
      15.0,
      range = "(0,)",
      doc = "Spread of supergroup centres in the ambient space."
    ),
    subcluster_spread = p_dbl(
      2.0,
      range = "(0,)",
      doc = "Spread of subcluster centres around their supergroup centre."
    ),
    point_std = p_dbl(
      0.4,
      range = "(0,)",
      doc = "Within-subcluster Gaussian noise."
    )
  )
)

spec_trajectory <- param_spec(
  name = "trajectory",
  title = "Parameters for trajectory data generation",
  description = "For use with [manifold_synthetic_data()].",
  label = "trajectory params",
  fields = list(
    topology = p_choice(
      "bifurcation",
      c("bifurcation", "linear", "combination"),
      doc = "Ignored if `cell_trajectories` is not `NULL`."
    ),
    cell_trajectories = p_free(
      NULL,
      doc = paste(
        "Optional named list with three equal-length vectors: `parent`",
        "(integer, `NA` for root, zero-indexed), `split_at` (numeric, fraction",
        "along parent where branch starts), and `length` (numeric, length of",
        "the branch). If `NULL`, `topology` is used instead."
      )
    ),
    noise = p_dbl(0.1, range = "(0,)", doc = "Amount of noise to add.")
  ),
  extra_ctor = quote(
    if (!is.null(cell_trajectories)) {
      assertCellTrajectories(cell_trajectories)
    }
  ),
  extra_check = quote(
    if (!is.null(x$cell_trajectories)) {
      res <- checkCellTrajectories(x$cell_trajectories)
      if (!isTRUE(res)) {
        return(res)
      }
    }
  )
)

# evoc -------------------------------------------------------------------------

spec_evoc <- param_spec(
  name = "evoc",
  title = "Wrapper function to generate EVoC parameters",
  label = "EVoC params",
  fields = list(
    noise_level = p_dbl(
      0.5,
      range = "[0,1]",
      doc = paste(
        "Noise level for the embedding gradient. `0.0` = aggressive, `1.0` =",
        "conservative."
      )
    ),
    n_epochs = p_int(
      50L,
      range = "[1,)",
      doc = "Number of embedding optimisation epochs."
    ),
    embedding_dim = p_int(
      NULL,
      range = "[2,)",
      null_ok = TRUE,
      doc = paste(
        "Embedding dimensionality. If `NULL`, uses",
        "`min(max(n_neighbours / 4, 4), 16)`."
      )
    ),
    neighbour_scale = p_dbl(
      1.0,
      range = "(0,)",
      doc = "Multiplier on effective neighbours for fuzzy graph construction."
    ),
    symmetrise = p_lgl(TRUE, doc = "Whether to symmetrise the fuzzy graph."),
    min_samples = p_int(
      5L,
      range = "[1,)",
      doc = "Minimum samples for core distance in MST density estimation."
    ),
    base_min_cluster_size = p_int(
      5L,
      range = "[2,)",
      doc = "Base minimum cluster size for the finest layer."
    ),
    approx_n_clusters = p_int(
      NULL,
      range = "[2,)",
      null_ok = TRUE,
      doc = paste(
        "If set, binary-searches for approximately this many clusters (single",
        "layer output)."
      )
    ),
    min_similarity_threshold = p_dbl(
      0.2,
      range = "[0,1]",
      doc = "Jaccard similarity threshold for filtering redundant layers."
    ),
    max_layers = p_int(
      10L,
      range = "[1,)",
      doc = "Maximum number of cluster layers to return."
    )
  )
)

# k-means ----------------------------------------------------------------------

spec_kmeans <- param_spec(
  name = "kmeans",
  title = "Wrapper function to generate k-means parameters",
  label = "k-means params",
  fields = list(
    metric = p_choice(
      "euclidean",
      c("euclidean", "cosine"),
      doc = "Distance metric to use."
    ),
    max_iters = p_int(
      1000L,
      range = "[1,)",
      doc = "Maximum number of iterations."
    ),
    batch_size = p_int(
      4096L,
      range = "[1,)",
      doc = "Mini-batch size. Only used when `method = \"minibatch\"`."
    ),
    drift_threshold = p_dbl(
      1e-4,
      doc = paste(
        "Below which centroid drift the mini-batch k-means is considered",
        "converged. Only used when `method = \"minibatch\"`."
      )
    ),
    lr_alpha = p_dbl(
      1.0,
      doc = paste(
        "Learning rate decay for the mini-batch k-means. Original paper uses",
        "`1.0`."
      )
    ),
    init = p_choice(
      "parallel",
      c("parallel", "random"),
      doc = "The initialisation of the centroids."
    ),
    use_hamerly = p_lgl(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Shall Hamerly's method be used (only if",
        "`metric == \"euclidean\"`)."
      )
    ),
    use_gemm = p_lgl(
      NULL,
      null_ok = TRUE,
      doc = paste(
        "Shall the GEMM path be used. Useful on high dimensional data. If",
        "`NULL`, choice will be based on heuristics."
      )
    )
  )
)
