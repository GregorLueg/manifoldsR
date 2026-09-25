//! ForceAtlas2 wrapper functions to R from manifolds-rs

#![warn(missing_docs)]

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

use crate::umap::get_params_umap_graph;
use crate::utils::get_params_nn_manifolds;

/// Repulsion approximation passed to manifolds-rs. Barnes-Hut is the only
/// variant the crate offers, so it is not exposed to R.
const FA2_APPROX: &str = "barnes_hut";

////////////
// Params //
////////////

/// Helper function to generate the ForceAtlas2 optimisation parameters
///
/// ### Params
///
/// * `r_list` - The list that has the ForceAtlas2 optimisation parameters.
///
/// ### Returns
///
/// The `Fa2OptimParams` with the crate defaults for anything not found in the
/// list.
fn get_params_fa2_optim<T>(r_list: List) -> Result<Fa2OptimParams<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let optim_params: HashMap<&str, Robj> = r_list.try_into()?;
    let defaults = Fa2OptimParams::<T>::default();

    let get_real = |name: &str, default: T| -> T {
        optim_params
            .get(name)
            .and_then(|v| v.as_real())
            .map(|v| T::from_f64(v).unwrap())
            .unwrap_or(default)
    };
    let get_bool = |name: &str, default: bool| -> bool {
        optim_params
            .get(name)
            .and_then(|v| v.as_bool())
            .unwrap_or(default)
    };

    let n_epochs = optim_params
        .get("n_epochs")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize)
        .unwrap_or(defaults.n_epochs);

    Ok(Fa2OptimParams::new(
        n_epochs,
        get_real("scaling_ratio", defaults.scaling_ratio),
        get_real("gravity", defaults.gravity),
        get_bool("strong_gravity", defaults.strong_gravity),
        get_bool("lin_log", defaults.lin_log),
        get_bool("dissuade_hubs", defaults.dissuade_hubs),
        get_real("edge_weight_influence", defaults.edge_weight_influence),
        get_real("jitter_tolerance", defaults.jitter_tolerance),
        get_real("theta", defaults.theta),
    ))
}

/// Helper function to assemble the `Fa2Params` from an R list
///
/// `mix_weight` is never sent from R, so `get_params_umap_graph` falls back to
/// `1`, the only value `forceatlas2()` accepts.
///
/// ### Params
///
/// * `fa2_params` - Named R list with the nearest neighbour, graph and
///   ForceAtlas2 parameters.
/// * `k` - Number of neighbours to use.
///
/// ### Returns
///
/// The assembled `Fa2Params`.
fn build_fa2_params<T>(fa2_params: List, k: usize) -> Result<Fa2Params<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let nn_params = get_params_nn_manifolds(fa2_params.clone())?;
    let graph_params = get_params_umap_graph(fa2_params.clone())?;
    let optim_params = get_params_fa2_optim(fa2_params.clone())?;

    let params: HashMap<&str, Robj> = fa2_params.try_into()?;

    let get_string = |name: &str, default: &str| -> String {
        String::from(
            params
                .get(name)
                .and_then(|v| v.as_str())
                .unwrap_or(default),
        )
    };

    let randomised = params
        .get("randomised")
        .and_then(|v| v.as_bool())
        .unwrap_or(false);

    Ok(Fa2Params::new(
        k,
        get_string("knn_method", "kmknn"),
        get_string("init", "spectral"),
        None,
        randomised,
        nn_params,
        graph_params,
        optim_params,
    ))
}

/////////////////
// ForceAtlas2 //
/////////////////

/// Wrapper function into the ForceAtlas2 implementation in `manifolds-rs`
///
/// Builds the UMAP fuzzy union graph from the data (or the pre-computed kNN)
/// and lays it out with ForceAtlas2.
///
/// ### Params
///
/// * `data` - The data to embed, samples x features.
/// * `pre_computed_knn` - Optional pre-computed kNN to be used.
/// * `k` - Number of neighbours to use.
/// * `fa2_params` - Named R list with the nearest neighbour, graph and
///   ForceAtlas2 parameters.
/// * `seed` - For reproducibility.
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// The ForceAtlas2 embedding as samples x 2 matrix.
///
/// ### References
///
/// Jacomy et al., PLoS ONE, 2014
pub fn fa2_manifold<T>(
    data: MatRef<T>,
    pre_computed_knn: PreComputedKnn<T>,
    k: usize,
    fa2_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
    HnswIndex<T>: HnswState<T>,
    NNDescent<T>: ApplySortedUpdates<T> + NNDescentQuery<T>,
    StandardNormal: Distribution<T>,
{
    let fa2_params = build_fa2_params(fa2_params, k)?;

    let res = forceatlas2(
        data,
        pre_computed_knn,
        &fa2_params,
        FA2_APPROX,
        seed,
        verbose,
    )
    .to_extendr()?;

    Ok(Mat::from_fn(res[0].len(), 2, |i, j| res[j][i]))
}

/// Wrapper function into ForceAtlas2 on a caller-supplied graph
///
/// The edge list comes from an undirected igraph object, which stores every
/// edge once. The crate needs both directions, so each edge is mirrored here.
/// Self-loops are kept once; the crate drops them.
///
/// ### Params
///
/// * `from` - 1-based source vertex of each edge.
/// * `to` - 1-based target vertex of each edge.
/// * `weight` - Weight of each edge.
/// * `n` - Number of vertices.
/// * `init` - Optional initial layout as the column-major data of an `n x 2`
///   R matrix. `None` gives a random layout.
/// * `fa2_params` - Named R list with the ForceAtlas2 parameters.
/// * `seed` - For reproducibility.
/// * `verbose` - If `0` -> silent or `1` for normal verbosity, `2` for detailed
///   verbosity.
///
/// ### Returns
///
/// The ForceAtlas2 embedding as samples x 2 matrix.
///
/// ### References
///
/// Jacomy et al., PLoS ONE, 2014
#[allow(clippy::too_many_arguments)]
pub fn fa2_graph_manifold<T>(
    from: &[i32],
    to: &[i32],
    weight: &[f64],
    n: usize,
    init: Option<&[f64]>,
    fa2_params: List,
    seed: usize,
    verbose: usize,
) -> Result<Mat<T>, extendr_api::Error>
where
    T: ManifoldsFloat,
{
    let optim_params = get_params_fa2_optim(fa2_params)?;

    let n_entries = 2 * from.len();
    let mut row_indices = Vec::with_capacity(n_entries);
    let mut col_indices = Vec::with_capacity(n_entries);
    let mut values = Vec::with_capacity(n_entries);

    for ((&a, &b), &w) in from.iter().zip(to).zip(weight) {
        let (a, b) = ((a - 1) as usize, (b - 1) as usize);
        let w = T::from_f64(w).unwrap();
        row_indices.push(a);
        col_indices.push(b);
        values.push(w);
        if a != b {
            row_indices.push(b);
            col_indices.push(a);
            values.push(w);
        }
    }

    let graph = CoordinateList {
        row_indices,
        col_indices,
        values,
        n_samples: n,
    };

    let init = init.map(|flat| {
        flat.chunks(n)
            .map(|col| col.iter().map(|&v| T::from_f64(v).unwrap()).collect())
            .collect()
    });

    let res = forceatlas2_from_graph(&graph, init, &optim_params, FA2_APPROX, seed, verbose)
        .to_extendr()?;

    Ok(Mat::from_fn(n, 2, |i, j| res[j][i]))
}
