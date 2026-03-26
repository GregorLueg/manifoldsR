library(magrittr)
library(data.table)
library(ggplot2)
library(zeallot)

rextendr::clean()
rextendr::document()

benchmark_data <- manifold_synthetic_data(
  type = "trajectory",
  n_samples = 200000L
)

tictoc::tic()
original <- phateR::phate(
  data = benchmark_data$data,
  knn = 15L,
  npca = 100L,
  n.jobs = -1,
  verbose = TRUE
)
tictoc::toc()

tictoc::tic()
manifold <- phate(
  data = benchmark_data$data,
  k = 15L,
  knn_method = "nndescent",
  phate_params = params_phate(
    n_landmarks = 2048L,
    landmark_method = "spectral"
  ),
  seed = 42L,
  .verbose = TRUE
)
tictoc::toc()

plot(manifold[, 1], manifold[, 2])

plot(original$embedding[, 1], original$embedding[, 2])

hierarchical_data <- manifold_synthetic_data(
  type = "hierarchical",
  n_samples = 25000L
)

pacmap_hierarchical <- pacmap(
  data = hierarchical_data$data,
  k = 10L,
  pacmap_params = params_pacmap(
    mn_candidate_start = 4L,
    mn_candidate_end = 25L,
    n_further = 5L,
    optimiser = "adam_parallel"
  ),
  seed = 42L
)

pacmap_hierarchical_df <- as.data.table(pacmap_hierarchical) %>%
  `colnames<-`(c("PaCMAP1", "PaCMAP2")) %>%
  .[, supergroup := as.factor(hierarchical_data$membership$supergroup)] %>%
  .[, subgroup := as.factor(hierarchical_data$membership$subgroup)]

ggplot(
  data = pacmap_hierarchical_df,
  mapping = aes(x = PaCMAP1, y = PaCMAP2)
) +
  geom_point(
    mapping = aes(colour = subgroup, shape = supergroup),
    size = 1,
    alpha = 0.5
  ) +
  theme_bw() +
  ggtitle("PaCMAP on hierarchical data") +
  scale_colour_viridis_d()


umap_hierarchical <- umap(
  data = hierarchical_data$data,
  k = 15L,
  seed = 42L,
  .verbose = FALSE
)

umap_hierarchical_df <- as.data.table(umap_hierarchical) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, supergroup := as.factor(hierarchical_data$membership$supergroup)] %>%
  .[, subgroup := as.factor(hierarchical_data$membership$subgroup)]

ggplot(
  data = umap_hierarchical_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = subgroup, shape = supergroup),
    size = 1,
    alpha = 0.5
  ) +
  theme_bw() +
  ggtitle("UMAP on hierarchical data") +
  scale_colour_viridis_d()
