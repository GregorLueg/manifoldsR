use burn::backend::{
    libtorch::{LibTorch, LibTorchDevice},
    Autodiff,
};
use burn::prelude::Backend;
use extendr_api::List;
use faer::{Mat, MatRef};
use manifolds_rs::*;

use crate::umap::InternalUmapParams;

///////////////////
// Main function //
///////////////////

#[allow(clippy::too_many_arguments)]
pub fn umap_parametric(
    data: MatRef<f32>,
    n_dim: usize,
    k: usize,
    min_dist: f32,
    spread: f32,
    umap_params: List,
    seed: usize,
    verbose: bool,
) -> Mat<f32> {
    let umap_params_internal = InternalUmapParams::from_r_list(umap_params, min_dist, spread);

    let params_umap_parametric = ParametricUmapParams::new(
        Some(n_dim),
        Some(k),
        Some("annoy".into()),
        None,
        Some(umap_params_internal.param_knn),
        Some(umap_params_internal.umap_graph),
        None,
    );

    let device = LibTorchDevice::Cpu;

    LibTorch::<f32>::seed(&device, seed as u64);

    let res = parametric_umap::<f32, Autodiff<LibTorch>>(
        data,
        &params_umap_parametric,
        &device,
        seed,
        verbose,
    );

    let ncol = res.len();
    let nrow = res[0].len();

    Mat::from_fn(nrow, ncol, |i, j| res[j][i])
}
