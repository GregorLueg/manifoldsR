//! NCVis wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{NNDescent, NNDescentQuery};
use ann_search_rs::utils::nndescent_utils::ApplySortedUpdates;
use bixverse_r::prelude::IntoExtendrErr;
use extendr_api::{List, Robj};
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;
use rand_distr::{Distribution, StandardNormal};
use std::collections::HashMap;

use crate::utils::{get_params_nn_manifolds, robj_to_f64};

////////////
// Params //
////////////

/// InternalNcvisParams
///
/// Internal representation of the NCVis parameters, parsed from the R list.
/// `None` fields fall through to the `manifolds-rs` defaults.
#[derive(Debug)]
pub struct InternalNcvisParams<T> {
    /// Which approximate nearest neighbour search to use.
    pub knn_method: String,
    /// Nearest neighbour parameters forwarded to the ANN methods.
    pub param_knn: NearestNeighbourParams<T>,
    /// Initialisation. One of `"pca"` or `"random"`.
    pub init: String,
    /// Standard deviation of the first axis of the initial layout.
    pub init_scale: T,
    /// Use randomised SVD for the PCA initialisation.
    pub randomised: bool,
    /// Number of epochs.
    pub n_epochs: Option<usize>,
    /// Mean number of negative samples per edge.
    pub n_negative: Option<T>,
    /// Learning rate of the embedding.
    pub lr: Option<T>,
    /// Learning rate of the noise normalisation constant `Q`.
    pub lr_q: Option<T>,
}

impl<T> InternalNcvisParams<T>
where
    T: ManifoldsFloat,
{
    /// Generate the NCVis parameters from an R list
    ///
    /// ### Params
    ///
    /// * `r_list` - The R list produced by `params_ncvis()`.
    ///
    /// ### Returns
    ///
    /// The parsed `InternalNcvisParams`.
    pub fn from_r_list(r_list: List) -> Result<Self, extendr_api::Error> {
        let param_knn = get_params_nn_manifolds(r_list.clone())?;
        let params: HashMap<&str, Robj> = r_list.try_into()?;

        let to_t = |key: &str| {
            params
                .get(key)
                .and_then(robj_to_f64)
                .map(|v| T::from_f64(v).unwrap())
        };

        let knn_method = String::from(
            params
                .get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("nndescent"),
        );
        let init = String::from(params.get("init").and_then(|v| v.as_str()).unwrap_or("pca"));
        let init_scale =
            to_t("init_scale").unwrap_or_else(|| T::from_f64(NCVIS_INIT_SCALE).unwrap());
        let randomised = params
            .get("randomised")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);
        let n_epochs = params
            .get("n_epochs")
            .and_then(|v| v.as_integer())
            .map(|v| v as usize);

        Ok(Self {
            knn_method,
            param_knn,
            init,
            init_scale,
            randomised,
            n_epochs,
            n_negative: to_t("n_negative"),
            lr: to_t("lr"),
            lr_q: to_t("lr_q"),
        })
    }
}

///////////
// NCVis //
///////////

/// Wrapper function into the NCVis implementation in `manifolds-rs`
///
/// ### Params
///
/// * `data` - Input data matrix of shape samples x features.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used. The distances
///   are ignored, NCVis works on the unweighted graph.
/// * `n_dim` - Number of output dimensions.
/// * `k` - Number of neighbours.
/// * `min_dist` - Minimum distance, fits the `a` and `b` of the kernel.
/// * `spread` - Spread, fits the `a` and `b` of the kernel.
/// * `ncvis_params` - Named R list with the NCVis parameters.
/// * `seed` - Seed for reproducibility. Hogwild! SGD, so only reproducible on
///   a single thread.
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// Returns the NCVis embeddings as matrix.
#[allow(clippy::too_many_arguments)]
pub fn ncvis_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    k: usize,
    min_dist: f64,
    spread: f64,
    ncvis_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let internal = InternalNcvisParams::<T>::from_r_list(ncvis_params)?;

    let optim_params = NcvisOptimParams::from_min_dist_spread(
        T::from_f64(min_dist).unwrap(),
        T::from_f64(spread).unwrap(),
        internal.n_epochs,
        internal.n_negative,
        internal.lr,
        internal.lr_q,
    );

    let params = NcvisParams::new(
        n_dim,
        k,
        internal.knn_method,
        internal.init,
        internal.init_scale,
        internal.randomised,
        internal.param_knn,
        optim_params,
    );

    let res = ncvis(data, pre_computed_knn, &params, seed, verbose).to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
