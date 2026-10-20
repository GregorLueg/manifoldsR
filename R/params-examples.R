# examples for the devforge-generated params_*() --------------------------------

# devforge's param_spec() has no examples field, so they attach here via
# @name + @rdname. Edit alongside inst/params/params.R when a field is renamed.

#' @name params_nn
#' @rdname params_nn
#' @examples
#' params_nn()
#' params_nn(dist_metric = "cosine", ef_search = 200L)
NULL

#' @name params_umap
#' @rdname params_umap
#' @examples
#' params_umap()
#' params_umap(n_epochs = 200L, neg_sample_rate = 10L)
NULL

#' @name params_densmap
#' @rdname params_densmap
#' @examples
#' params_densmap()
#' params_densmap(lambda = 1)
NULL

#' @name params_tsne
#' @rdname params_tsne
#' @examples
#' params_tsne()
#' params_tsne(n_epochs = 500L, theta = 0.8)
NULL

#' @name params_densne
#' @rdname params_densne
#' @examples
#' params_densne()
#' params_densne(lambda = 1)
NULL

#' @name params_dreams
#' @rdname params_dreams
#' @examples
#' params_dreams()
#' params_dreams(lambda = 0.3)
NULL

#' @name params_phate
#' @rdname params_phate
#' @examples
#' params_phate()
#' params_phate(decay = 20, n_landmarks = 500L)
NULL

#' @name params_pacmap
#' @rdname params_pacmap
#' @examples
#' params_pacmap()
#' params_pacmap(n_near = 15L, n_further = 30L)
NULL

#' @name params_diffusion_maps
#' @rdname params_diffusion_maps
#' @examples
#' params_diffusion_maps()
#' params_diffusion_maps(t_max = 50L)
NULL

#' @name params_fa2
#' @rdname params_fa2
#' @examples
#' params_fa2()
#' params_fa2(n_epochs = 200L, lin_log = TRUE)
NULL

#' @name params_evoc
#' @rdname params_evoc
#' @examples
#' params_evoc()
#' params_evoc(min_samples = 10L, base_min_cluster_size = 10L)
NULL

#' @name params_kmeans
#' @rdname params_kmeans
#' @examples
#' params_kmeans()
#' params_kmeans(metric = "cosine", max_iters = 100L)
NULL

#' @name params_clusters
#' @rdname params_clusters
#' @examples
#' params_clusters()
#' params_clusters(n_clusters = 5L)
NULL

#' @name params_hierarchical
#' @rdname params_hierarchical
#' @examples
#' params_hierarchical()
#' params_hierarchical(n_supergroups = 4L, n_subclusts = 2L)
NULL

#' @name params_trajectory
#' @rdname params_trajectory
#' @examples
#' params_trajectory()
NULL

#' @name params_swiss_roll
#' @rdname params_swiss_roll
#' @examples
#' params_swiss_roll()
#' params_swiss_roll(noise = 0.2)
NULL

#' @name params_swiss_roll_biased
#' @rdname params_swiss_roll_biased
#' @examples
#' params_swiss_roll_biased()
#' params_swiss_roll_biased(noise = 0.2, bias = 1)
NULL
