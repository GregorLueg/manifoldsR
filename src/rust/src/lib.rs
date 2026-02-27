pub mod phate;
pub mod tsne;
pub mod umap;
pub mod utils;

use bixverse_rs::prelude::*;
use bixverse_rs::utils::vec_utils::flatten_vector;
use extendr_api::prelude::*;
use manifolds_rs::data::synthetic::BranchSpec;
use manifolds_rs::prelude::*;

use crate::phate::*;
use crate::tsne::*;
use crate::umap::*;
use crate::utils::*;

////////////////////
// ExtendR module //
////////////////////

extendr_module! {
    mod manifoldsR;
    fn rs_umap;
    fn rs_umap_from_knn;
    fn rs_tsne;
    fn rs_phate;
    fn rs_approx_nearest_neighbours;
    fn rs_data_swiss_role;
    fn rs_data_clusters;
    fn rs_data_trajectory;
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
/// @description This is the wrapper function into the Rust interface for UMAP.
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

    let res = phate_simple(embd.as_ref(), n_dim, k, phate_params, seed, verbose);

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

////////////////////////
// Nearest neighbours //
////////////////////////

/// Wrapper around some nearest neighbour searches integrated into manifold-rs
///
/// ### Params
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
/// ### Returns
///
/// A list with the following elements
/// \itemize{
///   \item indices - flat representation of the indices.
///   \item dist - flat representaitons of the distances.
///   \item k - number of neighbours.
///   \item n - number of samples.
/// }
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
