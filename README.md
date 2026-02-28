# manifoldsR

![r_package](https://img.shields.io/badge/R_package-0.0.1.3-orange) 
<!-- [![CI](https://github.com/GregorLueg/genewalkR/actions/workflows/R-cmd-check.yml/badge.svg)](https://github.com/GregorLueg/genewalkR/actions/workflows/R-cmd-check.yml) -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Fast(!)** manifold learning methods implemented in Rust with R bindings.

## Overview

`manifoldsR` provides high-performance implementations of popular dimensionality reduction techniques:

- **UMAP** (Uniform Manifold Approximation and Projection)
- **t-SNE** (t-Distributed Stochastic Neighbor Embedding)
- **Synthetic data generators** for testing and benchmarking

The core algorithms are implemented in Rust for speed while providing user-friendly R interfaces.

## Installation

### Prerequisites

This package requires Rust to be installed on your system. If you don't have Rust installed:

**macOS and Linux:**

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Windows:**

Download and run the installer from [rustup.rs](https://rustup.rs/)

After installation, restart your terminal and verify Rust is installed:

```bash
rustc --version
```

### Install manifoldsR

```r
# Install from source
remotes::install_github("GregorLueg/manifoldsR")
```

## Synthetic Data Generation

The package includes generators for common test datasets used in manifold learning:

### Swiss Roll

```r
library(manifoldsR)
library(ggplot2)

# Generate Swiss roll data
swissrole <- rs_data_swiss_role(
  n_samples = 100000L,
  noise = 0.1,
  seed = 42L
)

# Visualise with UMAP
umap_swiss <- umap(
  data = swissrole,
  n_dim = 2,
  min_dist = 0.1,
  k = 5L,
  params = params_umap(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "pca",
    n_epochs = 500L
  ),
  seed = 42L,
  verbose = TRUE
)

# Plot results
umap_df <- as.data.frame(umap_swiss)
colnames(umap_df) <- c("UMAP1", "UMAP2")
umap_df$z_axis <- swissrole[, 3]

ggplot(umap_df, aes(x = UMAP1, y = UMAP2, colour = z_axis)) +
  geom_point()
```

### Clustered Data

```r
# Generate clustered data
cluster_result <- rs_data_clusters(
  n_samples = 100000L,
  dim = 32L,
  n_clusters = 15L,
  seed = 42L
)

cluster_data <- cluster_result$data
cluster_membership <- cluster_result$clusters

# Apply UMAP
umap_clusters <- umap(
  data = cluster_data,
  n_dim = 2,
  min_dist = 0.5,
  k = 15L,
  params = params_umap(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "spectral",
    n_epochs = 500L,
    randomised = TRUE
  ),
  seed = 42L,
  verbose = TRUE
)

# Plot results
umap_df <- as.data.frame(umap_clusters)
colnames(umap_df) <- c("UMAP1", "UMAP2")
umap_df$cluster <- as.factor(cluster_membership)

ggplot(umap_df, aes(x = UMAP1, y = UMAP2, colour = cluster)) +
  geom_point()
```

### Tree-like Branching Data

```r
# Generate tree data with branches
tree_result <- rs_data_tree(
  n_samples = 100000L,
  dim = 32L,
  n_branches = 25L,
  noise = 0.1,
  seed = 42L
)

tree_data <- tree_result$data
branch_membership <- tree_result$clusters

# Apply t-SNE
tsne_tree <- tsne(
  data = tree_data,
  n_dim = 2,
  perplexity = 30,
  approx_type = "bh",
  params = params_tsne(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)

# Plot results
tsne_df <- as.data.frame(tsne_tree)
colnames(tsne_df) <- c("tSNE1", "tSNE2")
tsne_df$branch <- as.factor(branch_membership)

ggplot(tsne_df, aes(x = tSNE1, y = tSNE2, colour = branch)) +
  geom_point()
```

## UMAP Examples

### Basic Usage

```r
# Simple UMAP with defaults
embedding <- umap(iris[, 1:4])

# Basic customisation
embedding <- umap(
  data = iris[, 1:4],
  n_dim = 2,
  k = 30,
  min_dist = 0.3,
  seed = 42
)
```

### Advanced Parameters

```r
# Full control over UMAP parameters
embedding <- umap(
  data = cluster_data,
  n_dim = 2,
  min_dist = 0.5,
  spread = 1,
  k = 15L,
  params = params_umap(
    knn_method = "hnsw",        # or "annoy", "NNDescent"
    optimiser = "adam_parallel", # or "sgd", "adam", "random"
    init = "spectral",          # or "pca"
    n_epochs = 500L,            # NULL for automatic detection
    randomised = TRUE
  ),
  seed = 42L,
  verbose = TRUE
)
```

### Automatic Epoch Detection

```r
# When n_epochs = NULL, automatically determined based on data size:
# - 500 epochs for datasets <10,000 samples OR with "adam_parallel"
# - 200 epochs for datasets >=10,000 samples with "sgd"/"adam"

params_auto <- params_umap(optimiser = "sgd")  # n_epochs = NULL
embedding <- umap(data = large_dataset, params = params_auto, verbose = TRUE)
# Using n_epochs = 200 (dataset >=10k samples with sgd/adam optimiser)
```

## t-SNE Examples

### Basic Usage

```r
# Simple t-SNE with defaults
embedding <- tsne(iris[, 1:4])

# Customise main parameters
embedding <- tsne(
  data = iris[, 1:4],
  perplexity = 50,
  approx_type = "fft",  # or "bh" for Barnes-Hut
  seed = 42
)
```

### Advanced Parameters

```r
# Full control over t-SNE parameters
embedding <- tsne(
  data = cluster_data,
  n_dim = 2,
  perplexity = 50,
  approx_type = "bh",
  params = params_tsne(
    knn_method = "hnsw",         # or "annoy", "NNDescent"
    dist_metric = "euclidean",   # or "cosine", "manhattan"
    theta = 0.5                  # Barnes-Hut approximation parameter
  ),
  seed = 123L,
  verbose = TRUE
)

# FFT-accelerated version for large datasets
embedding_fft <- tsne(
  data = swissrole,
  n_dim = 2,
  perplexity = 50,
  approx_type = "fft",
  params = params_tsne(
    knn_method = "hnsw",
    dist_metric = "euclidean",
    theta = 0.5
  ),
  seed = 123L,
  verbose = TRUE
)
```

## Performance Benchmarks

### UMAP: manifoldsR vs uwot

Using 100,000 cells (32 dimensions, 15 clusters) with 500 epochs:

```r
library(tictoc)

# uwot::umap2() with adam optimiser
tic()
uwot_result <- uwot::umap2(
  X = cluster_data,
  n_epochs = 500L,
  verbose = TRUE
)
toc()
# 11.688 sec elapsed

# manifoldsR::umap() with adam_parallel optimiser
tic()
manifolds_result <- umap(
  data = cluster_data,
  n_dim = 2,
  min_dist = 0.5,
  spread = 1,
  k = 15L,
  params = params_umap(
    knn_method = "hnsw",
    optimiser = "adam_parallel",
    init = "pca",
    n_epochs = 500L,
    randomised = TRUE
  ),
  seed = 42L,
  verbose = TRUE
)
toc()
# 8.696 sec elapsed
```

**manifoldsR is 1.34x faster** (11.69s vs 8.70s)

### Large Dataset: 500,000 cells

```r
# uwot::umap2()
tic()
uwot_large <- uwot::umap2(X = large_cluster_data, n_epochs = 500L, verbose = TRUE)
toc()
# 69.035 sec elapsed

# manifoldsR::umap()
tic()
manifolds_large <- umap(
  data = large_cluster_data,
  params = params_umap(optimiser = "adam_parallel", n_epochs = 500L),
  verbose = TRUE
)
toc()
# 58.28 sec elapsed
```

**manifoldsR is 1.18x faster** (69.04s vs 58.28s)

### Fair Comparison: SGD Optimiser

Comparing against `uwot::umap()` (SGD) with 100,000 cells, 200 epochs:

```r
# uwot::umap()
tic()
uwot_sgd <- uwot::umap(X = cluster_data, n_epochs = 200L, verbose = TRUE)
toc()
# 34.71 sec elapsed

# manifoldsR::umap() with SGD
tic()
manifolds_sgd <- umap(
  data = cluster_data,
  params = params_umap(
    optimiser = "sgd",
    init = "pca",
    n_epochs = 200L
  ),
  verbose = TRUE
)
toc()
# Comparable performance with SGD optimiser
```

## Performance Features

- ✓ **Parallel optimisation**: UMAP with `optimiser = "adam_parallel"` leverages multi-core processing
- ✓ **Multiple KNN methods**: HNSW (fast, approximate), Annoy (balanced), NNDescent (exact)
- ✓ **FFT-accelerated t-SNE**: Faster computation for large datasets vs Barnes-Hut
- ✓ **Memory-efficient Rust implementation**: Lower overhead and better cache utilisation
- ✓ **Flexible initialisation**: Spectral (default) or PCA-based initialisation for UMAP

## Input Validation

Both `umap()` and `tsne()` perform comprehensive input validation to prevent errors:

- ✓ Automatic conversion of data frames to matrices
- ✓ Validation of parameter ranges and types
- ✓ Checking for missing values
- ✓ Ensuring sufficient data for requested parameters

Invalid inputs are caught early with informative error messages before passing to the Rust backend.
