pub mod parametric_umap;
pub mod r_rust_interface;
pub mod umap;

use extendr_api::prelude::*;

use crate::parametric_umap::*;
use crate::r_rust_interface::*;
use crate::umap::*;

extendr_module! {
    mod manifoldsR;
    fn rs_umap;
}

//////////
// UMAP //
//////////

/// UMAP implementation in bixverse
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param n_dim Integer. Number of UMAP dimensions to return.
/// @param min_dist Numeric. Minimum distance to use.
/// @param spread Numeric. Spread parameter to use.
/// @param k Integer. Number of nearest neighbours to consider
/// @param umap_params Named list. List that contains all of the key parameters
/// for the UMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The UMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_umap(
    embd: RMatrix<f64>,
    n_dim: usize,
    min_dist: f64,
    spread: f64,
    k: usize,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let res = umap_simple(
        embd.as_ref(),
        n_dim,
        k,
        min_dist as f32,
        spread as f32,
        umap_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}

/////////////////////
// Parametric UMAP //
/////////////////////

/// UMAP implementation in bixverse (parametric)
///
/// @param embd Numerical matrix. The data to use to generate the embeddings.
/// Should be of dimensions samples x features.
/// @param n_dim Integer. Number of UMAP dimensions to return.
/// @param min_dist Numeric. Minimum distance to use.
/// @param spread Numeric. Spread parameter to use.
/// @param k Integer. Number of nearest neighbours to consider
/// @param umap_params Named list. List that contains all of the key parameters
/// for the UMAP generation.
/// @param seed Integer. Seed for reproducibility.
/// @param verbose Boolean. Controls verbosity of the function.
///
/// @return The UMAP embeddings.
///
/// @export
#[extendr]
#[allow(clippy::too_many_arguments)]
fn rs_umap_parametric(
    embd: RMatrix<f64>,
    n_dim: usize,
    min_dist: f64,
    spread: f64,
    k: usize,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> RMatrix<f64> {
    let embd = r_matrix_to_faer_fp32(&embd);

    let res = umap_parametric(
        embd.as_ref(),
        n_dim,
        k,
        min_dist as f32,
        spread as f32,
        umap_params,
        seed,
        verbose,
    );

    faer_to_r_matrix(res.as_ref())
}
