//! Various metrics for the package. Focus for now is on metrics useful for
//! clustering methods.

use ann_search_rs::utils::dist::SimdDistance;
use num_traits::Float;
use rayon::prelude::*;
use rustc_hash::FxHashMap;

////////////////////////
// Clustering metrics //
////////////////////////

/// Adjusted Rand Index between two clusterings
///
/// Computes ARI from the contingency table using the combinatorial
/// formulation. Both inputs must have the same length.
///
/// ### Params
///
/// * `labels_true` - Ground truth cluster labels
/// * `labels_pred` - Predicted cluster labels
///
/// ### Returns
///
/// ARI score in [-1, 1]. 1 = perfect agreement, 0 = chance.
pub fn adjusted_rand_index(labels_true: &[usize], labels_pred: &[usize]) -> f64 {
    let n = labels_true.len();
    assert_eq!(n, labels_pred.len());

    let mut contingency: FxHashMap<(usize, usize), u64> = FxHashMap::default();
    for i in 0..n {
        *contingency
            .entry((labels_true[i], labels_pred[i]))
            .or_insert(0) += 1;
    }

    // Row and column sums
    let mut row_sums: FxHashMap<usize, u64> = FxHashMap::default();
    let mut col_sums: FxHashMap<usize, u64> = FxHashMap::default();
    for (&(r, c), &count) in &contingency {
        *row_sums.entry(r).or_insert(0) += count;
        *col_sums.entry(c).or_insert(0) += count;
    }

    let comb2 = |x: u64| -> i64 { (x as i64) * (x as i64 - 1) / 2 };

    let sum_comb_nij: i64 = contingency.values().map(|&v| comb2(v)).sum();
    let sum_comb_a: i64 = row_sums.values().map(|&v| comb2(v)).sum();
    let sum_comb_b: i64 = col_sums.values().map(|&v| comb2(v)).sum();
    let comb_n = comb2(n as u64);

    let expected = (sum_comb_a as f64 * sum_comb_b as f64) / comb_n as f64;
    let max_index = 0.5 * (sum_comb_a as f64 + sum_comb_b as f64);
    let denom = max_index - expected;

    if denom == 0.0 {
        if sum_comb_nij as f64 == expected {
            1.0
        } else {
            0.0
        }
    } else {
        (sum_comb_nij as f64 - expected) / denom
    }
}

/// Mean silhouette score
///
/// Computes per-point silhouette coefficients and returns both the
/// mean score and the per-point values. Uses SIMD-accelerated squared
/// Euclidean distance internally. Points in singleton clusters receive
/// a silhouette of 0.
///
/// ### Params
///
/// * `data` - Flattened row-major data (`n * dim`)
/// * `assignments` - Cluster assignment per point (length `n`)
/// * `dim` - Dimensionality
/// * `n` - Number of points
///
/// ### Returns
///
/// Tuple of (mean silhouette, per-point silhouettes).
pub fn silhouette_score<T>(
    data: &[T],
    assignments: &[usize],
    dim: usize,
    n: usize,
) -> (f64, Vec<f64>)
where
    T: Float + SimdDistance + Send + Sync,
{
    // determine k from assignments
    let k = assignments.iter().copied().max().map_or(0, |m| m + 1);

    // Per-cluster: member count, vector sum, sum of squared norms
    let mut cluster_sizes = vec![0usize; k];
    let mut cluster_sums = vec![T::zero(); k * dim];
    let mut cluster_sq_norm_sums = vec![T::zero(); k];

    for i in 0..n {
        let c = assignments[i];
        let vi = &data[i * dim..(i + 1) * dim];
        cluster_sizes[c] += 1;
        T::add_assign_simd(&mut cluster_sums[c * dim..(c + 1) * dim], vi);
        cluster_sq_norm_sums[c] = cluster_sq_norm_sums[c] + T::dot_simd(vi, vi);
    }

    // Per-point squared norms
    let point_sq_norms: Vec<T> = (0..n)
        .into_par_iter()
        .map(|i| T::dot_simd(&data[i * dim..(i + 1) * dim], &data[i * dim..(i + 1) * dim]))
        .collect();

    let per_point: Vec<f64> = (0..n)
        .into_par_iter()
        .map(|i| {
            let ci = assignments[i];
            let vi = &data[i * dim..(i + 1) * dim];
            let ni = cluster_sizes[ci];

            if ni <= 1 {
                return 0.0;
            }

            // a(i): mean sq dist to own cluster, excluding self
            // sum_{j∈c} ||x_i - x_j||² = |c|·||x_i||² - 2·x_i·sum_c + sq_norm_sum_c
            // exclude j=i term (which is 0), divide by |c|-1
            let dot_own = T::dot_simd(vi, &cluster_sums[ci * dim..(ci + 1) * dim]);
            let a_i = (T::from(ni).unwrap() * point_sq_norms[i] - (dot_own + dot_own)
                + cluster_sq_norm_sums[ci])
                .to_f64()
                .unwrap()
                / (ni - 1) as f64;

            // b(i): min mean sq dist to any other cluster
            let mut b_i = f64::INFINITY;
            for c in 0..k {
                if c == ci || cluster_sizes[c] == 0 {
                    continue;
                }
                let nc = cluster_sizes[c];
                let dot_c = T::dot_simd(vi, &cluster_sums[c * dim..(c + 1) * dim]);
                let mean_sq = (T::from(nc).unwrap() * point_sq_norms[i] - (dot_c + dot_c)
                    + cluster_sq_norm_sums[c])
                    .to_f64()
                    .unwrap()
                    / nc as f64;
                if mean_sq < b_i {
                    b_i = mean_sq;
                }
            }

            (b_i - a_i) / a_i.max(b_i)
        })
        .collect();

    let mean = per_point.iter().sum::<f64>() / n as f64;
    (mean, per_point)
}

/// Within-cluster sum of squares (inertia)
///
/// For each point, computes the squared Euclidean distance to its
/// assigned centroid and sums across all points.
///
/// ### Params
///
/// * `data` - Flattened row-major data (`n * dim`)
/// * `centroids` - Flattened row-major centroids (`k * dim`)
/// * `assignments` - Cluster assignment per point (length `n`)
/// * `dim` - Dimensionality
/// * `n` - Number of points
///
/// ### Returns
///
/// Total within-cluster sum of squares.
pub fn inertia<T>(data: &[T], centroids: &[T], assignments: &[usize], dim: usize, n: usize) -> f64
where
    T: Float + SimdDistance + Send + Sync,
{
    (0..n)
        .into_par_iter()
        .map(|i| {
            let c = assignments[i];
            T::euclidean_simd(
                &data[i * dim..(i + 1) * dim],
                &centroids[c * dim..(c + 1) * dim],
            )
            .to_f64()
            .unwrap()
        })
        .sum()
}
