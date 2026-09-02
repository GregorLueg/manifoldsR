//! Implementation of the mini batch k-means leveraging infrastructure from
//! `ann-search-rs`.

use extendr_api::*;
use std::collections::HashMap;

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
    /// Initialisation. One of `"random"` or `"parallel"`
    pub init: String,
    /// Maximum number of Lloyd's / mini-batch iterations.
    pub max_iters: usize,
    /// Mini-batch size. Only used by the mini-batch path.
    pub batch_size: usize,
    /// Drifting threshold
    pub drift_threshold: f64,
    /// Learning rate exponent. `eta = m / count[c]^lr_alpha`.
    /// 1.0 = original Sculley (rather aggressive decay).
    pub lr_alpha: f64,
    /// Use Hamerly path (only available for Euclidean distance)
    pub use_hamerly: Option<bool>,
    /// Use GEMM instead of SIMD. Can be faster on larger data sets with high
    /// dimensionality.
    pub use_gemm: Option<bool>,
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
    pub fn from_r_list(r_list: List) -> Result<Self> {
        let params: HashMap<&str, Robj> = r_list.try_into()?;

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
        let use_hamerly = params.get("use_hamerly").and_then(|v| v.as_bool());
        let use_gemm = params.get("use_gemm").and_then(|v| v.as_bool());

        let init = String::from(
            params
                .get("init")
                .and_then(|v| v.as_str())
                .unwrap_or("parallel"),
        );

        Ok(Self {
            metric,
            max_iters,
            batch_size,
            drift_threshold,
            lr_alpha,
            use_hamerly,
            use_gemm,
            init,
        })
    }
}
