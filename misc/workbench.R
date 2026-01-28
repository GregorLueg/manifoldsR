data(iris)

library(magrittr)
library(data.table)
library(ggplot2)
library(zeallot)

rextendr::clean()
rextendr::document()

# synthetic data ---------------------------------------------------------------

n_samples <- 100000L

swissrole <- rs_data_swiss_role(n_samples = n_samples, noise = 0.1, seed = 42L)

c(cluster_data, cluster_membership) %<-%
  rs_data_clusters(
    n_samples = n_samples,
    dim = 32L,
    n_clusters = 15L,
    seed = 42L
  )

c(tree_data, branch_membership) %<-%
  rs_data_tree(
    n_samples = n_samples,
    dim = 32L,
    n_branches = 25L,
    noise = 0.1,
    seed = 42L
  )

## pca -------------------------------------------------------------------------

### swiss role -----------------------------------------------------------------

pca_swiss_role <- prcomp(swissrole)

pca_swiss_role_df <- as.data.frame(pca_swiss_role$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  dplyr::mutate(z_axis = swissrole[, 3])

ggplot(
  data = pca_swiss_role_df[sample(1:nrow(pca_swiss_role_df), 50000), ],
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(mapping = aes(colour = z_axis))

### clustered data -------------------------------------------------------------

pca_clusters <- prcomp(cluster_data)

pca_clusters_df <- as.data.frame(pca_clusters$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(
  data = pca_clusters_df[sample(1:nrow(pca_clusters_df), 50000), ],
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(mapping = aes(colour = cluster))

### tree data ------------------------------------------------------------------

pca_tree <- prcomp(tree_data)

pca_tree_df <- as.data.frame(pca_tree$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  dplyr::mutate(branch = as.factor(branch_membership))

ggplot(
  data = pca_tree_df[sample(1:nrow(pca_tree_df), 50000), ],
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(mapping = aes(colour = branch))

## umap ------------------------------------------------------------------------

### swiss role -----------------------------------------------------------------

umap_swissrole <- rs_umap(
  embd = swissrole,
  n_dim = 2,
  min_dist = 0.1,
  spread = 1,
  k = 15L,
  umap_params = list(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "pca",
    n_epochs = 500L
  ),
  seed = 42L,
  verbose = TRUE
)

umap_swissrole_df <- as.data.frame(umap_swissrole) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  dplyr::mutate(z_axis = swissrole[, 3])

ggplot(
  data = umap_swissrole_df[sample(1:nrow(umap_swissrole_df), 50000), ],
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(mapping = aes(colour = z_axis))

### clustered data -------------------------------------------------------------

tictoc::tic()
umap_clustered <- rs_umap(
  embd = cluster_data,
  n_dim = 2,
  min_dist = 0.5,
  spread = 1,
  k = 15L,
  umap_params = list(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "spectral",
    n_epochs = 500L
  ),
  seed = 42L,
  verbose = TRUE
)
tictoc::toc()

umap_clustered_df <- as.data.frame(umap_clustered) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(
  data = umap_clustered_df[sample(1:nrow(umap_clustered_df), 50000), ],
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(mapping = aes(colour = cluster))

### tree data ------------------------------------------------------------------

umap_tree <- rs_umap(
  embd = tree_data,
  n_dim = 2,
  min_dist = 0.5,
  spread = 1,
  k = 15L,
  umap_params = list(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "random",
    n_epochs = 500L
  ),
  seed = 42L,
  verbose = TRUE
)

umap_tree_df <- as.data.frame(umap_tree) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  dplyr::mutate(branch = as.factor(branch_membership))

ggplot(
  data = umap_tree_df[sample(1:nrow(umap_tree_df), 50000), ],
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(mapping = aes(colour = branch))

#### uwot ----------------------------------------------------------------------

# internal implementation
# with 500k cells -> 62.865 sec elapsed

tictoc::tic()
uwot_cluster <- uwot::umap(X = cluster_data, n_epochs = 500L, verbose = TRUE)
tictoc::toc()

# uwot implementation
# n_epochs = 500L, n_samples = 100_000L -> 74.785 sec elapsed
# internal version -> 91.892 sec elapsed
# internal version (SGD) -> 63.277 sec elapsed

tictoc::tic()
uwot_tree <- uwot::umap2(X = cluster_data, verbose = TRUE)
tictoc::toc()

# uwot implementation - umap2
# with 100k cells (umap) -> 11.189 sec elapsed
# internal version -> 8.663 sec elapsed

uwot_tree_df <- as.data.frame(uwot_tree) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(data = uwot_tree_df, mapping = aes(x = UMAP1, y = UMAP2)) +
  geom_point(mapping = aes(colour = cluster))

## tsne ------------------------------------------------------------------------

### swiss role -----------------------------------------------------------------

tsne_swissrole <- rs_tsne(
  embd = swissrole,
  n_dim = 2,
  perplexity = 50,
  approx_type = "fft",
  tsne_params = list(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_swissrole_df <- as.data.frame(tsne_swissrole) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(z_axis = swissrole[, 3])

ggplot(
  data = tsne_swissrole_df[sample(1:nrow(tsne_swissrole_df), 50000), ],
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = z_axis))

### clustered data -------------------------------------------------------------

tsne_clustered <- rs_tsne(
  embd = cluster_data,
  n_dim = 2,
  perplexity = 50,
  approx_type = "fft",
  tsne_params = list(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_clustered_df <- as.data.frame(tsne_clustered) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(cluster = as.factor(cluster_membership))

ggplot(
  data = tsne_clustered_df[sample(1:nrow(tsne_clustered_df), 50000), ],
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = cluster))

### tree data ------------------------------------------------------------------

tsne_tree <- rs_tsne(
  embd = tree_data,
  n_dim = 2,
  perplexity = 30,
  approx_type = "bh",
  tsne_params = list(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_tree_df <- as.data.frame(tsne_tree) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(branch = as.factor(branch_membership))

ggplot(
  data = tsne_tree_df[sample(1:nrow(tsne_tree_df), 50000), ],
  mapping = aes(x = tSNE1, y = tSNE2)
) +
  geom_point(mapping = aes(colour = branch))
