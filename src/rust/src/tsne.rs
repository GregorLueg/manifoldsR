//! tSNE wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{NNDescent, NNDescentQuery};
use ann_search_rs::utils::nndescent_utils::ApplySortedUpdates;
use bixverse_rs::prelude::IntoExtendrErr;
use extendr_api::{List, Robj};
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
// needs to be gated because Windows...
#[cfg(not(target_os = "windows"))]
use manifolds_rs::utils::fft::FftwFloat;
use manifolds_rs::*;
use rand_distr::{Distribution, StandardNormal};
use std::collections::HashMap;

use crate::utils::{get_params_dens, get_params_nn_manifolds};

////////////
// Params //
////////////

/// InternalTsneParams
///
/// Overall wrapper over various parameters needed for tSNE
#[derive(Debug)]
pub struct InternalTsneParams<T> {
    /// Which of the approximate nearest neighbour searches to use.
    pub knn_method: String,
    /// The nearest neighbour parameters that are forwarded to the approximate
    /// nearest neighbour methods.
    pub param_knn: NearestNeighbourParams<T>,
    /// Which initialisation to use. One of `"spectral"`, `"pca"`, or
    /// `"random"`.
    pub init: String,
    /// When setting initialisation to `"pca"` shall randomised SVD be used (can
    /// make it faster on large data sets).
    pub randomised: bool,
    /// The TsneOptimParameters
    pub param_optimiser: TsneOptimParams<T>,
}

impl<T> InternalTsneParams<T>
where
    T: ManifoldsFloat,
{
    /// Generate t-SNE parameters from an R list
    ///
    /// # Arguments
    ///
    /// * `r_list` - R list with all needed parameters for t-SNE
    ///
    /// # Returns
    ///
    /// The `InternalTsneParams`
    pub fn from_r_list(r_list: List) -> Result<Self, extendr_api::Error> {
        let nn_params = get_params_nn_manifolds(r_list.clone())?;
        let optim_params = get_params_tsne_optim(r_list.clone())?;

        let tsne_params: HashMap<&str, Robj> = r_list.try_into()?;

        let init = std::string::String::from(
            tsne_params
                .get("init")
                .and_then(|v| v.as_str())
                .unwrap_or("pca"),
        );

        let knn_method = std::string::String::from(
            tsne_params
                .get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("kmknn"),
        );

        let randomised = tsne_params
            .get("randomised")
            .and_then(|v| v.as_bool())
            .unwrap_or(true);

        Ok(Self {
            param_knn: nn_params,
            knn_method,
            init,
            randomised,
            param_optimiser: optim_params,
        })
    }
}

/// Helper function to generate t-SNE optimisation parameters
///
/// # Arguments
///
/// * `r_list` - List with t-SNE optimisation parameters
///
/// # Returns
///
/// `TsneOptimParams` with sensible defaults if not found in the list
fn get_params_tsne_optim<T>(r_list: List) -> Result<TsneOptimParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let optim_params: HashMap<&str, Robj> = r_list.try_into()?;

    let lr = optim_params
        .get("lr")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let late_exag_factor = optim_params
        .get("late_exag_factor")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    let n_epochs = optim_params
        .get("n_epochs")
        .and_then(|v| v.as_integer())
        .unwrap_or(1000) as usize;

    let early_exag_iter = optim_params
        .get("early_exag_iter")
        .and_then(|v| v.as_integer())
        .unwrap_or(250) as usize;

    let early_exag_factor = optim_params
        .get("early_exag_factor")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(12.0).unwrap());

    let theta = optim_params
        .get("theta")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.5).unwrap());

    let n_interp_points = optim_params
        .get("n_interp_points")
        .and_then(|v| v.as_integer())
        .unwrap_or(3) as usize;

    Ok(TsneOptimParams {
        n_epochs,
        lr,
        early_exag_iter,
        early_exag_factor,
        late_exag_factor,
        theta,
        n_interp_points,
    })
}

/// Helper function to assemble the `TsneParams` from an R list
///
/// Shared by `tsne_manifold` and `densne_manifold`, which build the exact same
/// t-SNE configuration and only differ in whether the density term is switched
/// on afterwards.
///
/// ### Params
///
/// * `tsne_params` - Named R list with all t-SNE parameters.
/// * `n_dim` - Number of dimensions to reduce to (needs to be two).
/// * `perplexity` - Perplexity parameter (typical: 5-50).
///
/// ### Returns
///
/// The assembled `TsneParams`.
fn build_tsne_params<T>(
    tsne_params: List,
    n_dim: usize,
    perplexity: T,
) -> Result<TsneParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let internal = InternalTsneParams::from_r_list(tsne_params)?;

    Ok(TsneParams {
        n_dim,
        perplexity,
        ann_type: internal.knn_method,
        initialisation: internal.init,
        nn_params: internal.param_knn,
        optim_params: internal.param_optimiser,
        randomised_init: internal.randomised,
        init_range: Some(T::from_f64(1e-2).unwrap()),
    })
}

//////////
// tSNE //
//////////

/// Wrapper function into the t-SNE implementation in `manifolds-rs`
///
/// This function wraps around the `manifolds-rs` function and exposes it to
/// R via another function.
///
/// ### Params
///
/// * `data` - Input data matrix for t-SNE
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of dimensions to reduce to (typically 2)
/// * `approximation` - String. One of `"bh"` for the Barnes Hut approximation
///   or `"fft"` for the Fast Fourier Transformation-accelerated one.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `tsne_params` - Named R list with all t-SNE parameters
/// * `seed` - Random seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// t-SNE embeddings as matrix
#[allow(clippy::too_many_arguments)]
#[cfg(not(target_os = "windows"))]
pub fn tsne_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    approx_type: &str,
    perplexity: T,
    tsne_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat + FftwFloat,
    HnswIndex<T>: HnswState<T>,
    StandardNormal: Distribution<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
{
    assert!(
        n_dim == 2,
        "At the moment, this tSNE implementation only supports n_dim = 2"
    );

    let tsne_params = build_tsne_params(tsne_params, n_dim, perplexity)?;

    let res = tsne(
        data,
        pre_computed_knn,
        &tsne_params,
        approx_type,
        seed,
        verbose,
    )
    .to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}

/// Wrapper function into the t-SNE implementation in `manifolds-rs`
///
/// This function wraps around the `manifolds-rs` function and exposes it to
/// R via another function.
///
/// ### Params
///
/// * `data` - Input data matrix for t-SNE
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of dimensions to reduce to (typically 2)
/// * `approximation` - String. One of `"bh"` for the Barnes Hut approximation
///   or `"fft"` for the Fast Fourier Transformation-accelerated one.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `tsne_params` - Named R list with all t-SNE parameters
/// * `seed` - Random seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// t-SNE embeddings as matrix
#[allow(clippy::too_many_arguments)]
#[cfg(target_os = "windows")]
pub fn tsne_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    approx_type: &str,
    perplexity: T,
    tsne_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    StandardNormal: Distribution<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
{
    assert!(
        n_dim == 2,
        "At the moment, this tSNE implementation only supports n_dim = 2"
    );

    let tsne_params = build_tsne_params(tsne_params, n_dim, perplexity)?;

    let res = tsne(
        data,
        pre_computed_knn,
        &tsne_params,
        approx_type,
        seed,
        verbose,
    )
    .to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}

///////////
// denSNE //
///////////

/// Wrapper function into the den-SNE implementation in `manifolds-rs`
///
/// den-SNE is t-SNE plus a density-preservation term, so the t-SNE
/// configuration is assembled exactly as for `tsne_manifold` and the three
/// density knobs are read from the same flat list. A `lambda` of `0` recovers
/// plain t-SNE.
///
/// ### Params
///
/// * `data` - Input data matrix for den-SNE
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of dimensions to reduce to (needs to be two)
/// * `approx_type` - String. One of `"bh"` for the Barnes Hut approximation
///   or `"fft"` for the Fast Fourier Transformation-accelerated one.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `densne_params` - Named R list with all t-SNE and density parameters
/// * `seed` - Random seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// den-SNE embeddings as matrix
///
/// ### References
///
/// Narayan, Berger & Cho, Nature Biotechnology, 2021
#[allow(clippy::too_many_arguments)]
#[cfg(not(target_os = "windows"))]
pub fn densne_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    approx_type: &str,
    perplexity: T,
    densne_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat + FftwFloat,
    HnswIndex<T>: HnswState<T>,
    StandardNormal: Distribution<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
{
    assert!(
        n_dim == 2,
        "At the moment, this den-SNE implementation only supports n_dim = 2"
    );

    let dens_params = get_params_dens(densne_params.clone())?;
    let tsne_params = build_tsne_params(densne_params, n_dim, perplexity)?;

    let densne_params = DensneParams::new(tsne_params, dens_params);

    let res = densne(
        data,
        pre_computed_knn,
        &densne_params,
        approx_type,
        seed,
        verbose,
    )
    .to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}

/// Wrapper function into the den-SNE implementation in `manifolds-rs`
///
/// den-SNE is t-SNE plus a density-preservation term, so the t-SNE
/// configuration is assembled exactly as for `tsne_manifold` and the three
/// density knobs are read from the same flat list. A `lambda` of `0` recovers
/// plain t-SNE.
///
/// ### Params
///
/// * `data` - Input data matrix for den-SNE
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `n_dim` - Number of dimensions to reduce to (needs to be two)
/// * `approx_type` - String. One of `"bh"` for the Barnes Hut approximation
///   or `"fft"` for the Fast Fourier Transformation-accelerated one. The
///   latter is not available on Windows.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `densne_params` - Named R list with all t-SNE and density parameters
/// * `seed` - Random seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// den-SNE embeddings as matrix
///
/// ### References
///
/// Narayan, Berger & Cho, Nature Biotechnology, 2021
#[allow(clippy::too_many_arguments)]
#[cfg(target_os = "windows")]
pub fn densne_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    n_dim: usize,
    approx_type: &str,
    perplexity: T,
    densne_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    StandardNormal: Distribution<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
{
    assert!(
        n_dim == 2,
        "At the moment, this den-SNE implementation only supports n_dim = 2"
    );

    let dens_params = get_params_dens(densne_params.clone())?;
    let tsne_params = build_tsne_params(densne_params, n_dim, perplexity)?;

    let densne_params = DensneParams::new(tsne_params, dens_params);

    let res = densne(
        data,
        pre_computed_knn,
        &densne_params,
        approx_type,
        seed,
        verbose,
    )
    .to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
