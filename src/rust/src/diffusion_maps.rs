//! Diffusion maps wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{NNDescent, NNDescentQuery};
use ann_search_rs::utils::nndescent_utils::ApplySortedUpdates;
use bixverse_rs::prelude::IntoExtendrErr;
use extendr_api::*;
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::utils::diffusions::parse_phate_time;
use manifolds_rs::*;
use rand_distr::{Distribution, StandardNormal};
use std::collections::HashMap;

use crate::utils::get_params_nn_manifolds;

////////////
// Params //
////////////

/// InternalDiffusionMapsParams
///
/// Internal representation of various parameters needed for the diffusion
/// maps implementation in `manifolds-rs`.
#[derive(Debug)]
pub struct InternalDiffusionMapsParams<T> {
    /// Which of the approximate nearest neighbour searches to use.
    pub knn_method: String,
    /// The nearest neighbour parameters that are forwarded to the approximate
    /// nearest neighbour methods.
    pub param_knn: NearestNeighbourParams<T>,
    /// Multiplicative factor applied to the adaptive kernel bandwidth.
    pub bandwidth_scale: T,
    /// Sparsity threshold applied to kernel entries.
    pub thresh: T,
    /// Graph symmetrisation method.
    pub graph_symmetry: String,
    /// Anisotropic density-correction exponent in `[0, 1]`.
    pub alpha_norm: T,
    /// Maximum diffusion steps for VNE-based optimal t selection.
    pub t_max: Option<usize>,
    /// Optional fixed diffusion time.
    pub t_custom: Option<usize>,
    /// Optional landmark count.
    pub n_landmarks: Option<usize>,
    /// Landmark selection method.
    pub landmark_method: String,
    /// SVD components for spectral landmark selection.
    pub n_svd: Option<usize>,
}

impl<T> InternalDiffusionMapsParams<T>
where
    T: ManifoldsFloat,
{
    /// Generate the diffusion maps parameters from an R list
    ///
    /// ### Params
    ///
    /// * `r_list` - The R list with all the needed parameters for diffusion
    ///   maps.
    ///
    /// ### Returns
    ///
    /// The `InternalDiffusionMapsParams`.
    pub fn from_r_list(r_list: List) -> Result<Self> {
        let nn_params = get_params_nn_manifolds(r_list.clone())?;

        let dm_params: HashMap<&str, Robj> = r_list.try_into()?;

        let knn_method = std::string::String::from(
            dm_params
                .get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("kmknn"),
        );

        let bandwidth_scale = dm_params
            .get("bandwidth_scale")
            .and_then(|v| v.as_real())
            .map(|v| T::from_f64(v).unwrap())
            .unwrap_or(T::from_f64(1.0).unwrap());

        let thresh = dm_params
            .get("thresh")
            .and_then(|v| v.as_real())
            .map(|v| T::from_f64(v).unwrap())
            .unwrap_or(T::from_f64(1e-4).unwrap());

        let graph_symmetry = std::string::String::from(
            dm_params
                .get("graph_symmetry")
                .and_then(|v| v.as_str())
                .unwrap_or("add"),
        );

        let alpha_norm = dm_params
            .get("alpha_norm")
            .and_then(|v| v.as_real())
            .map(|v| T::from_f64(v).unwrap())
            .unwrap_or(T::from_f64(1.0).unwrap());

        let t_max = dm_params
            .get("t_max")
            .and_then(|v| v.as_integer())
            .map(|v| v as usize);

        let t_custom = dm_params
            .get("t_custom")
            .and_then(|v| v.as_integer())
            .map(|v| v as usize);

        let n_landmarks = dm_params
            .get("n_landmarks")
            .and_then(|v| v.as_integer())
            .map(|v| v as usize);

        let landmark_method = std::string::String::from(
            dm_params
                .get("landmark_method")
                .and_then(|v| v.as_str())
                .unwrap_or("spectral"),
        );

        let n_svd = dm_params
            .get("n_svd")
            .and_then(|v| v.as_integer())
            .map(|v| v as usize);

        Ok(Self {
            knn_method,
            param_knn: nn_params,
            bandwidth_scale,
            thresh,
            graph_symmetry,
            alpha_norm,
            t_max,
            t_custom,
            n_landmarks,
            landmark_method,
            n_svd,
        })
    }
}

//////////
// Main //
//////////

/// Wrapper function into the diffusion maps implementation in `manifolds-rs`
///
/// This function uses under the hood the general diffusion maps
/// implementation from the `manifolds-rs` crate.
///
/// ### Params
///
/// * `data` - The data to use for the generation of the diffusion maps
///   embedding.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - The number of dimensions to use.
/// * `k` - Number of neighbours to use.
/// * `dm_params` - Named R list that has all of the various diffusion maps
///   parameters.
/// * `seed` - For reproducibility.
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// Returns the diffusion maps embeddings as matrix.
#[allow(clippy::too_many_arguments)]
pub fn diffusion_maps_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    k: usize,
    dm_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let internal = InternalDiffusionMapsParams::from_r_list(dm_params)?;

    let dm_rust_params = DiffusionMapsParams::new(
        n_dim,
        k,
        internal.knn_method,
        internal.param_knn,
        internal.bandwidth_scale,
        internal.thresh,
        internal.graph_symmetry,
        internal.alpha_norm,
        parse_phate_time(internal.t_custom, internal.t_max.unwrap_or(100)),
        internal.n_landmarks,
        internal.landmark_method,
        internal.n_svd,
    );

    let res = diffusion_maps(data, pre_computed_knn, dm_rust_params, seed, verbose).to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
