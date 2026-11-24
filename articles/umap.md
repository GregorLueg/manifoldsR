# Using UMAP

## UMAP in manifoldsR

`manifoldsR` provides a very rapid implementation of
[UMAP](https://arxiv.org/abs/1802.03426), based on the brilliant work in
the [uwot](https://github.com/jlmelville/uwot) package. Everything runs
in Rust, R is purely the interface, and the aim is to push the algorithm
even further on speed.

``` r

library(manifoldsR)
library(magrittr)
library(ggplot2)
library(data.table)
#> 
#> Attaching package: 'data.table'
#> The following object is masked from 'package:base':
#> 
#>     %notin%
```

### Intro

UMAP works by constructing a weighted k-nearest neighbour graph in the
high-dimensional space (see the knn_searches vignette for more details
here!), where edge weights reflect the likelihood that two points are
connected given their distance under a local, adaptive metric. It then
minimises a cross-entropy loss between this high-dimensional graph and a
low-dimensional analogue, pulling connected nodes together and pushing
unconnected ones apart. This objective is why **UMAP excels at
preserving cluster structure**: if two points are unlikely neighbours in
high dimensions, the repulsion term drives them apart in the embedding,
producing clean separation. The flip side is that UMAP has **no
incentive to preserve the relative distances along a continuum**. For
trajectory or manifold data where the meaningful signal is a smooth
progression, the loss treats weakly-connected distant points as things
to repel rather than as part of a coherent structure. Continuous
manifolds tend to get torn apart into spurious clusters. Distances and
even topology within an embedding should **therefore be interpreted with
caution**. [UMAP is a visualisation tool, not a metric
space!](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011288)

### Running UMAP

The default optimiser is a parallel version of Adam, the same idea
`uwot` uses in `umap2()`. The gradients for each node are collected in
parallel and then applied in one go, so it scales with your cores, and
the same seed gives you the same embedding every time. There is also a
sequential Adam (`optimiser = "adam"`), but the parallel one is the one
you want.

We are going to generate three different data sets to showcase the
strengths (and weaknesses) of UMAP:

``` r

cluster_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 25000L
)

swissroll_data <- manifold_synthetic_data(
  type = "swiss_roll",
  n_samples = 1000L
)

trajectory_data <- manifold_synthetic_data(
  type = "trajectory",
  n_samples = 25000L
)
```

#### Clustered data

Let’s start with something UMAP does well: visualise well separated
clusters. We will first contrast this against standard PCA to have a
baseline…

``` r

pca_clusters <- prcomp(cluster_data$data)

pca_clusters_df <- as.data.table(pca_clusters$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  .[, cluster := as.factor(cluster_data$membership)]

ggplot(
  data = pca_clusters_df,
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(mapping = aes(colour = cluster), size = 0.75, alpha = 0.5) +
  theme_bw() +
  ggtitle("PCA on clustered data")
```

![](umap_files/figure-html/clustered%20data%20-%20pca-1.png)

PCA does an okay job here, but several of the clusters are clearly
mixed. The separation likely sits in other combinations of the PCs.
Let’s see what UMAP can do in just two dimensions.

``` r

umap_clusters <- umap(
  data = cluster_data$data,
  k = 15L
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_clustered_df <- as.data.table(umap_clusters) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, cluster := as.factor(cluster_data$membership)]

ggplot(
  data = umap_clustered_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = cluster),
    alpha = 0.5,
    size = 0.75
  ) +
  theme_bw() +
  ggtitle("UMAP on clustered data")
```

![](umap_files/figure-html/clustered%20data%20-%20umap-1.png)

UMAP cleanly separates the individual clusters (as expected). In other
cases, UMAP does worse… Let’s look at the Swiss roll.

#### Swiss roll

``` r

pca_swiss_roll <- prcomp(swissroll_data$data)

pca_swiss_roll_df <- as.data.table(pca_swiss_roll$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  .[, z_axis := swissroll_data$data[, 3]]

ggplot(
  data = pca_swiss_roll_df,
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(
    mapping = aes(fill = z_axis),
    shape = 21,
    size = 2,
    alpha = 0.5
  ) +
  scale_fill_viridis_c() +
  theme_bw() +
  ggtitle("PCA on swissroll")
```

![](umap_files/figure-html/swissroll%20data%20-%20pca-1.png)

PCA clearly captures the Swiss roll structure. How does UMAP perform
here … ?

``` r

umap_swissroll <- umap(
  data = swissroll_data$data,
  knn_method = "exhaustive",
  k = 10L # reduced because smaller
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_swissroll_df <- as.data.table(umap_swissroll) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, z_axis := swissroll_data$data[, 3]]

ggplot(
  data = umap_swissroll_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(fill = z_axis),
    shape = 21,
    size = 2,
    alpha = 0.5
  ) +
  scale_fill_viridis_c() +
  theme_bw() +
  ggtitle("UMAP on swissroll")
```

![](umap_files/figure-html/swissroll%20data%20-%20umap-1.png)

UMAP rips apart the Swiss roll. Due to the nature of the loss, it is not
a great algorithm for data with a continuum-type manifold. The
trajectory data shows the same problem.

#### Trajectory

PCA first again.

``` r

pca_trajectory <- prcomp(trajectory_data$data)

pca_trajectory_df <- as.data.table(pca_trajectory$x[, 1:2]) %>%
  `colnames<-`(c("PC1", "PC2")) %>%
  .[, branch := trajectory_data$membership]

# will mix the labels to visualise the continuum better
ggplot(
  data = pca_trajectory_df[
    sample(1:nrow(pca_trajectory_df), nrow(pca_trajectory_df)),
  ],
  mapping = aes(x = PC1, y = PC2)
) +
  geom_point(
    mapping = aes(colour = branch),
    alpha = 0.5,
    size = 0.75
  ) +
  theme_bw() +
  scale_colour_viridis_c(option = "turbo") +
  ggtitle("PCA on trajectory data")
```

![](umap_files/figure-html/trajectory%20data%20-%20pca-1.png)

We can appreciate the branching and the continuum in the data.

``` r

umap_trajectory <- umap(
  data = trajectory_data$data,
  knn_method = "exhaustive"
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_trajectory_df <- as.data.table(umap_trajectory) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, branch := trajectory_data$membership]

ggplot(
  data = umap_trajectory_df[
    sample(1:nrow(umap_trajectory_df), nrow(umap_trajectory_df)),
  ],
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = branch),
    alpha = 0.5,
    size = 0.75
  ) +
  theme_bw() +
  scale_colour_viridis_c(option = "turbo") +
  ggtitle("UMAP on trajectory data")
```

![](umap_files/figure-html/trajectory%20data%20-%20umap-1.png)

Here we see the clear problem of UMAP. Instead of the continuum in the
manifold, we end up with distinct clusters and some bleeding in between
them. That does not represent the underlying data at all.

### Using pre-computed kNN parameters

Want to test a range of parameters while keeping the number of
neighbours constant? Compute the kNN graph once and hand the
`NearestNeighbours` object to
[`umap()`](https://gregorlueg.github.io/manifoldsR/reference/umap.md):

``` r

precomputed_knn <- generate_knn_graph(
  data = cluster_data$data,
  k = 15L,
  .verbose = FALSE
)

umap_clusters_from_knn <- umap(
  data = cluster_data$data,
  knn = precomputed_knn,
  k = 15L
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_clustered_from_knn_df <- as.data.table(umap_clusters_from_knn) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, cluster := as.factor(cluster_data$membership)]

ggplot(
  data = umap_clustered_from_knn_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = cluster),
    alpha = 0.5,
    size = 0.75
  ) +
  theme_bw() +
  ggtitle("UMAP on pre-computed kNN")
```

![](umap_files/figure-html/umap%20-%20use%20pre-computed%20kNN-1.png)

And a quick re-run with a different `min_dist`:

``` r

umap_clusters_from_knn <- umap(
  data = cluster_data$data,
  knn = precomputed_knn,
  min_dist = 1.0, # let's make the min_dist bigger
  k = 15L
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_clustered_from_knn_df <- as.data.table(umap_clusters_from_knn) %>%
  `colnames<-`(c("UMAP1", "UMAP2")) %>%
  .[, cluster := as.factor(cluster_data$membership)]

ggplot(
  data = umap_clustered_from_knn_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = cluster),
    alpha = 0.5,
    size = 0.75
  ) +
  theme_bw() +
  ggtitle("UMAP on pre-computed kNN (min_dist = 1.0)")
```

![](umap_files/figure-html/umap%20-%20different%20parameters-1.png)

### umap-learn behaviour: SGD

The original UMAP (and `umap-learn`, and
[`uwot::umap()`](https://jlmelville.github.io/uwot/reference/umap.html))
optimises with plain stochastic gradient descent. If you want embeddings
that look like those, pick one of the two SGD optimisers:

- `"sgd"`: single-threaded, reproducible with a given seed.
- `"sgd_parallel"`: lock-free,
  [Hogwild!](https://arxiv.org/abs/1106.5730) style. All threads write
  to the shared embedding without locks, which is where the speed comes
  from. The price: with more than one thread it is **not reproducible**
  run to run, even with the same seed.

Like `umap-learn`, both drop to 200 epochs above 10k samples unless you
set `n_epochs` yourself.

``` r

umap_clusters_sgd <- umap(
  data = cluster_data$data,
  knn = precomputed_knn,
  umap_params = params_umap(optimiser = "sgd"),
  k = 15L,
  .verbose = TRUE
)
#> Using n_epochs = 200 (dataset >10k samples with an SGD optimiser)

umap_clusters_sgd_par <- umap(
  data = cluster_data$data,
  knn = precomputed_knn,
  umap_params = params_umap(optimiser = "sgd_parallel"),
  k = 15L,
  .verbose = TRUE
)
#> Using n_epochs = 200 (dataset >10k samples with an SGD optimiser)

umap_sgd_df <- rbind(
  as.data.table(umap_clusters_sgd)[, optimiser := "sgd"],
  as.data.table(umap_clusters_sgd_par)[, optimiser := "sgd_parallel"]
) %>%
  `colnames<-`(c("UMAP1", "UMAP2", "optimiser")) %>%
  .[, cluster := as.factor(rep(cluster_data$membership, 2L))]

ggplot(
  data = umap_sgd_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = cluster),
    alpha = 0.5,
    size = 0.75
  ) +
  facet_wrap(~optimiser, scales = "free") +
  theme_bw() +
  ggtitle("UMAP with the SGD optimisers")
```

![](umap_files/figure-html/umap%20-%20sgd-1.png)

Same picture, one of them just gets there using all your cores. On
reproducibility, don’t take my word for it:

``` r

run_twice <- function(optimiser) {
  purrr::map(1:2, \(i) {
    umap(
      data = cluster_data$data,
      knn = precomputed_knn,
      umap_params = params_umap(optimiser = optimiser),
      seed = 42L,
      .verbose = FALSE
    )
  })
}

adam_par_runs <- run_twice("adam_parallel")
sgd_par_runs <- run_twice("sgd_parallel")

c(
  adam_parallel = identical(adam_par_runs[[1]], adam_par_runs[[2]]),
  sgd_parallel = identical(sgd_par_runs[[1]], sgd_par_runs[[2]])
)
#> adam_parallel  sgd_parallel 
#>          TRUE         FALSE
```

### umap-learn 0.6: Adam and recursive initialisation

umap-learn 0.6 switched its own optimiser to Adam and added a new
initialisation. `manifoldsR` has both:

- `optimiser = "adam_v06"`: a port of the umap-learn 0.6 Adam. Not the
  same as `"adam_parallel"`: textbook Adam constants, a learning rate
  warm-up, a soft clip on the repulsion, and on large layouts “hard
  negatives” drawn from points that sit close in the current embedding.
- `init = "recursive"`: umap-learn 0.6’s recursive label propagation. It
  coarsens the graph down to at most 1024 nodes, places that from a PCA
  anchor, then lays out and expands each level on the way back up.

The two are meant to go together: only with `init = "recursive"` does
`"adam_v06"` treat the start as a good layout and use the short, gentle
warm-up. UMAP only,
[`densmap()`](https://gregorlueg.github.io/manifoldsR/reference/densmap.md)
rejects `"adam_v06"`.

``` r

umap_clusters_v06 <- umap(
  data = cluster_data$data,
  knn = precomputed_knn,
  k = 15L,
  umap_params = params_umap(optimiser = "adam_v06", init = "recursive"),
  .verbose = TRUE
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_v06_df <- rbind(
  as.data.table(umap_clusters_from_knn)[, optimiser := "adam_parallel"],
  as.data.table(umap_clusters_v06)[, optimiser := "adam_v06 + recursive"]
) %>%
  `colnames<-`(c("UMAP1", "UMAP2", "optimiser")) %>%
  .[, cluster := as.factor(rep(cluster_data$membership, 2L))]

ggplot(
  data = umap_v06_df,
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = cluster),
    alpha = 0.5,
    size = 0.75
  ) +
  facet_wrap(~optimiser, scales = "free") +
  theme_bw() +
  ggtitle("UMAP: default vs umap-learn 0.6")
```

![](umap_files/figure-html/umap%20-%20adam_v06%20clusters-1.png)

All 15 clusters separate either way. The 0.6 pair packs each cluster
tighter and leaves more empty space between them, closer to what
umap-learn itself draws these days. The arrangement differs, as you’d
expect from a different start.

``` r

umap_trajectory_v06 <- umap(
  data = trajectory_data$data,
  knn_method = "exhaustive",
  umap_params = params_umap(optimiser = "adam_v06", init = "recursive"),
  .verbose = TRUE
)
#> Using n_epochs = 500 (Adam optimiser or dataset <=10k samples)

umap_trajectory_v06_df <- rbind(
  as.data.table(umap_trajectory)[, optimiser := "adam_parallel"],
  as.data.table(umap_trajectory_v06)[, optimiser := "adam_v06 + recursive"]
) %>%
  `colnames<-`(c("UMAP1", "UMAP2", "optimiser")) %>%
  .[, branch := rep(trajectory_data$membership, 2L)]

ggplot(
  data = umap_trajectory_v06_df[sample(.N)],
  mapping = aes(x = UMAP1, y = UMAP2)
) +
  geom_point(
    mapping = aes(colour = branch),
    alpha = 0.5,
    size = 0.75
  ) +
  facet_wrap(~optimiser, scales = "free") +
  theme_bw() +
  scale_colour_viridis_c(option = "turbo") +
  ggtitle("UMAP on trajectory data: default vs umap-learn 0.6")
```

![](umap_files/figure-html/umap%20-%20adam_v06%20trajectory-1.png)

Same tree, same branch order, same blobs where the branches are dense.
The umap-learn 0.6 behaviour doesn’t fix UMAP’s habit of clumping a
continuum; pick it when you want results that line up with current
umap-learn.

### Benchmarks

How does this compare against other UMAP implementations? Let’s do a
benchmark:

``` r

# set up the venv for the Python part/dependencies
local({
  env_name <- "r-manifolds"
  # umap-learn 0.6 for the Adam + recursive init path
  py_pkgs <- c("phate", "umap-learn>=0.6", "numpy", "scipy")

  if (!reticulate::virtualenv_exists(env_name)) {
    reticulate::virtualenv_create(env_name)
    reticulate::virtualenv_install(env_name, packages = py_pkgs)
  }

  if (!reticulate::py_available()) {
    reticulate::use_virtualenv(env_name, required = TRUE)
  }

  missing_pkgs <- Filter(
    Negate(reticulate::py_module_available),
    c("phate", "umap")
  )
  installed <- reticulate::py_list_packages(env_name)
  umap_version <- installed$version[installed$package == "umap-learn"]
  outdated <- length(umap_version) == 0L ||
    utils::compareVersion(umap_version, "0.6") < 0L
  if (length(missing_pkgs) > 0L || outdated) {
    reticulate::virtualenv_install(env_name, packages = py_pkgs)
  }
})
```

``` r

benchmark_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 5000L
)

umap_py <- reticulate::import("umap")

# initialise numba properly via JIT for fair comparison
# run a small dataset...
test_reducer <- umap_py$UMAP(
  n_neighbors = 15L,
  compatibility_layout = TRUE,
  n_jobs = parallel::detectCores() - 1L
)
test <- test_reducer$fit_transform(benchmark_data$data[1:500, ])

microbenchmark::microbenchmark(
  # umap version in pure R
  umap = {
    umap::umap(
      d = benchmark_data$data,
      method = "naive"
    )
  },
  umap_reticulate = {
    reducer <- umap_py$UMAP(
      n_neighbors = 15L,
      compatibility_layout = TRUE,
      n_jobs = parallel::detectCores() - 1L
    )
    reducer$fit_transform(benchmark_data$data)
  },
  # uwot - umap, for example used in Seurat
  uwot = {
    uwot::umap(X = benchmark_data$data)
  },
  # uwot - umap2 version with parallel Adam under the hood
  # the approach that was also taken by manifoldsR
  uwot_v2 = {
    uwot::umap2(X = benchmark_data$data)
  },
  # the manifolds version
  manifold_umap = {
    umap(
      data = benchmark_data$data,
      k = 15L,
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>             expr        min         lq       mean     median         uq
#>             umap 21183.8543 21183.8543 21183.8543 21183.8543 21183.8543
#>  umap_reticulate 28929.1161 28929.1161 28929.1161 28929.1161 28929.1161
#>             uwot  6081.3642  6081.3642  6081.3642  6081.3642  6081.3642
#>          uwot_v2  2941.2551  2941.2551  2941.2551  2941.2551  2941.2551
#>    manifold_umap   726.1105   726.1105   726.1105   726.1105   726.1105
#>         max neval
#>  21183.8543     1
#>  28929.1161     1
#>   6081.3642     1
#>   2941.2551     1
#>    726.1105     1
```

The standard R version is slow (as expected). The Python version (with
numba behind the scenes) via reticulate gives some speed-up, once the
numba parts are JIT compiled.
[`uwot::umap2()`](https://jlmelville.github.io/uwot/reference/umap2.html)
and `manifoldsR` are the fastest here. Let’s pit them against each other
on a larger data set, Adam against Adam and SGD against SGD, with
umap-learn 0.6 in the mix:

- Parallel Adam:
  [`uwot::umap2()`](https://jlmelville.github.io/uwot/reference/umap2.html)
  against the default `"adam_parallel"`.
- umap-learn 0.6 Adam: umap-learn with `optimizer = "adam"` (recursive
  init plus its Adam) against `"adam_v06"` with `init = "recursive"`.
- Hogwild! SGD:
  [`uwot::umap()`](https://jlmelville.github.io/uwot/reference/umap.html)
  and umap-learn’s legacy layout (`compatibility_layout = TRUE`) against
  `"sgd_parallel"`. All three write to the embedding lock-free on all
  cores and none of them is reproducible, so the comparison is fair.

``` r

benchmark_data_2 <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 50000L
)

n_cores <- parallel::detectCores()

umap_py <- reticulate::import("umap")

# warm up the numba JIT of both umap-learn paths
test <- umap_py$UMAP(optimizer = "adam", n_jobs = n_cores)$fit_transform(
  benchmark_data_2$data[1:500, ]
)
test <- umap_py$UMAP(
  compatibility_layout = TRUE,
  n_jobs = n_cores
)$fit_transform(
  benchmark_data_2$data[1:500, ]
)

microbenchmark::microbenchmark(
  # parallel Adam
  uwot_v2 = {
    uwot::umap2(X = benchmark_data_2$data)
  },
  manifold_adam_parallel = {
    umap(
      data = benchmark_data_2$data,
      k = 15L,
      .verbose = FALSE
    )
  },
  # umap-learn 0.6 Adam with recursive init
  umap_learn_adam = {
    umap_py$UMAP(
      n_neighbors = 15L,
      optimizer = "adam",
      n_jobs = n_cores
    )$fit_transform(benchmark_data_2$data)
  },
  manifold_adam_v06 = {
    umap(
      data = benchmark_data_2$data,
      k = 15L,
      umap_params = params_umap(optimiser = "adam_v06", init = "recursive"),
      .verbose = FALSE
    )
  },
  # multi-threaded SGD
  uwot_sgd = {
    uwot::umap(
      X = benchmark_data_2$data,
      n_threads = n_cores,
      n_sgd_threads = n_cores
    )
  },
  umap_learn_sgd = {
    umap_py$UMAP(
      n_neighbors = 15L,
      compatibility_layout = TRUE,
      n_jobs = n_cores
    )$fit_transform(benchmark_data_2$data)
  },
  manifold_sgd_parallel = {
    umap(
      data = benchmark_data_2$data,
      k = 15L,
      umap_params = params_umap(optimiser = "sgd_parallel"),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: seconds
#>                    expr       min        lq      mean    median        uq
#>                 uwot_v2 20.926223 20.926223 20.926223 20.926223 20.926223
#>  manifold_adam_parallel  8.006081  8.006081  8.006081  8.006081  8.006081
#>         umap_learn_adam 24.787822 24.787822 24.787822 24.787822 24.787822
#>       manifold_adam_v06 45.530757 45.530757 45.530757 45.530757 45.530757
#>                uwot_sgd 14.121128 14.121128 14.121128 14.121128 14.121128
#>          umap_learn_sgd 10.673991 10.673991 10.673991 10.673991 10.673991
#>   manifold_sgd_parallel  5.969445  5.969445  5.969445  5.969445  5.969445
#>        max neval
#>  20.926223     1
#>   8.006081     1
#>  24.787822     1
#>  45.530757     1
#>  14.121128     1
#>  10.673991     1
#>   5.969445     1
```

Optimised memory layouts, aggressive in-lining, heavy parallelism and
look-up tables (LUTs) make this version **fast**: likely(?) the fastest
UMAP available in R. Memory stays minimal too, as the data lives in Rust
from the moment it enters the kernel until the embedding is fitted. No
round tripping through R, just compiled code throughout. The different
nearest neighbour search algorithms give additional flexibility.
