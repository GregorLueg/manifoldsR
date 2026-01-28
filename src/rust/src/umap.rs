use extendr_api::List;
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;

////////////
// Params //
////////////

/// InternalUmapParams
///
/// Internal representation of various parameters needed for the UMAP
/// implementation in `manifolds-rs`.
///
/// ### Fields
///
/// * `knn_method` - Which of the approximate nearest neighbour searches to use.
/// * `param_knn` - The nearest neighbour parameters that are forwarded to the
///   approximate nearest neighbour methods.
/// * `umap_graph` - The UMAP graph generation parameters.
/// * `init` - Which initialisation to use. One of `"spectral"`, `"pca"`, or
///   `"random"`.
/// * `randomised` - When setting initialisation to `"pca"` shall randomised
///   SVD be used (can make it faster on large data sets).
/// * `optimiser` - Which of the possible optimisers to use. One of `"sgd"`,
///   `"adam"` or `"adam_parallel"`.
/// * `param_optimiser` - The UMAP optimisation parameters.
#[derive(Debug)]
pub struct InternalUmapParams {
    // knn
    pub knn_method: String,
    pub param_knn: NearestNeighbourParams<f32>,
    // umap graph params
    pub umap_graph: UmapGraphParams<f32>,
    // embedding initialisation
    pub init: String,
    pub randomised: bool,
    // optimisation of the embedding - normal UMAP
    pub optimiser: String,
    pub param_optimiser: UmapOptimParams<f32>,
}

impl InternalUmapParams {
    /// Generate the UMAP parameters from an R list
    ///
    /// ### Params
    ///
    /// * `r_list` - The R list with all the needed parameters for UMAP.
    /// * `min_dist` - The desired minimum distance.
    /// * `spread` - The desired spread.
    ///
    /// ### Returns
    ///
    /// The `BixverseUmapParams`.
    pub fn from_r_list(r_list: List, min_dist: f32, spread: f32) -> Self {
        let nn_params = get_params_nn(r_list.clone());
        let umap_graph_params = get_params_umap_graph(r_list.clone());
        let optim_params = get_params_umap_optim(r_list.clone(), min_dist, spread);

        let umap_params = r_list.into_hashmap();

        let init = std::string::String::from(
            umap_params
                .get("init")
                .and_then(|v| v.as_str())
                .unwrap_or("spectral"),
        );

        let optimiser = std::string::String::from(
            umap_params
                .get("optimiser")
                .and_then(|v| v.as_str())
                .unwrap_or("adam_parallel"),
        );

        let knn_method = std::string::String::from(
            umap_params
                .get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("hnsw"),
        );

        let randomised = umap_params
            .get("randomised")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        Self {
            param_knn: nn_params,
            umap_graph: umap_graph_params,
            knn_method,
            init,
            randomised,
            optimiser,
            param_optimiser: optim_params,
        }
    }
}

/// Helper function to generate the UMAP NN parameters
///
/// ### Params
///
/// * `r_list` - The list that has the nearest neighbour graph generation
///   parameters.
///
/// ### Returns
///
/// The `NearestNeighbourParams` with sensible defaults if not found in the
/// list.
pub fn get_params_nn(r_list: List) -> NearestNeighbourParams<f32> {
    let nn_params = r_list.into_hashmap();

    // distance
    let dist_metric = std::string::String::from(
        nn_params
            .get("dist_metric")
            .and_then(|v| v.as_str())
            .unwrap_or("cosine"),
    );

    // annoy
    let n_tree = nn_params
        .get("n_tree")
        .and_then(|v| v.as_integer())
        .unwrap_or(50) as usize;

    let search_budget = nn_params
        .get("search_budget")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    // hnsw
    let m = nn_params
        .get("m")
        .and_then(|v| v.as_integer())
        .unwrap_or(16) as usize;

    let ef_construction = nn_params
        .get("ef_construction")
        .and_then(|v| v.as_integer())
        .unwrap_or(100) as usize;

    let ef_search = nn_params
        .get("ef_search")
        .and_then(|v| v.as_integer())
        .unwrap_or(100) as usize;

    // nn descent
    let diversify_prob = nn_params
        .get("diversify_prob")
        .and_then(|v| v.as_real())
        .unwrap_or(0.0) as f32;

    let delta = nn_params
        .get("delta")
        .and_then(|v| v.as_real())
        .unwrap_or(0.001) as f32;

    let ef_budget = nn_params
        .get("ef_budget")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    NearestNeighbourParams {
        dist_metric,
        n_tree,
        search_budget,
        m,
        ef_construction,
        ef_budget,
        ef_search,
        diversify_prob,
        delta,
    }
}

/// Helper function to generate the UMAP graph construction parameters
///
/// ### Params
///
/// * `r_list` - The list that has the UMAP graph construction parameters.
///
/// ### Returns
///
/// The `UmapGraphParams` with sensible defaults if not found in the list.
pub fn get_params_umap_graph(r_list: List) -> UmapGraphParams<f32> {
    let graph_params = r_list.into_hashmap();

    let mix_weight = graph_params
        .get("diversify_prob")
        .and_then(|v| v.as_real())
        .unwrap_or(1.0) as f32;

    let local_connectivity = graph_params
        .get("local_connectivity")
        .and_then(|v| v.as_real())
        .unwrap_or(1.0) as f32;

    let bandwidth = graph_params
        .get("bandwidth")
        .and_then(|v| v.as_real())
        .unwrap_or(1e-5) as f32;

    UmapGraphParams {
        bandwidth,
        local_connectivity,
        mix_weight,
    }
}

/// Helper function to generate the UMAP optimisation parameters
///
/// The function will estimate `a` and `b` parameters based on the provided
/// minimum distance and spread parameter.
///
/// ### Params
///
/// * `r_list` - The list that has the UMAP optimisation parameters.
/// * `min_dist` - The desired minimum distance.
/// * `spread` - The desired spread.
///
/// ### Returns
///
/// The `UmapOptimParams` with sensible defaults if not found in the list.
fn get_params_umap_optim(r_list: List, min_dist: f32, spread: f32) -> UmapOptimParams<f32> {
    let optim_params = r_list.into_hashmap();

    let lr = optim_params
        .get("lr")
        .and_then(|v| v.as_real())
        .map(|v| v as f32);

    let n_epochs = optim_params
        .get("n_epochs")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let neg_sample_rate = optim_params
        .get("neg_sample_rate")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let gamma = optim_params
        .get("gamma")
        .and_then(|v| v.as_real())
        .map(|v| v as f32);

    UmapOptimParams::from_min_dist_spread(
        min_dist,
        spread,
        lr,
        gamma,
        n_epochs,
        neg_sample_rate,
        // use defaults here...
        None,
        None,
        None,
    )
}

/////////////////
// Normal UMAP //
/////////////////

/// Wrapper function into the UMAP implementation in `manifolds-rs`
///
/// This function uses under the hood the general UMAP implementation from the
/// `manifolds-rs` crate.
///
/// ### Params
///
/// * `data` - The data to use for the generation of the UMAP.
/// * `n_dim` - The number of dimension to use.
/// * `k` - Number of neighbors to use
/// * `min_dist` - Minimum distance parameter
/// * `spread` - Spread parameter
/// * `umap_list` - Named R list that has all of the various UMAP parameters.
/// * `seed` - For reproducibility
/// * `verbose` - Controls verbosity
///
/// ### Returns
///
/// Returns the UMAP embeddings as matrix.
#[allow(clippy::too_many_arguments)]
pub fn umap_simple(
    data: MatRef<f32>,
    n_dim: usize,
    k: usize,
    min_dist: f32,
    spread: f32,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> Mat<f32> {
    let umap_params_internal = InternalUmapParams::from_r_list(umap_params, min_dist, spread);

    let init_range = if umap_params_internal.init == "pca" {
        Some(0.1_f32)
    } else {
        None
    };

    let umap_params = UmapParams::new(
        Some(n_dim),
        Some(k),
        Some(umap_params_internal.optimiser),
        Some(umap_params_internal.knn_method),
        Some(umap_params_internal.init),
        init_range,
        Some(umap_params_internal.param_knn),
        Some(umap_params_internal.param_optimiser),
        Some(umap_params_internal.umap_graph),
        Some(umap_params_internal.randomised),
    );

    let res = umap(data, &umap_params, seed, verbose);

    let ncol = res.len();
    let nrow = res[0].len();

    Mat::from_fn(nrow, ncol, |i, j| res[j][i])
}
