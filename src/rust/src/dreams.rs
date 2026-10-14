//! DREAMS wrapper functions to R from manifolds-rs
//!
//! DREAMS is t-SNE with a pull towards a global reference embedding, so the
//! t-SNE configuration is assembled via the same helper as `tsne_manifold`.

#![warn(missing_docs)]

use ann_search_rs::cpu::hnsw::{HnswIndex, HnswState};
use ann_search_rs::cpu::nndescent::{NNDescent, NNDescentQuery};
use ann_search_rs::utils::nndescent_utils::ApplySortedUpdates;
use bixverse_rs::prelude::IntoExtendrErr;
use extendr_api::{List, RMatrix, Robj};
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::utils::dreams::DREAMS_LAMBDA;
use manifolds_rs::utils::fft::FftFloat;
use manifolds_rs::*;
use rand_distr::{Distribution, StandardNormal};
use std::collections::HashMap;

use crate::tsne::build_tsne_params;

////////////
// Params //
////////////

/// Helper function to get the DREAMS regularisation strength from an R list
///
/// ### Params
///
/// * `r_list` - Named R list with the DREAMS parameters (`lambda`)
///
/// ### Returns
///
/// `lambda`, falling back to `DREAMS_LAMBDA` if not found in the list.
fn get_params_dreams<T>(r_list: List) -> Result<T, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let dreams_params: HashMap<&str, Robj> = r_list.try_into()?;

    // the R checker accepts integers (`lambda = 1L`), which `as_real()` alone
    // would silently drop to the default
    let lambda = dreams_params
        .get("lambda")
        .and_then(|v| v.as_real().or_else(|| v.as_integer().map(f64::from)))
        .unwrap_or(DREAMS_LAMBDA);

    Ok(T::from_f64(lambda).unwrap())
}

/// Convert an R reference embedding into the layout manifolds-rs expects
///
/// The R matrix is column-major samples x 2, so each column is already one
/// contiguous inner vector of the `[n_dim][n_samples]` layout.
///
/// ### Params
///
/// * `reference` - Optional R matrix of dimensions samples x 2
///
/// ### Returns
///
/// The reference as `[n_dim][n_samples]`, or `None` if none was supplied.
pub fn r_reference_to_rust<T>(reference: Option<&RMatrix<f64>>) -> Option<Vec<Vec<T>>>
where
    T: ManifoldsFloat,
{
    reference.map(|m| {
        m.data()
            .chunks_exact(m.nrows())
            .map(|col| col.iter().map(|&v| T::from_f64(v).unwrap()).collect())
            .collect()
    })
}

////////////
// DREAMS //
////////////

/// Wrapper function into the DREAMS implementation in `manifolds-rs`
///
/// ### Params
///
/// * `data` - Input data matrix for DREAMS
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `reference` - Optional global reference embedding as
///   `[n_dim][n_samples]`. `None` uses PCA.
/// * `n_dim` - Number of dimensions to reduce to (needs to be two)
/// * `approx_type` - String. One of `"bh"` for the Barnes Hut approximation,
///   `"bh_qd"` for the quick-and-dirty Barnes Hut (depth-capped tree),
///   `"fft"` for the Fast Fourier Transformation-accelerated one or `"fft_3k"`
///   for the three-kernel FFT variant.
/// * `perplexity` - Perplexity parameter (typical: 5-50)
/// * `dreams_params` - Named R list with all t-SNE parameters plus `lambda`
/// * `seed` - Random seed for reproducibility
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// DREAMS embeddings as matrix
///
/// ### References
///
/// Kury, Kobak & Damrich, Transactions on Machine Learning Research, 2026
#[allow(clippy::too_many_arguments)]
pub fn dreams_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    reference: Option<Vec<Vec<T>>>,
    n_dim: usize,
    approx_type: &str,
    perplexity: T,
    dreams_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat + FftFloat,
    HnswIndex<T>: HnswState<T>,
    StandardNormal: Distribution<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
{
    let lambda = get_params_dreams(dreams_params.clone())?;
    let tsne_params = build_tsne_params(dreams_params, n_dim, perplexity)?;

    let dreams_params = DreamsParams::new(tsne_params, lambda);

    let res = dreams(
        data,
        pre_computed_knn,
        reference,
        &dreams_params,
        approx_type,
        seed,
        verbose,
    )
    .to_extendr()?;

    let ncol = res.len();
    let nrow = res[0].len();

    Ok(Mat::from_fn(nrow, ncol, |i, j| res[j][i]))
}
