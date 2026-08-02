//! PaCMAP wrapper functions to R from manifolds-rs

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

use crate::utils::get_params_nn_manifolds;

////////////
// Params //
////////////

/// InternalPacmapParams
#[derive(Debug)]
pub struct InternalPacmapParams<T> {
    /// Which approximate nearest neighbour search to use.
    pub knn_method: String,
    /// Nearest neighbour parameters forwarded to the ANN methods.
    pub param_knn: NearestNeighbourParams<T>,
    /// Near pairs per point (attractive).
    pub n_near: usize,
    /// Mid-near pairs per point.
    pub n_mid_near: usize,
    /// Further (random) pairs per point.
    pub n_further: usize,
    /// Start index into kNN list for mid-near candidate window.
    pub mn_candidate_start: usize,
    /// End index into kNN list for mid-near candidate window.
    pub mn_candidate_end: usize,
    /// Which initialisation to use. One of `"pca"` or `"random"`.
    pub init: String,
    /// Which optimiser to use. One of `"adam"` or `"adam_parallel"`.
    pub optimiser: String,
    /// PaCMAP optimisation parameters.
    pub param_optimiser: PacmapOptimParams<T>,
}

impl<T> InternalPacmapParams<T>
where
    T: ManifoldsFloat,
{
    /// Generate PaCMAP parameters from an R list.
    ///
    /// ### Params
    ///
    /// * `r_list` - The R list with the parameters to extract
    ///
    /// ### Returns
    ///
    /// The internal representation of the Pacmap parameters
    pub fn from_r_list(r_list: List) -> Result<Self, extendr_api::Error> {
        let nn_params = get_params_nn_manifolds(r_list.clone())?;
        let optim_params = get_params_pacmap_optim(r_list.clone())?;

        let params: HashMap<&str, Robj> = r_list.try_into()?;

        let knn_method = String::from(
            params
                .get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("kmknn"),
        );

        let init = String::from(params.get("init").and_then(|v| v.as_str()).unwrap_or("pca"));

        let optimiser = String::from(
            params
                .get("optimiser")
                .and_then(|v| v.as_str())
                .unwrap_or("adam_parallel"),
        );

        let n_near = params
            .get("n_near")
            .and_then(|v| v.as_integer())
            .unwrap_or(10) as usize;

        let n_mid_near = params
            .get("n_mid_near")
            .and_then(|v| v.as_integer())
            .unwrap_or(5) as usize;

        let n_further = params
            .get("n_further")
            .and_then(|v| v.as_integer())
            .unwrap_or(20) as usize;

        let mn_candidate_start = params
            .get("mn_candidate_start")
            .and_then(|v| v.as_integer())
            .unwrap_or(4) as usize;

        let mn_candidate_end = params
            .get("mn_candidate_end")
            .and_then(|v| v.as_integer())
            .unwrap_or(50) as usize;

        Ok(Self {
            knn_method,
            param_knn: nn_params,
            n_near,
            n_mid_near,
            n_further,
            mn_candidate_start,
            mn_candidate_end,
            init,
            optimiser,
            param_optimiser: optim_params,
        })
    }
}

/// Helper function to generate PaCMAP optimisation parameters.
///
/// ### Params
///
/// * `r_list` - The R list with the parameters to extract
///
/// ### Returns
///
/// The PacmapOptimParams
fn get_params_pacmap_optim<T>(r_list: List) -> Result<PacmapOptimParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let params: HashMap<&str, Robj> = r_list.try_into()?;

    let lr = params
        .get("lr")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let n_epochs = params
        .get("n_epochs")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let beta1 = params
        .get("beta1")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let beta2 = params
        .get("beta2")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let eps = params
        .get("eps")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let phase1_end = params
        .get("phase1_end")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    let phase2_end = params
        .get("phase2_end")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    Ok(PacmapOptimParams::new(
        n_epochs, lr, beta1, beta2, eps, phase1_end, phase2_end,
    ))
}

////////////
// PaCMAP //
////////////

/// Wrapper function into the PaCMAP implementation in `manifolds-rs`.
///
/// ### Params
///
/// * `data` - Input data matrix of shape samples × features.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of output dimensions. Currently only `2` is supported.
/// * `pacmap_params` - R list that contains the Pacmap parameters.
/// * `seed` - Seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// Returns the PaCMAP embeddings as matrix.
pub fn pacmap_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    pacmap_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let internal = InternalPacmapParams::from_r_list(pacmap_params)?;

    let params = PacmapParams::new(
        n_dim,
        internal.knn_method,
        internal.optimiser,
        internal.n_near,
        internal.n_mid_near,
        internal.n_further,
        internal.mn_candidate_start,
        internal.mn_candidate_end,
        internal.init,
        None,
        internal.param_knn,
        internal.param_optimiser,
    );

    let res = pacmap(data, pre_computed_knn, &params, seed, verbose).to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
