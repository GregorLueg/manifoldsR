//! UMAP wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{NNDescent, NNDescentQuery};
use ann_search_rs::utils::nndescent_utils::ApplySortedUpdates;
use bixverse_rs::prelude::IntoExtendrErr;
use extendr_api::{List, Robj};
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;
use rand_distr::{Distribution, StandardNormal};
use std::collections::HashMap;

use crate::utils::{get_params_dens, get_params_nn_manifolds};

////////////
// Params //
////////////

/// InternalUmapParams
///
/// Internal representation of various parameters needed for the UMAP
/// implementation in `manifolds-rs`.
#[derive(Debug)]
pub struct InternalUmapParams<T> {
    /// Which of the approximate nearest neighbour searches to use.
    pub knn_method: String,
    /// The nearest neighbour parameters that are forwarded to the approximate
    /// nearest neighbour methods.
    pub param_knn: NearestNeighbourParams<T>,
    /// The UMAP graph generation parameters.
    pub umap_graph: UmapGraphParams<T>,
    /// Which initialisation to use. One of `"spectral"`, `"pca"`, or
    /// `"random"`.
    pub init: String,
    /// When setting initialisation to `"pca"` shall randomised SVD be used (can
    /// make it faster on large data sets).
    pub randomised: bool,
    /// Which of the possible optimisers to use. One of `"sgd"`, `"adam"` or
    /// `"adam_parallel"`.
    pub optimiser: String,
    /// The UMAP optimisation parameters.
    pub param_optimiser: UmapOptimParams<T>,
}

impl<T> InternalUmapParams<T>
where
    T: ManifoldsFloat,
{
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
    pub fn from_r_list(
        r_list: List,
        min_dist: f64,
        spread: f64,
    ) -> Result<Self, extendr_api::Error> {
        let nn_params = get_params_nn_manifolds(r_list.clone())?;
        let umap_graph_params = get_params_umap_graph(r_list.clone())?;
        let optim_params = get_params_umap_optim(r_list.clone(), min_dist, spread)?;

        let umap_params: HashMap<&str, Robj> = r_list.try_into()?;

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
                .unwrap_or("kmknn"),
        );

        let randomised = umap_params
            .get("randomised")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        Ok(Self {
            param_knn: nn_params,
            umap_graph: umap_graph_params,
            knn_method,
            init,
            randomised,
            optimiser,
            param_optimiser: optim_params,
        })
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
pub fn get_params_umap_graph<T>(r_list: List) -> Result<UmapGraphParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let graph_params: HashMap<&str, Robj> = r_list.try_into()?;

    let mix_weight: T = graph_params
        .get("mix_weight")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(1.0).unwrap());

    let local_connectivity: T = graph_params
        .get("local_connectivity")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(1.0).unwrap());

    let bandwidth = graph_params
        .get("bandwidth")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(1e-5).unwrap());

    Ok(UmapGraphParams {
        bandwidth,
        local_connectivity,
        mix_weight,
    })
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
fn get_params_umap_optim<T>(
    r_list: List,
    min_dist: f64,
    spread: f64,
) -> Result<UmapOptimParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let optim_params: HashMap<&str, Robj> = r_list.try_into()?;

    let min_dist = T::from_f64(min_dist).unwrap();
    let spread = T::from_f64(spread).unwrap();

    let lr = optim_params
        .get("lr")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

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
        .map(|v| T::from(v).unwrap());

    Ok(UmapOptimParams::from_min_dist_spread(
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
    ))
}

/// Helper function to assemble the `UmapParams` from an R list
///
/// Shared by [`umap_manifold`] and [`densmap_manifold`], which build the exact
/// same UMAP configuration and only differ in whether the density term is
/// switched on afterwards.
///
/// ### Params
///
/// * `umap_params` - Named R list that has all of the various UMAP parameters.
/// * `n_dim` - The number of dimension to use.
/// * `k` - Number of neighbours to use.
/// * `min_dist` - Minimum distance parameter.
/// * `spread` - Spread parameter.
///
/// ### Returns
///
/// The assembled `UmapParams`.
fn build_umap_params<T>(
    umap_params: List,
    n_dim: usize,
    k: usize,
    min_dist: f64,
    spread: f64,
) -> Result<UmapParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let internal = InternalUmapParams::from_r_list(umap_params, min_dist, spread)?;

    let init_range = if internal.init == "pca" {
        Some(T::from_f64(1.0).unwrap())
    } else {
        None
    };

    Ok(UmapParams::new(
        n_dim,
        k,
        internal.optimiser,
        internal.knn_method,
        internal.init,
        init_range,
        internal.param_knn,
        internal.param_optimiser,
        internal.umap_graph,
        internal.randomised,
    ))
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
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - The number of dimension to use.
/// * `k` - Number of neighbors to use
/// * `min_dist` - Minimum distance parameter
/// * `spread` - Spread parameter
/// * `umap_list` - Named R list that has all of the various UMAP parameters.
/// * `seed` - For reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// Returns the UMAP embeddings as matrix.
#[allow(clippy::too_many_arguments)]
pub fn umap_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    k: usize,
    min_dist: f64,
    spread: f64,
    umap_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let umap_params = build_umap_params(umap_params, n_dim, k, min_dist, spread)?;

    let res = umap(data, pre_computed_knn, &umap_params, seed, verbose).to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}

//////////////
// densMAP //
//////////////

/// Wrapper function into the densMAP implementation in `manifolds-rs`
///
/// densMAP is UMAP plus a density-preservation term, so the UMAP configuration
/// is assembled exactly as for [`umap_manifold`] and the three density knobs
/// are read from the same flat list. A `lambda` of `0` recovers plain UMAP.
///
/// ### Params
///
/// * `data` - The data to use for the generation of the densMAP.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - The number of dimension to use.
/// * `k` - Number of neighbors to use
/// * `min_dist` - Minimum distance parameter
/// * `spread` - Spread parameter
/// * `densmap_params` - Named R list that has all of the various UMAP and
///   density parameters.
/// * `seed` - For reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// Returns the densMAP embeddings as matrix.
///
/// ### References
///
/// Narayan, Berger & Cho, Nature Biotechnology, 2021
#[allow(clippy::too_many_arguments)]
pub fn densmap_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    k: usize,
    min_dist: f64,
    spread: f64,
    densmap_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let dens_params = get_params_dens(densmap_params.clone())?;
    let umap_params = build_umap_params(densmap_params, n_dim, k, min_dist, spread)?;

    let densmap_params = DensmapParams::new(umap_params, dens_params);

    let res = densmap(data, pre_computed_knn, &densmap_params, seed, verbose).to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
