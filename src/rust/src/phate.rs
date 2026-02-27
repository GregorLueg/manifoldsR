use extendr_api::List;
use faer::{Mat, MatRef};
use manifolds_rs::prelude::*;
use manifolds_rs::*;

use crate::utils::get_params_nn;

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
#[derive(Debug)]
pub struct InternalPhateParams {
    // phate
    pub graph_symmetry: String,
    pub decay: Option<f32>,
    pub bandwidth_scale: Option<f32>,
    pub t_max: Option<usize>,
    pub t_custom: Option<usize>,
    pub gamma: Option<f32>,
    pub n_landmarks: Option<usize>,
    pub landmark_method: String,
    pub n_svd: Option<usize>,
    pub mds_method: String,
    // knn
    pub knn_method: String,
    pub param_knn: NearestNeighbourParams<f32>,
}

impl InternalPhateParams {
    pub fn from_r_list(r_list: List) -> Self {
        let nn_params = get_params_nn(r_list.clone());
        let phate_params = get_params_phate(r_list.clone());
        let base = r_list.into_hashmap();
        let knn_method = std::string::String::from(
            base.get("knn_method")
                .and_then(|v| v.as_str())
                .unwrap_or("hnsw"),
        );
        Self {
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
            knn_method,
            param_knn: nn_params,
        }
    }
}

fn get_params_phate(r_list: List) -> InternalPhateParams {
    let p = r_list.into_hashmap();
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
    InternalPhateParams {
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
        knn_method: "hnsw".to_string(),
        param_knn: NearestNeighbourParams::default(),
    }
}

///////////
// PHATE //
///////////

pub fn phate_simple(
    data: MatRef<f32>,
    n_dim: usize,
    k: usize,
    phate_params: List,
    seed: usize,
    verbose: bool,
) -> Mat<f32> {
    assert!(
        n_dim == 2,
        "At the moment, this tSNE implementation only supports n_dim = 2"
    );
    let internal_params_phate = InternalPhateParams::from_r_list(phate_params);
    let params_phate = PhateParams::new(
        Some(n_dim),
        Some(k),
        Some(internal_params_phate.knn_method),
        internal_params_phate.decay,
        internal_params_phate.bandwidth_scale,
        Some(internal_params_phate.graph_symmetry),
        internal_params_phate.t_max,
        internal_params_phate.gamma,
        internal_params_phate.n_landmarks,
        Some(internal_params_phate.landmark_method),
        internal_params_phate.n_svd,
        internal_params_phate.t_custom,
        Some(internal_params_phate.mds_method),
        Some(true),
    );
    let res = phate(data, None, params_phate, seed, verbose);
    let ncol = res.len();
    let nrow = res[0].len();
    Mat::from_fn(nrow, ncol, |i, j| res[j][i])
}
