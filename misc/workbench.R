library(magrittr)
library(data.table)
library(ggplot2)
library(zeallot)

rextendr::clean()
rextendr::document()

# synthetic data ---------------------------------------------------------------

# generate different synthetic data sets

n_samples <- 10000L

swissrole <- rs_data_swiss_role(n_samples = 10000, noise = 0.1, seed = 42L)

c(cluster_data, cluster_membership) %<-%
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = 15L,
    seed = 42L
  )

## tsne ------------------------------------------------------------------------

### swiss role -----------------------------------------------------------------

tsne_swissrole <- rs_tsne(
  embd = swissrole,
  n_dim = 2,
  perplexity = 5,
  approx_type = "bh",
  tsne_params = list(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    init = "pca",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_swissrole_df <- as.data.frame(tsne_swissrole) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(z_axis = swissrole[, 3])

ggplot(
  data = tsne_swissrole_df,
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = z_axis))

### clustered data -------------------------------------------------------------

tictoc::tic()
tsne_clustered <- rs_tsne(
  embd = cluster_data,
  n_dim = 2,
  perplexity = 30,
  approx_type = "bh",
  tsne_params = list(
    knn_method = "annoy",
    dist_metric = "euclidean",
    theta = 0.5,
    n_epochs = 1000L
  ),
  seed = 123L,
  verbose = TRUE
)
tictoc::toc()

tsne_clustered_df <- as.data.frame(tsne_clustered) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(
  data = tsne_clustered_df,
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = cluster), alpha = 0.5, size = 0.25)

tictoc::tic()
rtsne_res <- Rtsne::Rtsne(cluster_data, verbose = TRUE)
tictoc::toc()


rtsne_clustered_df <- as.data.frame(rtsne_res$Y) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(
  data = rtsne_clustered_df,
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = cluster), alpha = 0.5, size = 0.25)

### tree data ------------------------------------------------------------------

tsne_tree <- rs_tsne(
  embd = tree_data,
  n_dim = 2,
  perplexity = 50,
  approx_type = "bh",
  tsne_params = list(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5,
    n_epochs = 1000L
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_tree_df <- as.data.frame(tsne_tree) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(branch = as.factor(branch_membership))

ggplot(
  data = tsne_tree_df,
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = branch), alpha = 0.5, size = 0.25)


#### Testing out wrappers -----------------------------------------------------------------

umap_clustered_adam <- umap(
  data = cluster_data,
  n_dim = 2L,
  min_dist = 0.5,
  spread = 1L,
  k = 15L,
  params = params_umap(knn_method = "NNDescent"),
  seed = 42L,
  verbose = TRUE
)

tsne_clustered <- tsne(
  data = cluster_data,
  n_dim = 2L,
  perplexity = 50L,
  approx_type = "bh",
  params = params_tsne(knn_method = "NNDescent"),
  seed = 123L,
  verbose = TRUE
)

## phate -----------------------------------------------------------------------

rextendr::document()

n_samples <- 50000L

c(cluster_data, cluster_membership) %<-%
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = 15L,
    seed = 42L
  )

c(tree_data, branch_membership) %<-%
  rs_data_trajectory(
    n_samples = n_samples,
    dim = 32L,
    topology = "bifurcation",
    cell_trajectories = NULL,
    noise = 0.25,
    seed = 42L
  )

### tree data ------------------------------------------------------------------

tictoc::tic()
phate_tree <- rs_phate(
  embd = tree_data,
  n_dim = 2L,
  k = 15L,
  phate_params = list(
    mds_method = "classic",
    landmark_method = "spectral",
    n_landmarks = 1024L
  ),
  seed = 42L,
  verbose = TRUE
)
tictoc::toc()

phate_tree_df <- as.data.frame(phate_tree) %>%
  `colnames<-`(c("PHATE1", "PHATE2")) %>%
  dplyr::mutate(branch = as.factor(branch_membership))

ggplot(
  data = phate_tree_df,
  mapping = aes(x = PHATE1, y = PHATE2)
) +
  geom_point(mapping = aes(colour = branch), alpha = 0.5, size = 0.25)

### cluster data ---------------------------------------------------------------

phate_cluster <- rs_phate(
  embd = cluster_data,
  n_dim = 2L,
  k = 5L,
  phate_params = list(
    mds_method = "dense",
    n_landmarks = 500L
  ),
  seed = 42L,
  verbose = TRUE
)

phate_cluster_df <- as.data.frame(phate_cluster) %>%
  `colnames<-`(c("PHATE1", "PHATE2")) %>%
  dplyr::mutate(branch = as.factor(cluster_membership))


ggplot(
  data = phate_cluster_df,
  mapping = aes(x = PHATE1, y = PHATE2)
) +
  geom_point(mapping = aes(colour = branch))


swissrole <- rs_data_swiss_role(n_samples = 1000L, noise = 0.1, seed = 42L)

phate_cluster <- rs_phate(
  embd = swissrole,
  n_dim = 2L,
  k = 25L,
  phate_params = list(
    mds_method = "sgd",
    n_landmarks = 1024L
  ),
  seed = 42L,
  verbose = TRUE
)

swissrole_df <- as.data.frame(phate_cluster) %>%
  `colnames<-`(c("PHATE1", "PHATE2")) %>%
  dplyr::mutate(z = swissrole[, 3])

ggplot(
  data = swissrole_df,
  mapping = aes(x = PHATE1, y = PHATE2)
) +
  geom_point(mapping = aes(colour = z))


knn <- generate_knn_graph(
  data = cluster_data$data,
  k = k,
  ann_method = "nndescent",
  .verbose = FALSE
)


benchmark_data_large <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 50000L
)

if (.Platform$OS.type == "unix") {
  microbenchmark::microbenchmark(
    Rtsne = {
      Rtsne::Rtsne(
        X = benchmark_data_large$data,
        dims = 2,
        perplexity = 30,
        verbose = FALSE
      )
    },
    manifold_bh = {
      tsne(
        data = benchmark_data_large$data,
        perplexity = 30,
        approx_type = "bh",
        seed = 42L,
        .verbose = FALSE
      )
    },
    manifold_fft = {
      tsne(
        data = benchmark_data_large$data,
        perplexity = 30,
        approx_type = "fft",
        seed = 42L,
        .verbose = FALSE
      )
    },
    times = 1L
  )
} else {
  microbenchmark::microbenchmark(
    Rtsne = {
      Rtsne::Rtsne(
        X = benchmark_data_large$data,
        dims = 2,
        perplexity = 30,
        verbose = FALSE
      )
    },
    manifold_bh = {
      tsne(
        data = benchmark_data_large$data,
        perplexity = 30,
        approx_type = "bh",
        seed = 42L,
        .verbose = FALSE
      )
    },
    times = 1L
  )
}

# let's run FFT if possible...
microbenchmark::microbenchmark(
  manifold_bh = {
    tsne(
      data = benchmark_data_large$data,
      perplexity = 30,
      approx_type = "bh",
      seed = 42L,
      .verbose = FALSE
    )
  },
  manifold_fft = {
    tsne(
      data = benchmark_data_large$data,
      perplexity = 30,
      approx_type = "fft",
      seed = 42L,
      .verbose = FALSE
    )
  },
  times = 1L
)
