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
