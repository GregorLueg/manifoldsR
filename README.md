# manifoldsR

Fast manifold learning methods implemented in Rust with R bindings.

## Overview

`manifoldsR` provides high-performance implementations of popular dimensionality reduction techniques:

- **UMAP** (Uniform Manifold Approximation and Projection)
- **t-SNE** (t-Distributed Stochastic Neighbor Embedding)
- **Synthetic data generators** for testing and benchmarking

The core algorithms are implemented in Rust for speed, with user-friendly R interfaces.

## Installation

```r
# Install from source
devtools::install()
```

## Quick Start

### UMAP

```r
library(manifoldsR)

# Basic UMAP with defaults
embedding <- umap(iris[, 1:4])

# Customize main parameters
embedding <- umap(
  data = iris[, 1:4],
  n_dim = 2,
  k = 30,
  min_dist = 0.3,
  seed = 42
)

# Plot results
plot(embedding[, 1], embedding[, 2], 
     col = iris$Species, pch = 19,
     xlab = "UMAP 1", ylab = "UMAP 2")
```

### t-SNE

```r
# Basic t-SNE with defaults
embedding <- tsne(iris[, 1:4])

# Customize main parameters
embedding <- tsne(
  data = iris[, 1:4],
  perplexity = 50,
  approx_type = "fft",  # or "bh" for Barnes-Hut
  seed = 42
)

# Plot results
plot(embedding[, 1], embedding[, 2], 
     col = iris$Species, pch = 19,
     xlab = "t-SNE 1", ylab = "t-SNE 2")
```

## Synthetic Data Generation

Generate test datasets for experimenting with manifold learning:

```r
# Swiss roll
swiss <- rs_data_swiss_role(n_samples = 1000, noise = 0.1, seed = 42)

# Clustered data
clusters <- rs_data_clusters(
  n_samples = 500, 
  dim = 10, 
  n_clusters = 5, 
  seed = 42
)

# Tree-like branching data
tree <- rs_data_tree(
  n_samples = 1000,
  dim = 50,
  n_branches = 3,
  noise = 0.05,
  seed = 42
)
```

## Advanced Usage

### UMAP Advanced Parameters

```r
# Customize advanced parameters via params
custom_params <- params_umap(
  knn_method = "annoy",      # "hnsw" or "annoy"
  optimiser = "sgd",         # "adam_parallel" or "sgd"
  init = "pca",              # "spectral" or "pca"
  n_epochs = 1000            # Override automatic detection
)

embedding <- umap(
  data = my_data,
  n_dim = 3,
  k = 30,
  min_dist = 0.3,
  spread = 2.0,
  params = custom_params,
  verbose = TRUE
)

# Automatic n_epochs detection:
# - Uses 500 epochs for datasets <10,000 samples OR with "adam_parallel"
# - Uses 200 epochs for datasets >=10,000 samples with "sgd"/"adam"
# - User-specified values always override automatic detection
params_auto <- params_umap(optimiser = "sgd")  # n_epochs determined automatically
```

### t-SNE Advanced Parameters

```r
# Customize advanced parameters via params
custom_params <- params_tsne(
  knn_method = "hnsw",        # "hnsw" or "annoy"
  dist_metric = "cosine",     # "euclidean", "cosine", or "manhattan"
  theta = 0.3                 # Barnes-Hut theta parameter
)

embedding <- tsne(
  data = my_data,
  perplexity = 50,
  approx_type = "fft",        # "bh" or "fft"
  params = custom_params,
  verbose = TRUE
)
```

## Input Validation

Both `umap()` and `tsne()` perform comprehensive input validation to prevent errors:

- ✓ Automatic conversion of data frames to matrices
- ✓ Validation of parameter ranges and types
- ✓ Checking for missing values
- ✓ Ensuring sufficient data for requested parameters

Invalid inputs are caught early with informative error messages before passing to the Rust backend.

## Performance

The Rust implementation provides significant performance improvements over pure R implementations, especially for large datasets. The package supports:

- Parallel optimization (UMAP with `optimiser = "adam_parallel"`)
- Approximate nearest neighbor methods (HNSW, Annoy)
- FFT-accelerated t-SNE for faster computation

## License

[Your license here]
