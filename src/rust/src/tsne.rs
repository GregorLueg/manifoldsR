use extendr_api::List;
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;

use crate::umap::get_params_nn;

////////////
// Params //
////////////

/// InternalTsneParams
///
/// Overall wrapper over various parameters needed for tSNE
///
/// ### Params
///
/// * `knn_method` - Which of the approximate nearest neighbour searches to use.
/// * `param_knn` - The nearest neighbour parameters that are forwarded to the
///   approximate nearest neighbour methods.
/// * `umap_graph` - The UMAP graph generation parameters.
/// * `init` - Which initialisation to use. One of `"spectral"`, `"pca"`, or
///   `"random"`.
/// * `randomised` - When setting initialisation to `"pca"` shall randomised
///   SVD be used (can make it faster on large data sets).
/// * `param_optimiser` - The TsneOptimParameters
#[derive(Debug)]
pub struct InternalTsneParams {
    // knn
    pub knn_method: String,
    pub param_knn: NearestNeighbourParams<f32>,
    // embedding initialisation
    pub init: String,
    pub randomised: bool,
    // optimisation parameters
    pub param_optimiser: TsneOptimParams<f32>,
}

impl InternalTsneParams {
    /// Generate t-SNE parameters from an R list
    ///
    /// # Arguments
    ///
    /// * `r_list` - R list with all needed parameters for t-SNE
    ///
    /// # Returns
    ///
    /// The `InternalTsneParams`
    pub fn from_r_list(r_list: List) -> Self {
        let nn_params = get_params_nn(r_list.clone());
        let optim_params = get_params_tsne_optim(r_list.clone());

        let tsne_params = r_list.into_hashmap();

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
                .unwrap_or("hnsw"),
        );

        let randomised = tsne_params
            .get("randomised")
            .and_then(|v| v.as_bool())
            .unwrap_or(true);

        Self {
            param_knn: nn_params,
            knn_method,
            init,
            randomised,
            param_optimiser: optim_params,
        }
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
fn get_params_tsne_optim(r_list: List) -> TsneOptimParams<f32> {
    let optim_params = r_list.into_hashmap();

    let lr = optim_params
        .get("lr")
        .and_then(|v| v.as_real())
        .unwrap_or(200.0) as f32;

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
        .unwrap_or(12.0) as f32;

    let theta = optim_params
        .get("theta")
        .and_then(|v| v.as_real())
        .unwrap_or(0.5) as f32;

    let n_interp_points = optim_params
        .get("n_interp_points")
        .and_then(|v| v.as_integer())
        .unwrap_or(3) as usize;

    TsneOptimParams {
        n_epochs,
        lr,
        early_exag_iter,
        early_exag_factor,
        theta,
        n_interp_points,
    }
}

//////////
// tSNE //
//////////

/// Wrapper function into the t-SNE implementation in `manifolds-rs`
///
/// This function uses the Barnes-Hut t-SNE implementation from the
/// `manifolds-rs` crate.
///
/// ### Params
///
/// * `data` - Input data matrix for t-SNE
/// * `n_dim` - Number of dimensions to reduce to (typically 2)
/// * `approximation` - String. One of `"bh"` for the Barnes Hut approximation
///   or `"fft"` for the Fast Fourier Transformation-accelerated one.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `tsne_params` - Named R list with all t-SNE parameters
/// * `seed` - Random seed for reproducibility
/// * `verbose` - Controls verbosity
///
/// ### Returns
///
/// t-SNE embeddings as matrix
#[allow(clippy::too_many_arguments)]
pub fn tsne_simple(
    data: MatRef<f32>,
    n_dim: usize,
    approx_type: &str,
    perplexity: f32,
    tsne_params: List,
    seed: usize,
    verbose: bool,
) -> Mat<f32> {
    assert!(
        n_dim == 2,
        "At the moment, this tSNE implementation only supports n_dim = 2"
    );

    let tsne_params_internal = InternalTsneParams::from_r_list(tsne_params);

    let tsne_params = TsneParams {
        n_dim,
        perplexity,
        ann_type: tsne_params_internal.knn_method,
        initialisation: tsne_params_internal.init,
        nn_params: tsne_params_internal.param_knn,
        optim_params: tsne_params_internal.param_optimiser,
        randomised_init: tsne_params_internal.randomised,
        init_range: Some(1e-4),
    };

    let res = tsne(data, &tsne_params, approx_type, seed, verbose);

    let ncol = res.len();
    let nrow = res[0].len();

    Mat::from_fn(nrow, ncol, |i, j| res[j][i])
}
