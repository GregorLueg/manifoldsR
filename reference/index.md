# Package index

## 2D embedding methods

The core functions to generate the 2D embeddings

- [`tsne()`](https://gregorlueg.github.io/manifoldsR/reference/tsne.md)
  : Rust-based t-SNE
- [`umap()`](https://gregorlueg.github.io/manifoldsR/reference/umap.md)
  : Rust-based UMAP
- [`densmap()`](https://gregorlueg.github.io/manifoldsR/reference/densmap.md)
  : Rust-based densMAP
- [`densne()`](https://gregorlueg.github.io/manifoldsR/reference/densne.md)
  : Rust-based den-SNE
- [`phate()`](https://gregorlueg.github.io/manifoldsR/reference/phate.md)
  : Rust-based PHATE
- [`pacmap()`](https://gregorlueg.github.io/manifoldsR/reference/pacmap.md)
  : Rust-based PaCMAP
- [`diffusion_maps()`](https://gregorlueg.github.io/manifoldsR/reference/diffusion_maps.md)
  : Rust-based diffusion maps

## kNN helpers

Everything and anything around kNN graph generation

- [`generate_knn_graph()`](https://gregorlueg.github.io/manifoldsR/reference/generate_knn_graph.md)
  : Generate a k-nearest neighbour graph.
- [`new_nearest_neighbour()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md)
  [`generate_nearest_neigbours_class()`](https://gregorlueg.github.io/manifoldsR/reference/new_nearest_neighbour.md)
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

## Clustering algorithms

Various methods to do clustering in manifoldsR

- [`best_membership()`](https://gregorlueg.github.io/manifoldsR/reference/best_membership.md)
  : Get the cluster membership at the best persistence score
- [`calc_ari()`](https://gregorlueg.github.io/manifoldsR/reference/calc_ari.md)
  : Adjusted Rand index calculation
- [`calc_inertia()`](https://gregorlueg.github.io/manifoldsR/reference/calc_inertia.md)
  : Calculate the cluster inertia
- [`calc_silhouette_score()`](https://gregorlueg.github.io/manifoldsR/reference/calc_silhouette_score.md)
  : Calculates the Silhouette score of a given clustering
- [`evoc()`](https://gregorlueg.github.io/manifoldsR/reference/evoc.md)
  : Rust-based EVoC clustering
- [`get_centroids()`](https://gregorlueg.github.io/manifoldsR/reference/get_centroids.md)
  : Get cluster centroids
- [`get_layer()`](https://gregorlueg.github.io/manifoldsR/reference/get_layer.md)
  : Get a specific EVoC layer
- [`get_nearest_neighbours()`](https://gregorlueg.github.io/manifoldsR/reference/get_nearest_neighbours.md)
  : Get the kNN graph from an Evoc object
- [`kmeans_cluster()`](https://gregorlueg.github.io/manifoldsR/reference/kmeans_cluster.md)
  : K-means clustering
- [`membership()`](https://gregorlueg.github.io/manifoldsR/reference/membership.md)
  : Get cluster assignments

## Params

Wrapper functions around core parameters

- [`params_clusters()`](https://gregorlueg.github.io/manifoldsR/reference/params_clusters.md)
  : Parameters for clustered data generation
- [`params_densmap()`](https://gregorlueg.github.io/manifoldsR/reference/params_densmap.md)
  : Wrapper function to generate densMAP parameters
- [`params_densne()`](https://gregorlueg.github.io/manifoldsR/reference/params_densne.md)
  : Wrapper function to generate den-SNE parameters
- [`params_evoc()`](https://gregorlueg.github.io/manifoldsR/reference/params_evoc.md)
  : Wrapper function to generate EVoC parameters
- [`params_hierarchical()`](https://gregorlueg.github.io/manifoldsR/reference/params_hierarchical.md)
  : Parameters for hierarchical cluster data generation
- [`params_kmeans()`](https://gregorlueg.github.io/manifoldsR/reference/params_kmeans.md)
  : Wrapper function to generate k-means parameters
- [`params_nn()`](https://gregorlueg.github.io/manifoldsR/reference/params_nn.md)
  : Wrapper function to generate nearest neighbour parameters
- [`params_pacmap()`](https://gregorlueg.github.io/manifoldsR/reference/params_pacmap.md)
  : Wrapper function to generate PaCMAP parameters
- [`params_diffusion_maps()`](https://gregorlueg.github.io/manifoldsR/reference/params_diffusion_maps.md)
  : Wrapper function to generate diffusion maps parameters
- [`params_phate()`](https://gregorlueg.github.io/manifoldsR/reference/params_phate.md)
  : Wrapper function to generate PHATE parameters
- [`params_umap()`](https://gregorlueg.github.io/manifoldsR/reference/params_umap.md)
  : Wrapper function to generate UMAP parameters
- [`params_swiss_role()`](https://gregorlueg.github.io/manifoldsR/reference/params_swiss_role.md)
  : Parameters for swiss roll data generation
- [`params_swiss_role_biased()`](https://gregorlueg.github.io/manifoldsR/reference/params_swiss_role_biased.md)
  : Parameters for swiss roll data generation
- [`params_trajectory()`](https://gregorlueg.github.io/manifoldsR/reference/params_trajectory.md)
  : Parameters for trajectory data generation
- [`params_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/params_tsne.md)
  : Wrapper function to generate t-SNE parameters

## Rust wrappers

Everything rusty - only use this if you know what you are doing…

- [`rs_approx_nearest_neighbours()`](https://gregorlueg.github.io/manifoldsR/reference/rs_approx_nearest_neighbours.md)
  **\[experimental\]** : Wrapper around some nearest neighbour searches
  integrated into manifold-rs
- [`rs_ari()`](https://gregorlueg.github.io/manifoldsR/reference/rs_ari.md)
  **\[experimental\]** : Adjusted Rand index
- [`rs_data_biased_swiss_role()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_biased_swiss_role.md)
  **\[experimental\]** : Generates the SwissRole data
- [`rs_data_clusters()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_clusters.md)
  **\[experimental\]** : Generates clustered data
- [`rs_data_swiss_role()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_swiss_role.md)
  **\[experimental\]** : Generates the SwissRole data
- [`rs_data_trajectory()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_trajectory.md)
  **\[experimental\]** : Generates tree-like data with branches
- [`rs_data_hierarchical()`](https://gregorlueg.github.io/manifoldsR/reference/rs_data_hierarchical.md)
  **\[experimental\]** : Generate hierarchical cluster data
- [`rs_densmap()`](https://gregorlueg.github.io/manifoldsR/reference/rs_densmap.md)
  **\[experimental\]** : densMAP implementation
- [`rs_densmap_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_densmap_from_knn.md)
  **\[experimental\]** : densMAP implementation
- [`rs_densne()`](https://gregorlueg.github.io/manifoldsR/reference/rs_densne.md)
  **\[experimental\]** : den-SNE implementation
- [`rs_densne_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_densne_from_knn.md)
  **\[experimental\]** : den-SNE implementation
- [`rs_diffusion_maps()`](https://gregorlueg.github.io/manifoldsR/reference/rs_diffusion_maps.md)
  **\[experimental\]** : Diffusion maps implementation
- [`rs_diffusion_maps_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_diffusion_maps_from_knn.md)
  **\[experimental\]** : Diffusion maps implementation with pre-computed
  kNN
- [`rs_evoc()`](https://gregorlueg.github.io/manifoldsR/reference/rs_evoc.md)
  **\[experimental\]** : EVoC clustering
- [`rs_evoc_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_evoc_from_knn.md)
  **\[experimental\]** : EVoC clustering from pre-computed kNN
- [`rs_intertia()`](https://gregorlueg.github.io/manifoldsR/reference/rs_intertia.md)
  **\[experimental\]** : Calculates the intertia for k-means clustering
- [`rs_k_means()`](https://gregorlueg.github.io/manifoldsR/reference/rs_k_means.md)
  **\[experimental\]** : K-means clustering (full)
- [`rs_k_means_mini_batch()`](https://gregorlueg.github.io/manifoldsR/reference/rs_k_means_mini_batch.md)
  **\[experimental\]** : Mini-batch k-means clustering
- [`rs_pacmap()`](https://gregorlueg.github.io/manifoldsR/reference/rs_pacmap.md)
  **\[experimental\]** : PaCMAP implementation
- [`rs_pacmap_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_pacmap_from_knn.md)
  **\[experimental\]** : PaCMAP implementation with pre-computed kNN
- [`rs_phate()`](https://gregorlueg.github.io/manifoldsR/reference/rs_phate.md)
  **\[experimental\]** : Run PHATE dimensionality reduction
- [`rs_phate_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_phate_from_knn.md)
  **\[experimental\]** : Run PHATE dimensionality reduction from a
  precomputed kNN graph
- [`rs_silhouette_score()`](https://gregorlueg.github.io/manifoldsR/reference/rs_silhouette_score.md)
  **\[experimental\]** : Calculates the cluster silhouette scores
- [`rs_tsne()`](https://gregorlueg.github.io/manifoldsR/reference/rs_tsne.md)
  **\[experimental\]** : tSNE implementation
- [`rs_tsne_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_tsne_from_knn.md)
  **\[experimental\]** : tSNE implementation
- [`rs_umap()`](https://gregorlueg.github.io/manifoldsR/reference/rs_umap.md)
  **\[experimental\]** : UMAP implementation
- [`rs_umap_from_knn()`](https://gregorlueg.github.io/manifoldsR/reference/rs_umap_from_knn.md)
  **\[experimental\]** : UMAP implementation
