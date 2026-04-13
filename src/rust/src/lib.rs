//! Rust to R function implementations, exposing the manifolds-rs,
//! ann-search-rs and evoc-rs functionality to R.

#![allow(clippy::needless_range_loop)]

pub mod evoc;
pub mod k_means;
pub mod metrics;
pub mod pacmap;
pub mod phate;
pub mod tsne;
pub mod umap;
pub mod utils;

use ann_search_rs::utils::k_means_utils::*;
use ann_search_rs::utils::matrix_to_flat;
use bixverse_rs::prelude::*;
use bixverse_rs::utils::vec_utils::flatten_vector;
use extendr_api::prelude::*;
use manifolds_rs::data::synthetic::BranchSpec;
use manifolds_rs::prelude::*;

use crate::evoc::*;
use crate::k_means::*;
use crate::metrics::*;
use crate::pacmap::*;
use crate::phate::*;
use crate::tsne::*;
use crate::umap::*;
use crate::utils::*;

////////////////////
// ExtendR module //
////////////////////

extendr_module! {
    mod manifoldsR;
    // embeddings
    fn rs_umap;
    fn rs_umap_from_knn;
    fn rs_tsne;
    fn rs_tsne_from_knn;
    fn rs_phate;
    fn rs_phate_from_knn;
    fn rs_pacmap;
    fn rs_pacmap_from_knn;
    // clustering
    fn rs_evoc;
    fn rs_evoc_from_knn;
    fn rs_k_means;
    fn rs_k_means_mini_batch;
    // nn utils
    fn rs_approx_nearest_neighbours;
    // synthetic data
    fn rs_data_swiss_role;
    fn rs_data_clusters;
    fn rs_data_trajectory;
    fn rs_data_hierarchical;
    // metrics
    fn rs_check_cluster_separation;
    fn rs_ari;
    fn rs_silhouette_score;
    fn rs_intertia;
}

//////////
// UMAP //
//////////

/// UMAP implementation
///
/// @description This is the wrapper function into the Rust interface for UMAP.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param n_dim Integer. Number of UMAP dimensions to return.
/// @param min_dist Numeric. Minimum distance to use.
/// @param spread Numeric. Spread parameter to use.
/// @param k Integer. Number of nearest neighbours to consider
/// @param umap_params Named list. List that contains all of the key parameters
/// for the UMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The UMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_umap(
    embd: RMatrix<f64>,
    n_dim: usize,
    min_dist: f64,
    spread: f64,
    k: usize,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let res = umap_manifold(
        embd.as_ref(),
        None,
        n_dim,
        k,
        min_dist as f32,
        spread as f32,
        umap_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}

/// UMAP implementation
///
/// @description This is the wrapper function into the Rust interface for UMAP
/// and can use a pre-computed kNN.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param knn_data `NearestNeighbours` class from R.
/// @param n_dim Integer. Number of UMAP dimensions to return.
/// @param min_dist Numeric. Minimum distance to use.
/// @param spread Numeric. Spread parameter to use.
/// @param k Integer. Number of nearest neighbours to consider
/// @param umap_params Named list. List that contains all of the key parameters
/// for the UMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The UMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_umap_from_knn(
    embd: RMatrix<f64>,
    knn_data: List,
    n_dim: usize,
    min_dist: f64,
    spread: f64,
    k: usize,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let knn = nearest_neighbours_to_rust(knn_data);

    let res = umap_manifold(
        embd.as_ref(),
        knn,
        n_dim,
        k,
        min_dist as f32,
        spread as f32,
        umap_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}

//////////
// tSNE //
//////////

/// tSNE implementation
///
/// @description This is the wrapper function into the Rust interface for tSNE.
/// You have the option to use the Barnes-Hut implemetation or the
/// FFT-accelerated version to approximate the repulsive forces.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param n_dim Integer. Number of tSNE dimensions to return. Needs to be two,
/// others are not supported.
/// @param perplexity Numeric. The tSNE perplexity parameter.
/// @param approx_type String. One of `c("fft", "bh")`. Which of the two
/// approximations to use.
/// @param tsne_params Named list. List that contains all of the key parameters
/// for the tSNE generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The tSNE embeddings.
///
/// @export
#[extendr]
fn rs_tsne(
    embd: RMatrix<f64>,
    n_dim: usize,
    perplexity: f64,
    approx_type: String,
    tsne_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let res = tsne_simple(
        embd.as_ref(),
        None,
        n_dim,
        &approx_type,
        perplexity as f32,
        tsne_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}

/// tSNE implementation
///
/// @description This is the wrapper function into the Rust interface for tSNE.
/// You have the option to use the Barnes-Hut implemetation or the
/// FFT-accelerated version to approximate the repulsive forces. This one
/// can use a pre-computed kNN.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param knn_data `NearestNeighbours` class from R.
/// @param n_dim Integer. Number of tSNE dimensions to return. Needs to be two,
/// others are not supported.
/// @param perplexity Numeric. The tSNE perplexity parameter.
/// @param approx_type String. One of `c("fft", "bh")`. Which of the two
/// approximations to use.
/// @param tsne_params Named list. List that contains all of the key parameters
/// for the tSNE generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The tSNE embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_tsne_from_knn(
    embd: RMatrix<f64>,
    knn_data: List,
    n_dim: usize,
    perplexity: f64,
    approx_type: String,
    tsne_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let knn = nearest_neighbours_to_rust(knn_data);

    let res = tsne_simple(
        embd.as_ref(),
        knn,
        n_dim,
        &approx_type,
        perplexity as f32,
        tsne_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}

///////////
// PHATE //
///////////

/// Run PHATE dimensionality reduction
///
/// @description Wrapper function into the Rust interface for PHATE.
/// Constructs a kNN graph, computes alpha decay affinities, powers the
/// diffusion operator to time `t`, and embeds via MDS on the resulting
/// diffusion potential distances.
///
/// @param embd Numerical matrix. The data to embed of shape samples x
/// features.
/// @param n_dim Integer. Number of PHATE dimensions to return. Currently only
/// `2L` is supported.
/// @param k Integer. Number of nearest neighbours for graph construction.
/// @param phate_params Named list. Contains all key parameters for PHATE,
/// see [params_phate()] and [params_nn()].
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The PHATE embedding as a matrix of shape samples x n_dim.
///
/// @export
#[extendr]
fn rs_phate(
    embd: RMatrix<f64>,
    n_dim: usize,
    k: usize,
    phate_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);
    let res = phate_simple(embd.as_ref(), None, n_dim, k, phate_params, seed, verbose);
    faer_to_r_matrix(res.as_ref())
}

/// Run PHATE dimensionality reduction from a precomputed kNN graph
///
/// @description Wrapper function into the Rust interface for PHATE using a
/// precomputed kNN graph. Useful when iterating over diffusion parameters
/// without repeating the neighbour search.
///
/// @param embd Numerical matrix. The data to embed of shape samples x
/// features.
/// @param knn_data `NearestNeighbours` class from R.
/// @param n_dim Integer. Number of PHATE dimensions to return. Currently only
/// `2L` is supported.
/// @param k Integer. Number of nearest neighbours used during graph
/// construction. Must match the k used to generate `knn_data`.
/// @param phate_params Named list. Contains all key parameters for PHATE,
/// see [params_phate()] and [params_nn()].
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The PHATE embedding as a matrix of shape samples x n_dim.
///
/// @export
#[extendr]
fn rs_phate_from_knn(
    embd: RMatrix<f64>,
    knn_data: List,
    n_dim: usize,
    k: usize,
    phate_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);
    let knn = nearest_neighbours_to_rust(knn_data);
    let res = phate_simple(embd.as_ref(), knn, n_dim, k, phate_params, seed, verbose);
    faer_to_r_matrix(res.as_ref())
}

////////////
// PaCMAP //
////////////

/// PaCMAP implementation
///
/// @description This is the wrapper function into the Rust interface for
/// PaCMAP.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param n_dim Integer. Number of dimensions to return.
/// @param k Integer. Number of nearest neighbours to consider.
/// @param pacmap_params Named list. List that contains all of the key
/// parameters for the PaCMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The PaCMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_pacmap(
    embd: RMatrix<f64>,
    n_dim: usize,
    k: usize,
    pacmap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);
    let res = pacmap_manifold(embd.as_ref(), None, n_dim, k, pacmap_params, seed, verbose);
    faer_to_r_matrix(res.as_ref())
}

/// PaCMAP implementation with pre-computed kNN
///
/// @description This is the wrapper function into the Rust interface for
/// PaCMAP and can use a pre-computed kNN.
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param knn_data `NearestNeighbours` class from R.
/// @param n_dim Integer. Number of dimensions to return.
/// @param k Integer. Number of nearest neighbours to consider.
/// @param pacmap_params Named list. List that contains all of the key
/// parameters for the PaCMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The PaCMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_pacmap_from_knn(
    embd: RMatrix<f64>,
    knn_data: List,
    n_dim: usize,
    k: usize,
    pacmap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);
    let knn = nearest_neighbours_to_rust(knn_data);
    let res = pacmap_manifold(embd.as_ref(), knn, n_dim, k, pacmap_params, seed, verbose);
    faer_to_r_matrix(res.as_ref())
}

/////////////////////////
// Synthetic data sets //
/////////////////////////

/// Generates the SwissRole data
///
/// @description Generates synthetic data, i.e., the Swiss role to test
/// different manifold learning techniques
///
/// @param n_samples Integer. Number of data points to generate.
/// @param noise Numeric. How much noise to add.
/// @param seed Integer. For reproducibility purposes
///
/// @return The Swiss role synthetic data with the desired parameters.
///
/// @export
#[extendr]
fn rs_data_swiss_role(n_samples: usize, noise: f64, seed: usize) -> RMatrix<f64> {
    let res = generate_swiss_roll(n_samples, noise, seed as u64);

    faer_to_r_matrix(res.as_ref())
}

/// Generates clustered data
///
/// @description Generates synthetic data with clear cluster structure.
///
/// @param n_samples Integer. Number of data points to generate.
/// @param dim Integer. Dimensionality of the data
/// @param n_clusters Integer. Number of clusters to produce in the data.
/// @param seed Integer. For reproducibility purposes
///
/// @return A list with the following elements:
/// \itemize{
///  \item data - Numerical matrix with the data.
///  \item clusters - Cluster assignments
/// }
///
/// @export
#[extendr]
fn rs_data_clusters(n_samples: usize, dim: usize, n_clusters: usize, seed: usize) -> List {
    let (res, clusters) = generate_clustered_data(n_samples, dim, n_clusters, seed as u64);

    list!(data = faer_to_r_matrix(res.as_ref()), clusters = clusters)
}

/// Generates tree-like data with branches
///
/// @description Generates synthetic data that has a tree-like structure to
/// simulate evolution/trajectory of data.
///
/// @param n_samples Integer. Number of data points to generate.
/// @param dim Integer. Dimensionality of the data.
/// @param topology String. One of `c("bifurcation", "linear", "combination")`.
/// @param cell_trajectories List or NULL. Named list with three equal-length
///   vectors: `parent` (integer, NA for root, zero-indexed), `split_at`
///   (numeric, fraction along parent where branch starts), and `length`
///   (numeric, length of the branch). If NULL, will use the topology specified
///   in topology.
/// @param noise Numeric. How much noise to add.
/// @param seed Integer. For reproducibility purposes.
///
/// @return A list with the following elements:
/// \itemize{
///  \item data - Numerical matrix with the generated data.
///  \item branches - Branch assignments for each sample.
/// }
///
/// @export
#[extendr]
fn rs_data_trajectory(
    n_samples: usize,
    dim: usize,
    topology: String,
    cell_trajectories: Nullable<List>,
    noise: f64,
    seed: usize,
) -> List {
    // parse potentially provided cell_trajectories
    let branches: Vec<BranchSpec> = match cell_trajectories {
        NotNull(list) => parse_branch_specs(list).unwrap(),
        _ => {
            let topology = parse_topology(&topology).unwrap_or_default();
            generate_example_branches(&topology)
        }
    };

    let (res, branches) = generate_trajectory(n_samples, &branches, dim, noise, seed as u64);

    list!(data = faer_to_r_matrix(res.as_ref()), branches = branches)
}

/// Generate hierarchical cluster data
///
/// @description Generates synthetic data with a two-level cluster hierarchy:
/// `n_supergroups` top-level groups each containing `n_subclusts` tight
/// subclusters. Supergroup centres are spread far apart; subcluster centres sit
/// tightly around their supergroup centre.
///
/// Note that the actual number of samples returned may be slightly less than
/// `n_samples` if it is not evenly divisible by `n_supergroups * n_subclusts`.
///
/// @param n_samples Integer. Total number of points, distributed evenly across
/// all subclusters.
/// @param dim Integer. Dimensionality of the ambient space.
/// @param n_supergroups Integer. Number of top-level groups. Defaults to `3`.
/// @param n_subclusts Integer. Number of subclusters per supergroup. Defaults
/// to `3`.
/// @param supergroup_spread Numeric. Spread of supergroup centres. Defaults to
/// `15.0`.
/// @param subcluster_spread Numeric. Spread of subcluster centres around their
/// supergroup centre. Defaults to `2.0`.
/// @param point_std Numeric. Within-subcluster Gaussian noise. Defaults to
/// `0.4`.
/// @param seed Integer. Seed for reproducibility.
///
/// @return A named list with three elements: `data`, a numeric matrix of shape
/// samples x `dim`; `supergroup`, an integer vector of supergroup labels
/// (`0..n_supergroups`) one per sample; and `subgroup`, an integer vector of
/// subcluster labels (`0..n_supergroups * n_subclusts`) one per sample.
///
/// @export
#[allow(clippy::too_many_arguments)]
#[extendr]
fn rs_data_hierarchical(
    n_samples: usize,
    dim: usize,
    n_supergroups: usize,
    n_subclusts: usize,
    supergroup_spread: f64,
    subcluster_spread: f64,
    point_std: f64,
    seed: u64,
) -> List {
    let (res, supergroup, subgroup) = generate_hierarchical_clusters(
        n_samples,
        dim,
        n_supergroups,
        n_subclusts,
        supergroup_spread,
        subcluster_spread,
        point_std,
        seed,
    );

    list!(
        data = faer_to_r_matrix(res.as_ref()),
        supergroup = supergroup,
        subgroup = subgroup
    )
}

////////////////////////
// Nearest neighbours //
////////////////////////

/// Wrapper around some nearest neighbour searches integrated into manifold-rs
///
/// @param data Numeric matrix. Shape of samples x n_dim for which to get the
/// (approximate) nearest neighbours
/// @param k Integer. Number of neighbours to return
/// @param ann_method String. Which of the methods to use. One of
/// `c("hsnw", "balltree", "annoy", "nndescent")`
/// @param ann_params Named list. Contains the nearest neighbour parameters.
/// @param seed Integer. Seed for reproducibility
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @returns A list with the following elements
/// \itemize{
///   \item indices - flat representation of the indices.
///   \item dist - flat representaitons of the distances.
///   \item k - number of neighbours.
///   \item n - number of samples.
/// }
///
/// @export
#[extendr]
fn rs_approx_nearest_neighbours(
    data: RMatrix<f64>,
    k: usize,
    ann_method: String,
    ann_params: List,
    seed: usize,
    verbose: bool,
) -> List {
    let data = r_matrix_to_faer_fp32(&data);

    let mut nn_params = get_params_nn(ann_params);

    // balltree underperforms on small data set as the budget is too small
    // and individual leafs hold too many data points
    if data.nrows() <= 5000 && nn_params.bt_budget <= 0.25 {
        nn_params.bt_budget = 0.5
    }

    let (indices, dist) = run_ann_search(data.as_ref(), k, ann_method, &nn_params, seed, verbose);

    let indices = flatten_vector(indices);
    let dist = flatten_vector(dist);

    list![
        indices = indices.r_int_convert(),
        dist = dist.r_float_convert(),
        k = k,
        n = data.nrows()
    ]
}

//////////
// EVoC //
//////////

/// EVoC clustering
///
/// @description Wrapper function into the Rust interface for EVoC clustering.
///
/// @param embd Numerical matrix. The data to cluster. Should be of dimensions
/// samples x features.
/// @param n_neighbours Integer. Number of nearest neighbours for graph
/// construction.
/// @param evoc_params Named list. List that contains all of the key parameters
/// for EVoC clustering.
/// @param return_knn Boolean. Shall the kNN graph be returned.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return A named list with:
/// \itemize{
///   \item evoc_res - List with the EVoC results
///   \item knn - Optional list (can be NULL) with the kNN graph
/// }
///
/// @export
#[extendr]
fn rs_evoc(
    embd: RMatrix<f64>,
    n_neighbours: usize,
    evoc_params: List,
    return_knn: bool,
    seed: usize,
    verbose: bool,
) -> List {
    let embd = r_matrix_to_faer_fp32(&embd);
    let (res, indices, dist) = evoc_cluster(
        embd.as_ref(),
        None,
        n_neighbours,
        return_knn,
        evoc_params,
        seed,
        verbose,
    );

    let knn = match (indices, dist) {
        (Some(idx), Some(d)) => list!(
            indices = idx.r_int_convert(),
            dist = d.r_float_convert(),
            k = n_neighbours,
            n = embd.nrows()
        )
        .into_robj(),
        _ => NULL.into_robj(),
    };
    list!(evoc_res = res, knn = knn)
}

/// EVoC clustering from pre-computed kNN
///
/// @description Wrapper function into the Rust interface for EVoC clustering
/// using a pre-computed kNN graph.
///
/// @param embd Numerical matrix. The data to cluster. Should be of dimensions
/// samples x features.
/// @param knn_data List. A NearestNeighbours object with `k`, `indices`, and
/// `dist` elements.
/// @param n_neighbours Integer. Number of nearest neighbours for graph
/// construction.
/// @param evoc_params Named list. List that contains all of the key parameters
/// for EVoC clustering.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return A named list with cluster layers, membership strengths, persistence
/// scores, and the kNN graph.
///
/// @export
#[extendr]
fn rs_evoc_from_knn(
    embd: RMatrix<f64>,
    knn_data: List,
    n_neighbours: usize,
    evoc_params: List,
    seed: usize,
    verbose: bool,
) -> List {
    let embd = r_matrix_to_faer_fp32(&embd);
    let pre_computed_knn = nearest_neighbours_to_rust(knn_data);
    let (res, _, _) = evoc_cluster(
        embd.as_ref(),
        pre_computed_knn,
        n_neighbours,
        false,
        evoc_params,
        seed,
        verbose,
    );

    res
}

/////////////
// k-means //
/////////////

/// Full k-means clustering
///
/// @description Rust interface for k-means clustering using Lloyd's algorithm
/// with SIMD or GEMM acceleration depending on dimensionality.
///
/// @param data Numerical matrix. The data to cluster, of dimensions
/// samples x features.
/// @param k Integer. Number of clusters.
/// @param kmeans_params Named list. Parameters produced by `params_kmeans()`.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity.
///
/// @return A named list with:
/// \itemize{
///   \item centroids - Numeric matrix of shape k x features.
///   \item assignments - Integer vector of length samples (1-indexed).
/// }
///
/// @export
#[extendr]
fn rs_k_means(
    data: RMatrix<f64>,
    k: usize,
    kmeans_params: List,
    seed: usize,
    verbose: bool,
) -> List {
    let params = InternalKmeansParams::from_r_list(kmeans_params);
    let metric = params.dist();

    // transform data to fp32 and flatten
    let data = r_matrix_to_faer_fp32(&data);
    let (vectors_flat, n, dim) = matrix_to_flat(data.as_ref());

    let centroids = train_centroids(
        &vectors_flat,
        dim,
        n,
        k,
        &metric,
        params.max_iters,
        seed,
        verbose,
    );

    // Final assignment pass
    let data_norms = compute_data_norms(&vectors_flat, dim, n, &metric);
    let centroid_norms = recompute_centroid_norms(&centroids, dim, k, &metric);
    let assignments = assign_all_parallel(
        &vectors_flat,
        &data_norms,
        dim,
        n,
        &centroids,
        &centroid_norms,
        k,
        &metric,
    );

    // Convert to R (1-indexed assignments, centroids as k x dim matrix)
    let assignments_r: Vec<i32> = assignments.r_int_convert();
    let centroids_r = flat_to_r_matrix_f64(&centroids, k, dim);

    list!(centroids = centroids_r, assignments = assignments_r)
}

/// Mini-batch k-means clustering
///
/// @description Rust interface for mini-batch k-means clustering
/// (Sculley 2010). Uses random mini-batches with a decaying learning rate
/// for faster convergence on large data sets.
///
/// @param data Numerical matrix. The data to cluster, of dimensions
/// samples x features.
/// @param k Integer. Number of clusters.
/// @param kmeans_params Named list. Parameters produced by `params_kmeans()`.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity.
///
/// @return A named list with:
/// \itemize{
///   \item centroids - Numeric matrix of shape k x features.
///   \item assignments - Integer vector of length samples (1-indexed).
/// }
///
/// @export
#[extendr]
fn rs_k_means_mini_batch(
    data: RMatrix<f64>,
    k: usize,
    kmeans_params: List,
    seed: usize,
    verbose: bool,
) -> List {
    let params = InternalKmeansParams::from_r_list(kmeans_params);
    let metric = params.dist();

    // transform data to fp32 and flatten
    let data = r_matrix_to_faer_fp32(&data);
    let (vectors_flat, n, dim) = matrix_to_flat(data.as_ref());

    let (centroids, assignments) = train_centroids_minibatch(
        &vectors_flat,
        dim,
        n,
        k,
        &metric,
        params.max_iters,
        params.batch_size,
        params.drift_threshold,
        params.lr_alpha,
        seed,
        verbose,
    );

    let assignments_r: Vec<i32> = assignments.r_int_convert();
    let centroids_r = flat_to_r_matrix_f64(&centroids, k, dim);

    list!(centroids = centroids_r, assignments = assignments_r)
}

/////////////
// Metrics //
/////////////

/// Check cluster separation in an embedding
///
/// @param embd Numerical matrix. The embedding of shape samples x dims.
/// @param cluster_membership Integer vector. Zero-indexed cluster labels.
///
/// @return A named list with `within_dists` and `between_dists`.
///
/// @export
#[extendr]
fn rs_check_cluster_separation(embd: RMatrix<f64>, cluster_membership: &[i32]) -> List {
    let nrow = embd.nrows();
    let ncol = embd.ncols();

    let mut within_dists: Vec<f64> = Vec::new();
    let mut between_dists: Vec<f64> = Vec::new();

    for i in 0..nrow {
        for j in (i + 1)..nrow {
            let dist = (0..ncol)
                .map(|c| {
                    let d = embd[[i, c]] - embd[[j, c]];
                    d * d
                })
                .sum::<f64>()
                .sqrt();

            if cluster_membership[i] == cluster_membership[j] {
                within_dists.push(dist);
            } else {
                between_dists.push(dist);
            }
        }
    }

    list!(within_dists = within_dists, between_dists = between_dists)
}

/// Adjusted Rand index
///
/// @param cluster_membership_a Integers. Cluster memberships in group a.
/// @param cluster_membership_b Integers. Cluster memberships in group b.
///
/// @returns Returns the adjusted Rand index between the two groups.
///
/// @export
#[extendr]
fn rs_ari(cluster_membership_a: &[i32], cluster_membership_b: &[i32]) -> f64 {
    let cluster_membership_a = cluster_membership_a.r_int_convert();
    let cluster_membership_b = cluster_membership_b.r_int_convert();

    adjusted_rand_index(&cluster_membership_a, &cluster_membership_b)
}

/// Calculates the cluster silhouette scores
///
/// @description Uses the squared Euclidean distance under the hood for speed.
///
/// @param data Numeric matrix. The data in shape of sample x features.
/// @param cluster_membership Integers. Cluster memberships as integers.
///
/// @returns A list with the following items
/// \itemize{
///  \item mean_silhouette - Mean silhouette scores per cluster.
///  \item silhouette_scores - Silhouette scores per given data point.
/// }
///
/// @export
#[extendr]
fn rs_silhouette_score(data: RMatrix<f64>, cluster_membership: &[i32]) -> List {
    let data = r_matrix_to_faer(&data);
    let (vectors_flat, n, dim) = matrix_to_flat(data.as_ref());
    let cluster_membership = cluster_membership.r_int_convert();

    let (mean_silhouette, silhouette_scores) =
        silhouette_score(&vectors_flat, &cluster_membership, dim, n);

    list!(
        mean_silhouette = mean_silhouette,
        silhouette_scores = silhouette_scores
    )
}

/// Calculates the intertia for k-means clustering
///
/// @param data Numeric matrix. The data in shape of sample x features.
/// @param centroids Numeric matrix. The centroid data in shape k x features.
/// @param cluster_membership Integers. Cluster memberships as integers.
///
/// @returns The inertia score
///
/// @export
#[extendr]
fn rs_intertia(data: RMatrix<f64>, centroids: RMatrix<f64>, cluster_membership: &[i32]) -> f64 {
    let data = r_matrix_to_faer(&data);
    let centroids = r_matrix_to_faer(&centroids);
    let cluster_membership = cluster_membership.r_int_convert();

    let (vectors_flat, n, dim) = matrix_to_flat(data.as_ref());
    let (centroids_flat, _, _) = matrix_to_flat(centroids.as_ref());

    inertia(&vectors_flat, &centroids_flat, &cluster_membership, dim, n)
}
