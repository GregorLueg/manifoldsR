# Wrapper function to generate EVoC parameters

Wrapper function to generate EVoC parameters

## Usage

``` r
params_evoc(
  noise_level = 0.5,
  n_epochs = 50L,
  embedding_dim = NULL,
  neighbour_scale = 1,
  symmetrise = TRUE,
  min_samples = 5L,
  base_min_cluster_size = 5L,
  approx_n_clusters = NULL,
  min_similarity_threshold = 0.2,
  max_layers = 10L
)
```

## Arguments

- noise_level:

  Numeric. Noise level for the embedding gradient. `0.0` = aggressive,
  `1.0` = conservative. Defaults to `0.5`.

- n_epochs:

  Integer. Number of embedding optimisation epochs. Defaults to `50L`.

- embedding_dim:

  Integer or `NULL`. Embedding dimensionality. If `NULL`, defaults to
  `min(max(n_neighbours / 4, 4), 16)`. Defaults to `NULL`.

- neighbour_scale:

  Numeric. Multiplier on effective neighbours for fuzzy graph
  construction. Defaults to `1.0`.

- symmetrise:

  Logical. Whether to symmetrise the fuzzy graph. Defaults to `TRUE`.

- min_samples:

  Integer. Minimum samples for core distance in MST density estimation.
  Defaults to `5L`.

- base_min_cluster_size:

  Integer. Base minimum cluster size for the finest layer. Defaults to
  `5L`.

- approx_n_clusters:

  Integer or `NULL`. If set, binary-searches for approximately this many
  clusters (single layer output). Defaults to `NULL`.

- min_similarity_threshold:

  Numeric. Jaccard similarity threshold for filtering redundant layers.
  Defaults to `0.2`.

- max_layers:

  Integer. Maximum number of cluster layers to return. Defaults to
  `10L`.

## Value

A list with the EVoC parameters.
