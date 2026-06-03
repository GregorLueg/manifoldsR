//! EVoC wrapper functions to R from evoc-rs

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{ApplySortedUpdates, NNDescent, NNDescentQuery};
use bixverse_rs::prelude::IntoExtendrErr;
use bixverse_rs::utils::vec_utils::flatten_vector;
use evoc_rs::prelude::{EvocFloat, NearestNeighbourParamsEvoc};
use evoc_rs::{evoc, EvocParams};
use extendr_api::*;
use faer::MatRef;
use manifolds_rs::PreComputedKnn;
use std::collections::HashMap;

///////////
// Types //
///////////

/// EvocResults type wrapper
pub type EvocResults = Result<(List, Option<Vec<usize>>, Option<Vec<f32>>)>;

////////////
// Params //
////////////

/// Helper function to generate the UMAP NN parameters
///
/// This is a near duplicate of [crate::utils::get_params_nn_manifolds()], but
/// avoids the previous tight coupling between the two crates `evoc-rs` and
/// `manifolds-rs`.
///
/// ### Params
///
/// * `r_list` - The list that has the nearest neighbour graph generation
///   parameters.
///
/// ### Returns
///
/// The `NearestNeighbourParamsEvoc` with sensible defaults if not found in the
/// list.
pub fn get_params_nn_evoc<T>(r_list: List) -> Result<NearestNeighbourParamsEvoc<T>>
where
    T: EvocFloat,
{
    let nn_params: HashMap<&str, Robj> = r_list.try_into()?;

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
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.0).unwrap());

    let delta = nn_params
        .get("delta")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.001).unwrap());

    let ef_budget = nn_params
        .get("ef_budget")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    // balltree
    let bt_budget = nn_params
        .get("bt_budget")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.1).unwrap());

    // ivf
    let n_list = nn_params
        .get("n_list")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let n_probes = nn_params
        .get("n_probes")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    Ok(NearestNeighbourParamsEvoc {
        dist_metric,
        n_tree,
        search_budget,
        m,
        ef_construction,
        ef_budget,
        ef_search,
        diversify_prob,
        delta,
        bt_budget,
        n_list,
        n_probes,
    })
}

/// InternalEvocParams
///
/// Internal representation of the parameters needed for EVoC clustering,
/// populated from an R list.
#[derive(Debug)]
pub struct InternalEvocParams<T> {
    /// Which approximate nearest neighbour search to use.
    pub knn_method: String,
    /// Nearest neighbour parameters forwarded to the ANN backend.
    pub param_knn: NearestNeighbourParamsEvoc<T>,
    /// EVoC-specific clustering parameters.
    pub evoc: EvocParams<T>,
}

impl<T> InternalEvocParams<T>
where
    T: EvocFloat,
{
    /// Build from an R list.
    ///
    /// ### Params
    ///
    /// * `r_list` - The merged R list containing both NN and EVoC parameters.
    /// * `n_neighbours` - Number of nearest neighbours (top-level R arg).
    ///
    /// ### Returns
    ///
    /// `InternalEvocParams` ready to pass into the Rust EVoC implementation.
    pub fn from_r_list(r_list: List, n_neighbours: usize) -> Result<Self> {
        let nn_params = get_params_nn_evoc(r_list.clone())?;
        let evoc_params = get_params_evoc(r_list.clone(), n_neighbours)?;

        let map: HashMap<&str, Robj> = r_list.try_into()?;

        let knn_method = String::from(
            map.get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("kmknn"),
        );

        Ok(Self {
            knn_method,
            param_knn: nn_params,
            evoc: evoc_params,
        })
    }
}

/// Parse EVoC-specific parameters from an R list.
///
/// ### Params
///
/// * `r_list` - Named R List that contains all the parameters supplied from the
///   R side.
/// * `n_neighbours` - Number of neighbours to use
///
/// ### Returns
///
/// The [`EvocParams`]
fn get_params_evoc<T>(r_list: List, n_neighbours: usize) -> Result<EvocParams<T>>
where
    T: EvocFloat,
{
    let map: HashMap<&str, Robj> = r_list.try_into()?;

    let noise_level = map
        .get("noise_level")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.5).unwrap());

    let n_epochs = map
        .get("n_epochs")
        .and_then(|v| v.as_integer())
        .unwrap_or(50) as usize;

    let embedding_dim = map
        .get("embedding_dim")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let neighbour_scale = map
        .get("neighbour_scale")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(1.0).unwrap());

    let symmetrise = map
        .get("symmetrise")
        .and_then(|v| v.as_bool())
        .unwrap_or(true);

    let min_samples = map
        .get("min_samples")
        .and_then(|v| v.as_integer())
        .unwrap_or(5) as usize;

    let base_min_cluster_size = map
        .get("base_min_cluster_size")
        .and_then(|v| v.as_integer())
        .unwrap_or(5) as usize;

    let approx_n_clusters = map
        .get("approx_n_clusters")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let min_similarity_threshold = map
        .get("min_similarity_threshold")
        .and_then(|v| v.as_real())
        .unwrap_or(0.2);

    let max_layers = map
        .get("max_layers")
        .and_then(|v| v.as_integer())
        .unwrap_or(10) as usize;

    Ok(EvocParams {
        n_neighbours,
        noise_level,
        n_epochs,
        embedding_dim,
        neighbour_scale,
        symmetrise,
        min_samples,
        base_min_cluster_size,
        approx_n_clusters,
        min_similarity_threshold,
        max_layers,
    })
}

//////////
// Main //
//////////

/// EVoC clustering wrapper
///
/// ### Params
///
/// * `data` - Input matrix (n_points x n_features).
/// * `pre_computed_knn` - Optional pre-computed kNN.
/// * `n_neighbours` - Number of nearest neighbours.
/// * `return_knn` - Shall the kNN be returned.
/// * `evoc_params` - Merged named R list with all parameters.
/// * `seed` - Random seed.
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// A named R list with `cluster_layers`, `membership_strengths`,
/// `persistence_scores`, `nn_indices`, and `nn_distances`.
#[allow(clippy::too_many_arguments)]
pub fn evoc_cluster<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_neighbours: usize,
    return_knn: bool,
    evoc_params: List,
    seed: usize,
    verbose: usize,
) -> EvocResults
where
    T: EvocFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    std::vec::Vec<T>: std::iter::FromIterator<T>,
{
    let params = InternalEvocParams::from_r_list(evoc_params, n_neighbours)?;

    let result = evoc(
        data,
        params.knn_method,
        pre_computed_knn,
        &params.evoc,
        &params.param_knn,
        seed,
        verbose,
    )
    .to_extendr()?;

    // Convert cluster_layers: Vec<Vec<i64>> -> R list of integer vectors
    let cluster_layers: Vec<Robj> = result
        .cluster_layers
        .iter()
        .map(|layer| {
            let v: Vec<i32> = layer.iter().map(|&l| l as i32).collect();
            v.into_robj()
        })
        .collect();

    // Convert membership_strengths: Vec<Vec<f32>> -> R list of numeric vectors
    let membership_strengths: Vec<Robj> = result
        .membership_strengths
        .iter()
        .map(|layer| {
            let v: Vec<f64> = layer.iter().map(|s| s.to_f64().unwrap()).collect();
            v.into_robj()
        })
        .collect();

    // persistence_scores: Vec<f64> -> R numeric vector
    let persistence_scores: Vec<f64> = result.persistence_scores;

    let (nn, dist) = if return_knn {
        let nn_indices: Vec<usize> = flatten_vector(result.nn_indices);
        let nn_distances: Vec<T> = flatten_vector(result.nn_distances);
        let nn_distances = nn_distances.iter().map(|x| x.to_f32().unwrap()).collect();
        (Some(nn_indices), Some(nn_distances))
    } else {
        (None, None)
    };

    Ok((
        list!(
            cluster_layers = List::from_values(cluster_layers),
            membership_strengths = List::from_values(membership_strengths),
            persistence_scores = persistence_scores,
        ),
        nn,
        dist,
    ))
}
