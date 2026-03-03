# Package index

## Main functions

The core functions to generate the 2D embeddings

- [`tsne()`](https://gregorlueg.github.io/manifoldsR/reference/tsne.md)
  : Rust-based t-SNE
- [`umap()`](https://gregorlueg.github.io/manifoldsR/reference/umap.md)
  : Rust-based UMAP
- [`phate()`](https://gregorlueg.github.io/manifoldsR/reference/phate.md)
  : Rust-based PHATE

## kNN helpers

Everything and anything around kNN graph generation

- [`generate_knn_graph()`](https://gregorlueg.github.io/manifoldsR/reference/generate_knn_graph.md)
  : Generate a k-nearest neighbour graph.
- [`generate_nearest_neigbours_class()`](https://gregorlueg.github.io/manifoldsR/reference/generate_nearest_neigbours_class.md)
  : Generate a new NearestNeighbours
- [`get_idx_mat()`](https://gregorlueg.github.io/manifoldsR/reference/get_idx_mat.md)
  : Get the indices as a matrix
- [`get_idx_flat()`](https://gregorlueg.github.io/manifoldsR/reference/get_idx_flat.md)
  : Get the indices as a flat vector
- [`get_dist_mat()`](https://gregorlueg.github.io/manifoldsR/reference/get_dist_mat.md)
  : Get the indices as a matrix
- [`get_dist_flat()`](https://gregorlueg.github.io/manifoldsR/reference/get_dist_flat.md)
  : Get the distances as a flat vector

## Synthetic data

- [`manifold_synthetic_data()`](https://gregorlueg.github.io/manifoldsR/reference/manifold_synthetic_data.md)
  : Generate synthetic data for manifold learning

## Params

Wrapper functions around core parameters

- [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md)
  : Wrapper function to generate nearest neighbour parameters
- [`params_umap()`](https://gregorlueg.github.io/manifoldsR/reference/params_umap.md)
  : Wrapper function to generate UMAP parameters
- [`params_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/params_tsne.md)
  : Wrapper function to generate t-SNE parameters
- [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md)
  : Wrapper function to generate PHATE parameters

## Rust wrappers

Everything rusty - only use this if you know what you are doing…

- [`rs_approx_nearest_neighbours()`](https://gregorlueg.github.io/manifoldsR/reference/rs_approx_nearest_neighbours.md)
  : Wrapper around some nearest neighbour searches integrated into
  manifold-rs
- [`rs_data_clusters()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_clusters.md)
  : Generates clustered data
- [`rs_data_swiss_role()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_swiss_role.md)
  : Generates the SwissRole data
- [`rs_data_trajectory()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_trajectory.md)
  : Generates tree-like data with branches
- [`rs_phate()`](https://gregorlueg.github.io/manifoldsR/reference/rs_phate.md)
  : Run PHATE dimensionality reduction
- [`rs_phate_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_phate_from_knn.md)
  : Run PHATE dimensionality reduction from a precomputed kNN graph
- [`rs_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/rs_tsne.md)
  : tSNE implementation
- [`rs_tsne_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_tsne_from_knn.md)
  : tSNE implementation
- [`rs_umap()`](https://gregorlueg.github.io/manifoldsR/reference/rs_umap.md)
  : UMAP implementation
- [`rs_umap_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_umap_from_knn.md)
  : UMAP implementation
- [`rs_check_cluster_separation()`](https://gregorlueg.github.io/manifoldsR/reference/rs_check_cluster_separation.md)
  : Check cluster separation in an embedding
