//! Implementation of the mini batch k-means leveraging infrastructure from
//! `ann-search-rs`.

use ann_search_rs::prelude::AnnSearchFloat;
use ann_search_rs::utils::dist::*;
use ann_search_rs::utils::k_means_utils::*;
use extendr_api::List;
use num_traits::Float;
use rand::rngs::StdRng;
use rand::seq::SliceRandom;
use rand::SeedableRng;
use rayon::prelude::*;

////////////
// Params //
////////////

/// Internal k-means parameters
///
/// Holds all parameters needed for both full and mini-batch k-means,
/// parsed from the R parameter list.
#[derive(Debug)]
pub struct InternalKmeansParams {
    /// Distance metric. One of `"euclidean"` or `"cosine"`.
    pub metric: String,
    /// Maximum number of Lloyd's / mini-batch iterations.
    pub max_iters: usize,
    /// Mini-batch size. Only used by the mini-batch path.
    pub batch_size: usize,
    /// Drifting threshold
    pub drift_threshold: f64,
    /// Learning rate exponent. `eta = m / count[c]^lr_alpha`.
    /// 1.0 = original Sculley (rather aggressive decay).
    pub lr_alpha: f64,
}

impl InternalKmeansParams {
    /// Parse k-means parameters from an R list
    ///
    /// ### Params
    ///
    /// * `r_list` - The R list produced by `params_kmeans()`.
    ///
    /// ### Returns
    ///
    /// The parsed `InternalKmeansParams`.
    pub fn from_r_list(r_list: List) -> Self {
        let params = r_list.into_hashmap();

        let metric = String::from(
            params
                .get("metric")
                .and_then(|v| v.as_str())
                .unwrap_or("euclidean"),
        );
        let max_iters = params
            .get("max_iters")
            .and_then(|v| v.as_integer())
            .unwrap_or(100) as usize;
        let batch_size = params
            .get("batch_size")
            .and_then(|v| v.as_integer())
            .unwrap_or(4096) as usize;
        let drift_threshold = params
            .get("drift_threshold")
            .and_then(|v| v.as_real())
            .unwrap_or(1e-4);
        let lr_alpha = params
            .get("lr_alpha")
            .and_then(|v| v.as_real())
            .unwrap_or(1.0);

        Self {
            metric,
            max_iters,
            batch_size,
            drift_threshold,
            lr_alpha,
        }
    }

    /// Convert the metric string to the internal `Dist` enum.
    pub fn dist(&self) -> Dist {
        match self.metric.as_str() {
            "cosine" => Dist::Cosine,
            _ => Dist::Euclidean,
        }
    }
}

/////////////
// Helpers //
/////////////

/// Recompute centroid norms for the assignment path
///
/// Computes the norm representation expected by `gemm_assign_full` and
/// `direct_assign`: squared L2 norm (`||c||^2`) for Euclidean, or L2
/// norm (`||c||`) for Cosine.
///
/// ### Params
///
/// * `centroids` - All centroids, flattened row-major (`k * dim` elements)
/// * `dim` - Embedding dimensionality
/// * `k` - Number of centroids
/// * `metric` - Distance metric
///
/// ### Returns
///
/// `Vec<T>` of length `k` containing the per-centroid norm values.
pub fn recompute_centroid_norms<T>(centroids: &[T], dim: usize, k: usize, metric: &Dist) -> Vec<T>
where
    T: Float + SimdDistance,
{
    (0..k)
        .map(|c| {
            let cent = &centroids[c * dim..(c + 1) * dim];
            match metric {
                Dist::Euclidean => T::dot_simd(cent, cent),
                Dist::Cosine => T::calculate_l2_norm(cent),
            }
        })
        .collect()
}

/// Compute per-vector L2 norms, or return an empty vec for Euclidean
///
/// For Cosine distance, computes `||x||` for each vector (needed by the
/// centroid distance and pre-normalised assignment paths). For Euclidean,
/// returns an empty `Vec` since the assignment path computes squared
/// norms internally.
///
/// ### Params
///
/// * `data` - All vectors, flattened row-major (`n * dim` elements)
/// * `dim` - Embedding dimensionality
/// * `n` - Number of vectors
/// * `metric` - Distance metric
///
/// ### Returns
///
/// `Vec<T>` of length `n` (Cosine) or length `0` (Euclidean).
pub fn compute_data_norms<T>(data: &[T], dim: usize, n: usize, metric: &Dist) -> Vec<T>
where
    T: Float + Send + Sync + SimdDistance,
{
    match metric {
        Dist::Cosine => (0..n)
            .into_par_iter()
            .map(|i| T::calculate_l2_norm(&data[i * dim..(i + 1) * dim]))
            .collect(),
        Dist::Euclidean => Vec::new(),
    }
}

////////////////////////
// Mini batch k-means //
////////////////////////

/// Mini-batch k-means (Sculley 2010)
///
/// Trains centroids using random mini-batches with a decaying learning
/// rate (`eta = 1 / count[c]`). Each iteration samples `batch_size`
/// vectors without replacement, assigns them to the nearest centroid,
/// and applies an incremental mean update. A full assignment pass seeds
/// the per-centroid counts after initialisation to stabilise early
/// updates. Convergence is checked via maximum centroid drift.
///
/// After training, a final full-dataset assignment pass produces the
/// returned assignments.
///
/// ### Params
///
/// * `data` - Training vectors, flattened row-major (`n * dim` elements)
/// * `dim` - Embedding dimensionality
/// * `n` - Number of training vectors
/// * `n_centroids` - Number of clusters to create
/// * `metric` - Distance metric (`Euclidean` or `Cosine`)
/// * `max_iters` - Maximum number of mini-batch iterations
/// * `batch_size` - Number of vectors sampled per iteration. Clamped to
///   `n` if larger.
/// * `drift_threshold` - Below which centroid drift the algorithm is seen as
///   converged.
/// * `lr_alpha` - Learning rate alpha decay. The original paper used `1.0`, but
///   `0.75` yields better convergence.
/// * `seed` - Random seed for reproducibility
/// * `verbose` - Print convergence diagnostics
///
/// ### Returns
///
/// Tuple of (centroids, assignments) where centroids is a `Vec<T>` of
/// length `n_centroids * dim` (row-major) and assignments is a `Vec<usize>`
/// of length `n` with the nearest centroid index for each vector.
#[allow(clippy::too_many_arguments)]
pub fn train_centroids_minibatch<T>(
    data: &[T],
    dim: usize,
    n: usize,
    n_centroids: usize,
    metric: &Dist,
    max_iters: usize,
    batch_size: usize,
    drift_threshold: f64,
    lr_alpha: f64,
    seed: usize,
    verbose: bool,
) -> (Vec<T>, Vec<usize>)
where
    T: AnnSearchFloat,
{
    let batch_size = batch_size.min(n);

    // precompute all data norms once
    let data_norms: Vec<T> = match metric {
        Dist::Euclidean => (0..n)
            .into_par_iter()
            .map(|i| {
                let v = &data[i * dim..(i + 1) * dim];
                T::dot_simd(v, v)
            })
            .collect(),
        Dist::Cosine => (0..n)
            .into_par_iter()
            .map(|i| T::calculate_l2_norm(&data[i * dim..(i + 1) * dim]))
            .collect(),
    };

    // initialise centroids
    let mut centroids = if n_centroids > 200 {
        if verbose {
            println!("  Initialising centroids via fast random selection");
        }
        fast_random_init(data, dim, n, n_centroids, seed)
    } else {
        if verbose {
            println!("  Initialising centroids via k-means||");
        }
        let init_norms: Vec<T> = match metric {
            Dist::Euclidean => (0..n)
                .map(|i| T::calculate_l2_norm(&data[i * dim..(i + 1) * dim]))
                .collect(),
            Dist::Cosine => data_norms.clone(),
        };
        kmeans_parallel_init(data, &init_norms, dim, n, n_centroids, metric, seed)
    };

    let mut centroid_norms = recompute_centroid_norms(&centroids, dim, n_centroids, metric);

    // seed counts cheaply -> no full assignment pass
    let init_count = (batch_size / n_centroids).max(1);
    let mut counts = vec![init_count; n_centroids];

    let mut old_centroids = vec![T::zero(); n_centroids * dim];

    // pre-shuffle for epoch-based iteration: avoids per-iteration RNG + gather
    let mut rng = StdRng::seed_from_u64(seed as u64);
    let mut shuffled_indices: Vec<usize> = (0..n).collect();
    shuffled_indices.shuffle(&mut rng);
    let mut epoch_offset = 0usize;

    // scratch buffers
    let mut batch_data = Vec::with_capacity(batch_size * dim);
    let mut batch_norms = Vec::with_capacity(batch_size);

    let num_threads = rayon::current_num_threads();
    let alpha_t = T::from_f64(lr_alpha).unwrap();
    let drift_t = T::from_f64(drift_threshold).unwrap();

    if verbose {
        println!(
            "  Running mini-batch iterations (batch_size={}, lr_alpha={:.2})",
            batch_size, lr_alpha
        );
    }

    for iter in 0..max_iters {
        // epoch-based sampling: take next chunk, re-shuffle on wrap
        if epoch_offset + batch_size > n {
            shuffled_indices.shuffle(&mut rng);
            epoch_offset = 0;
        }
        let batch_indices = &shuffled_indices[epoch_offset..epoch_offset + batch_size];
        epoch_offset += batch_size;

        // gather batch
        batch_data.clear();
        batch_norms.clear();
        for &idx in batch_indices {
            batch_data.extend_from_slice(&data[idx * dim..(idx + 1) * dim]);
            batch_norms.push(data_norms[idx]);
        }

        // assign batch
        let batch_assignments = assign_all_parallel(
            &batch_data,
            &batch_norms,
            dim,
            batch_size,
            &centroids,
            &centroid_norms,
            n_centroids,
            metric,
        );

        // parallel fold-reduce -> per-cluster sums and counts
        let chunk_size = (batch_size + num_threads - 1) / num_threads.max(1);
        let (batch_sums, batch_counts) = batch_assignments
            .par_chunks(chunk_size)
            .enumerate()
            .map(|(chunk_idx, assign_chunk)| {
                let mut local_sums = vec![T::zero(); n_centroids * dim];
                let mut local_counts = vec![0usize; n_centroids];
                let start = chunk_idx * chunk_size;
                let data_chunk = &batch_data[start * dim..(start + assign_chunk.len()) * dim];

                for (i, &c) in assign_chunk.iter().enumerate() {
                    local_counts[c] += 1;
                    let vec = &data_chunk[i * dim..(i + 1) * dim];
                    let offset = c * dim;
                    T::add_assign_simd(&mut local_sums[offset..offset + dim], vec);
                }
                (local_sums, local_counts)
            })
            .reduce(
                || {
                    (
                        vec![T::zero(); n_centroids * dim],
                        vec![0usize; n_centroids],
                    )
                },
                |(mut s1, mut c1), (s2, c2)| {
                    T::add_assign_simd(&mut s1, &s2);
                    for i in 0..c1.len() {
                        c1[i] += c2[i];
                    }
                    (s1, c1)
                },
            );

        // collect touched centroids
        let touched: Vec<usize> = (0..n_centroids).filter(|&c| batch_counts[c] > 0).collect();

        // save old centroids (only need them for drift, full copy is cheap)
        old_centroids.copy_from_slice(&centroids);

        // apply incremental updates to touched centroids only
        for &c in &touched {
            let m = batch_counts[c];
            counts[c] += m;
            let count_f = T::from(counts[c]).unwrap();
            let eta = T::from(m).unwrap() / count_f.powf(alpha_t);
            // clamp eta to [0, 1] powf with alpha < 1 can push it above 1
            let eta = if eta > T::one() { T::one() } else { eta };
            let one_minus_eta = T::one() - eta;
            let inv_m = T::one() / T::from(m).unwrap();
            let offset = c * dim;
            for d in 0..dim {
                let batch_mean = batch_sums[offset + d] * inv_m;
                centroids[offset + d] = centroids[offset + d] * one_minus_eta + batch_mean * eta;
            }
        }

        // recompute norms only for touched centroids
        for &c in &touched {
            let cent = &centroids[c * dim..(c + 1) * dim];
            centroid_norms[c] = match metric {
                Dist::Euclidean => T::dot_simd(cent, cent),
                Dist::Cosine => T::calculate_l2_norm(cent),
            };
        }

        // drift check only on touched centroids
        let max_drift = touched
            .iter()
            .map(|&c| {
                let old = &old_centroids[c * dim..(c + 1) * dim];
                let new_c = &centroids[c * dim..(c + 1) * dim];
                euclidean_distance_static(old, new_c)
            })
            .fold(T::zero(), T::max);

        if max_drift <= drift_t {
            if verbose {
                println!("    Converged at iteration {}", iter + 1);
            }
            break;
        }

        if verbose && (iter + 1) % 50 == 0 {
            println!(
                "    Iteration {}, max centroid drift: {:.6}, touched: {}/{}",
                iter + 1,
                max_drift.to_f64().unwrap(),
                touched.len(),
                n_centroids,
            );
        }
    }

    // final full assignment
    let assignments = assign_all_parallel(
        data,
        &data_norms,
        dim,
        n,
        &centroids,
        &centroid_norms,
        n_centroids,
        metric,
    );

    (centroids, assignments)
}
