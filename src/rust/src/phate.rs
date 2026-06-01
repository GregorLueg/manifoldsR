//! PHATE wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

use bixverse_rs::prelude::IntoExtendrErr;
use extendr_api::{List, Robj};
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;
use std::collections::HashMap;

use crate::utils::get_params_nn;

////////////
// Params //
////////////

/// InternalPhateParams
///
/// Overall wrapper over various parameters needed for PHATE.
#[derive(Debug)]
pub struct InternalPhateParams {
    /// Method to symmetrise the affinity graph. One of `"average"` or `"add"`.
    /// Defaults to `"average"`.
    pub graph_symmetry: String,
    /// Alpha decay parameter controlling the kernel bandwidth.
    pub decay: Option<f32>,
    /// Scaling factor for the bandwidth. `None` lets the library select a
    /// sensible default.
    pub bandwidth_scale: Option<f32>,
    /// Maximum diffusion time considered during automatic selection via
    /// Von Neumann entropy knee point detection.
    pub t_max: Option<usize>,
    /// Fixed diffusion time. When `Some`, overrides automatic time selection.
    pub t_custom: Option<usize>,
    /// Informational distance parameter for the diffusion potential.
    pub gamma: Option<f32>,
    /// Number of landmarks for compressed diffusion. `None` uses the full N × N
    /// diffusion operator.
    pub n_landmarks: Option<usize>,
    /// Method used to select landmarks. One of `"spectral"`, `"random"`, or
    /// `"min_max"`.
    pub landmark_method: String,
    /// Number of SVD components. `None` lets the library select a sensible
    /// default.
    pub n_svd: Option<usize>,
    /// MDS algorithm. One of `"sgd_dense"` or `"classic"`.
    pub mds_method: String,
    /// Optional user-provided number of iterations
    pub mds_iter: Option<usize>,
    /// Which approximate nearest neighbour method to use.
    pub knn_method: String,
    /// Nearest neighbour parameters forwarded to the ANN methods.
    pub param_knn: NearestNeighbourParams<f32>,
}

impl InternalPhateParams {
    /// Construct `InternalPhateParams` from an R named list.
    ///
    /// Delegates to `get_params_nn` and `get_params_phate` for their
    /// respective parameter subsets, then extracts `knn_method` directly
    /// from the top-level list.
    ///
    /// ### Params
    ///
    /// * `r_list` - Named R list containing all PHATE and nearest neighbour
    ///   parameters, as produced by `params_phate()` and `params_nn()` on
    ///   the R side.
    ///
    /// ### Returns
    ///
    /// A fully populated `InternalPhateParams`.
    pub fn from_r_list(r_list: List) -> Result<Self, extendr_api::Error> {
        let nn_params = get_params_nn(r_list.clone())?;
        let phate_params = get_params_phate(r_list.clone())?;
        let base: HashMap<&str, Robj> = r_list.try_into()?;
        let knn_method = std::string::String::from(
            base.get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("kmknn"),
        );
        Ok(Self {
            graph_symmetry: phate_params.graph_symmetry,
            decay: phate_params.decay,
            bandwidth_scale: phate_params.bandwidth_scale,
            t_max: phate_params.t_max,
            t_custom: phate_params.t_custom,
            gamma: phate_params.gamma,
            n_landmarks: phate_params.n_landmarks,
            landmark_method: phate_params.landmark_method,
            n_svd: phate_params.n_svd,
            mds_method: phate_params.mds_method,
            mds_iter: phate_params.mds_iter,
            knn_method,
            param_knn: nn_params,
        })
    }
}

/// Extract PHATE-specific parameters from an R named list.
///
/// Parses each PHATE field from the list, falling back to sensible defaults
/// when a key is absent. Does not extract nearest neighbour or `knn_method`
/// parameters; those are handled separately in `from_r_list`.
///
/// ### Params
///
/// * `r_list` - Named R list containing the PHATE parameter keys.
///
/// ### Returns
///
/// An `InternalPhateParams` with PHATE fields populated and `knn_method` /
/// `param_knn` set to their defaults. Callers should override those fields
/// via `from_r_list`.
fn get_params_phate(r_list: List) -> Result<InternalPhateParams, extendr_api::Error> {
    let p: HashMap<&str, Robj> = r_list.try_into()?;
    let graph_symmetry = std::string::String::from(
        p.get("graph_symmetry")
            .and_then(|v| v.as_str())
            .unwrap_or("add"),
    );
    let decay = p
        .get("decay")
        .and_then(|v| v.as_real())
        .map(|v| v as f32)
        .or(Some(40.0));
    let bandwidth_scale = p
        .get("bandwidth_scale")
        .and_then(|v| v.as_real())
        .map(|v| v as f32);
    let t_max = p
        .get("t_max")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize)
        .or(Some(100));
    let t_custom = p
        .get("t_custom")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let gamma = p
        .get("gamma")
        .and_then(|v| v.as_real())
        .map(|v| v as f32)
        .or(Some(1.0));
    let n_landmarks = p
        .get("n_landmarks")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let landmark_method = std::string::String::from(
        p.get("landmark_method")
            .and_then(|v| v.as_str())
            .unwrap_or("spectral"),
    );
    let n_svd = p
        .get("n_svd")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let mds_method = std::string::String::from(
        p.get("mds_method")
            .and_then(|v| v.as_str())
            .unwrap_or("sgd_dense"),
    );
    let mds_iter = p
        .get("mds_iter")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    Ok(InternalPhateParams {
        graph_symmetry,
        decay,
        bandwidth_scale,
        t_max,
        t_custom,
        gamma,
        n_landmarks,
        landmark_method,
        n_svd,
        mds_method,
        mds_iter,
        knn_method: "kmknn".to_string(),
        param_knn: NearestNeighbourParams::default(),
    })
}

///////////
// PHATE //
///////////

/// Run PHATE from an R parameter list without a precomputed kNN graph.
///
/// Parses the R parameter list into `PhateParams`, runs the full PHATE
/// pipeline including kNN search, and returns the embedding as a
/// column-major `Mat<f32>`.
///
/// ### Params
///
/// * `data` - Input data matrix of shape samples × features.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of output dimensions. Currently only `2` is supported.
/// * `k` - Number of nearest neighbours for graph construction.
/// * `phate_params` - Named R list of parameters, as produced by
///   `params_phate()` and `params_nn()` on the R side.
/// * `seed` - Random seed for reproducibility.
/// * `verbose` - Print progress information.
///
/// ### Returns
///
/// Embedding matrix of shape samples × n_dim.
pub fn phate_simple(
    data: MatRef<f32>,
    pre_computed_knn: PreComputedKnn<f32>,
    n_dim: usize,
    k: usize,
    phate_params: List,
    seed: usize,
    verbose: bool,
) -> Result<Mat<f32>, extendr_api::Error> {
    assert!(
        n_dim == 2,
        "At the moment, this PHATE implementation only supports n_dim = 2"
    );
    let internal = InternalPhateParams::from_r_list(phate_params)?;

    let diffusion_params = PhateDiffusionParams::new(
        Some(internal.decay.unwrap_or(40.0)),
        internal.bandwidth_scale.unwrap_or(1.0),
        1e-4,
        internal.graph_symmetry,
        internal.n_landmarks,
        internal.landmark_method,
        internal.n_svd,
        internal.t_max,
        internal.t_custom,
        internal.gamma.unwrap_or(1.0),
    );

    let params_phate = PhateParams::new(
        n_dim,
        k,
        internal.knn_method,
        internal.param_knn,
        diffusion_params,
        internal.mds_method,
        internal.mds_iter,
        true,
    );

    let res = phate(data, pre_computed_knn, params_phate, seed, verbose).to_extendr()?;
    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
