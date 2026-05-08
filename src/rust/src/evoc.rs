//! EVoC wrapper functions to R from evoc-rs

#![warn(missing_docs)]

use bixverse_rs::utils::vec_utils::flatten_vector;
use evoc_rs::{evoc, EvocParams};
use extendr_api::*;
use faer::MatRef;
use manifolds_rs::prelude::*;
use manifolds_rs::PreComputedKnn;
use std::collections::HashMap;

use crate::utils::get_params_nn;

///////////
// Types //
///////////

/// EvocResults type wrapper
pub type EvocResults = Result<(List, Option<Vec<usize>>, Option<Vec<f32>>)>;

////////////
// Params //
////////////

/// InternalEvocParams
///
/// Internal representation of the parameters needed for EVoC clustering,
/// populated from an R list.
#[derive(Debug)]
pub struct InternalEvocParams {
    /// Which approximate nearest neighbour search to use.
    pub knn_method: String,
    /// Nearest neighbour parameters forwarded to the ANN backend.
    pub param_knn: NearestNeighbourParams<f32>,
    /// EVoC-specific clustering parameters.
    pub evoc: EvocParams<f32>,
}

impl InternalEvocParams {
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
        let nn_params = get_params_nn(r_list.clone())?;
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
fn get_params_evoc(r_list: List, n_neighbours: usize) -> Result<EvocParams<f32>> {
    let map: HashMap<&str, Robj> = r_list.try_into()?;

    let noise_level = map
        .get("noise_level")
        .and_then(|v| v.as_real())
        .unwrap_or(0.5) as f32;

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
        .unwrap_or(1.0) as f32;

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
/// * `verbose` - Controls verbosity.
///
/// ### Returns
///
/// A named R list with `cluster_layers`, `membership_strengths`,
/// `persistence_scores`, `nn_indices`, and `nn_distances`.
#[allow(clippy::too_many_arguments)]
pub fn evoc_cluster(
    data: MatRef<f32>,
    pre_computed_knn: PreComputedKnn<f32>,
    n_neighbours: usize,
    return_knn: bool,
    evoc_params: List,
    seed: usize,
    verbose: bool,
) -> EvocResults {
    let params = InternalEvocParams::from_r_list(evoc_params, n_neighbours)?;

    let result = evoc(
        data,
        params.knn_method,
        pre_computed_knn,
        &params.evoc,
        &params.param_knn,
        seed,
        verbose,
    );

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
            let v: Vec<f64> = layer.iter().map(|&s| s as f64).collect();
            v.into_robj()
        })
        .collect();

    // persistence_scores: Vec<f64> -> R numeric vector
    let persistence_scores: Vec<f64> = result.persistence_scores;

    let (nn, dist) = if return_knn {
        let nn_indices: Vec<usize> = flatten_vector(result.nn_indices);
        let nn_distances: Vec<f32> = flatten_vector(result.nn_distances);
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
