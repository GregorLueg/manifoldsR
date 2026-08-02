//! Utility functions like shared parsing of parameter lists, and branching
//! trajectories.

#![warn(missing_docs)]

use extendr_api::*;
use manifolds_rs::prelude::*;
use manifolds_rs::PreComputedKnn;
use std::collections::HashMap;

////////////////////////
// Nearest neighbours //
////////////////////////

/// Helper function to generate the UMAP NN parameters
///
/// ### Params
///
/// * `r_list` - The list that has the nearest neighbour graph generation
///   parameters.
///
/// ### Returns
///
/// The `NearestNeighbourParams` with sensible defaults if not found in the
/// list.
/// Helper function to generate the UMAP NN parameters
///
/// # Arguments
///
/// * `r_list` - The list that has the nearest neighbour graph generation
///   parameters.
///
/// # Returns
///
/// `NearestNeighbourParams` with sensible defaults if not found in the list.
pub fn get_params_nn_manifolds<T>(r_list: List) -> Result<NearestNeighbourParams<T>>
where
    T: ManifoldsFloat,
{
    let nn_params: HashMap<&str, Robj> = r_list.try_into()?;
    let dist_metric = std::string::String::from(
        nn_params
            .get("dist_metric")
            .and_then(|v| v.as_str())
            .unwrap_or("cosine"),
    );
    let n_tree = nn_params
        .get("n_tree")
        .and_then(|v| v.as_integer())
        .unwrap_or(50) as usize;
    let search_budget = nn_params
        .get("search_budget")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let m = nn_params
        .get("m")
        .and_then(|v| v.as_integer())
        .unwrap_or(16) as usize;
    let ef_construction = nn_params
        .get("ef_construction")
        .and_then(|v| v.as_integer())
        .unwrap_or(100) as usize;
    let ef_search = nn_params
        .get("ef_search")
        .and_then(|v| v.as_integer())
        .unwrap_or(100) as usize;
    let diversify_prob = nn_params
        .get("diversify_prob")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.0).unwrap());
    let delta = nn_params
        .get("delta")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.001).unwrap());
    let ef_budget = nn_params
        .get("ef_budget")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let bt_budget = nn_params
        .get("bt_budget")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap())
        .unwrap_or(T::from_f64(0.1).unwrap());
    let n_list = nn_params
        .get("n_list")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);
    let n_probes = nn_params
        .get("n_probes")
        .and_then(|v| v.as_integer())
        .map(|v| v as usize);

    Ok(NearestNeighbourParams {
        dist_metric,
        n_tree,
        search_budget,
        m,
        ef_construction,
        ef_budget,
        ef_search,
        diversify_prob,
        delta,
        bt_budget,
        n_list,
        n_probes,
    })
}

////////////////////////
// Density parameters //
////////////////////////

/// Helper function to generate the density-preservation parameters
///
/// Shared by densMAP and den-SNE. A missing key falls through to the default
/// in `manifolds-rs`, which is `lambda = 2.0` (the densMAP weight) - den-SNE
/// wants `0.1`, so the R layer always supplies all three.
///
/// ### Params
///
/// * `r_list` - The list that has the density-preservation parameters.
///
/// ### Returns
///
/// The `DensParams` with sensible defaults if not found in the list.
pub fn get_params_dens<T>(r_list: List) -> Result<DensParams<T>>
where
    T: ManifoldsFloat,
{
    let dens_params: HashMap<&str, Robj> = r_list.try_into()?;

    let lambda = dens_params
        .get("lambda")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());
    let frac = dens_params
        .get("frac")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());
    let var_shift = dens_params
        .get("var_shift")
        .and_then(|v| v.as_real())
        .map(|v| T::from_f64(v).unwrap());

    Ok(DensParams::new(lambda, frac, var_shift))
}

/// Parse the nearest neighbours to a Rust function
///
/// ### Params
///
/// * `List` - The NearestNeighbour list.
///
/// ### Returns
///
/// A PreComputedKnn<f32> for the 2D embedding methods
pub fn nearest_neighbours_to_rust<T>(nn: List) -> PreComputedKnn<T>
where
    T: ManifoldsFloat,
{
    let k = nn.dollar("k").unwrap().as_integer().unwrap() as usize;

    let indices: Vec<i32> = nn.dollar("indices").unwrap().as_integer_vector().unwrap();
    let dist: Vec<f64> = nn.dollar("dist").unwrap().as_real_vector().unwrap();

    let indices: Vec<Vec<usize>> = indices
        .chunks(k)
        .map(|chunk| chunk.iter().map(|&i| (i - 1) as usize).collect())
        .collect();

    let dist: Vec<Vec<T>> = dist
        .chunks(k)
        .map(|chunk| chunk.iter().map(|&d| T::from_f64(d).unwrap()).collect())
        .collect();

    Some((indices, dist))
}

///////////////////////
// Cell trajectories //
///////////////////////

/// Helper function to parse a list to BranchSpecs
///
/// ### Params
///
/// * `list` - The R list. Needs to have the elements `"parent"`, `"split_at"`
///   and `"length"`.
///
/// ### Returns
///
/// A `Result<Vec<BranchSpec>>` that can be fed into `rs_data_trajectory()`.
pub fn parse_branch_specs(list: List) -> Result<Vec<BranchSpec>> {
    let parents: Vec<Option<usize>> = list
        .dollar("parent")?
        .as_integer_vector()
        .ok_or(Error::Other("'parent' must be an integer vector".into()))?
        .iter()
        .map(|&x| {
            if x == i32::MIN {
                None
            } else {
                Some(x as usize)
            }
        })
        .collect();

    let split_ats: Vec<f64> = list
        .dollar("split_at")?
        .as_real_vector()
        .ok_or(Error::Other("'split_at' must be a numeric vector".into()))?;

    let lengths: Vec<f64> = list
        .dollar("length")?
        .as_real_vector()
        .ok_or(Error::Other("'length' must be a numeric vector".into()))?;

    if parents.len() != split_ats.len() || parents.len() != lengths.len() {
        return Err(Error::Other(
            "parent, split_at and length must have equal length".into(),
        ));
    }

    Ok(parents
        .into_iter()
        .zip(split_ats)
        .zip(lengths)
        .map(|((parent, split_at), length)| BranchSpec {
            parent,
            split_at,
            length,
        })
        .collect())
}

/////////////////////
// Data transforms //
/////////////////////

/// Convert a flat `&[f32]` slice to an R matrix of `f64`
///
/// R matrices are column-major, so this transposes from the row-major
/// flat layout (nrow * ncol elements) into the column-major order
/// expected by `RMatrix`.
///
/// ### Params
///
/// * `flat` - Row-major f32 data of length `nrow * ncol`
/// * `nrow` - Number of rows in the output matrix
/// * `ncol` - Number of columns in the output matrix
///
/// ### Returns
///
/// An `RMatrix<f64>` of shape `nrow x ncol`
pub fn flat_to_r_matrix_f64(flat: &[f32], nrow: usize, ncol: usize) -> RMatrix<f64> {
    RMatrix::new_matrix(nrow, ncol, |r, c| flat[r * ncol + c] as f64)
}
