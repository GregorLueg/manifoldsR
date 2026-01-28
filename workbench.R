library(data.table)
library(ggplot2)
library(magrittr)

devtools::load_all()

data <- qs2::qs_read("~/Desktop/test_data.qs2")

# normal UMAP ------------------------------------------------------------------

tictoc::tic()
umap_bixverse_sdg <- rs_umap(
  embd = data$data,
  n_dim = 2L,
  min_dist = 0.5,
  spread = 1.0,
  k = 15L,
  umap_params = list(
    init = "spectral",
    optimiser = "adam_parallel",
    knn_method = "nndescent",
    gamma = 1.0
  ),
  seed = 42L,
  verbose = TRUE
)
tictoc::toc()

umap_uwot_bixverse_sgd <- as.data.table(umap_bixverse_sdg) %>%
  `colnames<-`(c("umap1", "umap2")) %>%
  .[,
    `:=`(
      cell_line = data$propagation_res,
      condition = data$condition_res
    )
  ]

ggplot(data = umap_uwot_bixverse_sgd, mapping = aes(x = umap1, y = umap2)) +
  geom_point(mapping = aes(col = cell_line), size = 0.25)

# parametric UMAP --------------------------------------------------------------

tictoc::tic()
umap_bixverse_parametric <- rs_umap_parametric(
  embd = data$data,
  n_dim = 2L,
  min_dist = 0.5,
  spread = 1.0,
  k = 15L,
  umap_params = list(
    knn_method = "nndescent",
    gamma = 1.0
  ),
  seed = 42L,
  verbose = TRUE
)
tictoc::toc()

rextendr::document()
