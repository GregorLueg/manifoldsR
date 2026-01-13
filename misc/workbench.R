data(iris)

library(magrittr)
library(data.table)
library(ggplot2)

rextendr::clean()
rextendr::document()

input <- as.matrix(iris[, c(
  "Sepal.Length",
  "Sepal.Width",
  "Petal.Length",
  "Petal.Width"
)])

# pca

pca_stuff <- prcomp(input)

pca_plot_df <- as.data.frame(pca_stuff$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  dplyr::mutate(class = iris$Species)

ggplot(data = pca_plot_df, mapping = aes(x = PC1, y = PC2)) +
  geom_point(mapping = aes(colour = class))

# umap

umap_output <- rs_umap(
  embd = input,
  n_dim = 2,
  min_dist = 0.5,
  spread = 1,
  k = 15L,
  umap_params = list(
    knn_method = "annoy",
    optimiser = "adam_parallel",
    init = "pca",
    n_epochs = 500L
  ),
  seed = 42L,
  verbose = TRUE
)

umap_plot_df <- as.data.frame(umap_output) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  dplyr::mutate(class = iris$Species)

ggplot(data = umap_plot_df, mapping = aes(x = UMAP1, y = UMAP2)) +
  geom_point(mapping = aes(colour = class))

# tsne

tsne_output <- rs_tsne(
  embd = input,
  n_dim = 2,
  perplexity = 30,
  tsne_params = list(
    dist_metric = "euclidean",
    theta = 0.1
  ),
  seed = 123L,
  verbose = TRUE
)

tsne_plot_df <- as.data.frame(tsne_output) %>%
  `colnames<-`(c("tSNE1", "tSNE2")) %>%
  dplyr::mutate(class = iris$Species)

ggplot(data = tsne_plot_df, mapping = aes(x = tSNE1, y = tSNE2)) +
  geom_point(mapping = aes(colour = class))
