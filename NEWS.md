# manifoldsR 0.5.0

First CRAN release.

## Breaking changes

- Typos fixed in exported names: `params_swiss_role()`,
  `params_swiss_role_biased()`, `rs_data_swiss_role()`,
  `rs_data_biased_swiss_role()` and `rs_intertia()` are now
  `params_swiss_roll()`, `params_swiss_roll_biased()`, `rs_data_swiss_roll()`,
  `rs_data_biased_swiss_roll()` and `rs_inertia()`. The old names still work
  but throw a deprecation warning and will go in a future release.

## Features

- Rayon's thread pool is capped at two threads when `_R_CHECK_LIMIT_CORES_` is
  set (i.e. under `R CMD check --as-cran`), unless `RAYON_NUM_THREADS` is
  already set.
- `use_high_precision = NA` now warns and falls back to `TRUE` instead of
  silently doing so.

## Internals

- All Rust crates are vendored into `src/rust/vendor.tar.xz` and the build runs
  offline. The vendored set is filtered to the CRAN platforms.
- Rust output goes through R's console (`rprintln!`) rather than stdout.
- Vignettes are pkgdown-only articles now and no longer ship with the package.
- Examples added to all user-facing exports.
- Backend bumps: `manifolds-rs` 0.7.2 and `bixverse-rs` 0.8.0.

# manifoldsR 0.4.0

## Features

- DREAMS from [Kury, Kobak & Damrich](https://arxiv.org/abs/2508.13747):
  t-SNE with a pull towards a global reference embedding, so cluster positions
  keep their meaning. Use `dreams()` with `params_dreams()` (`lambda`, default
  `0.15`). PCA is the default reference; pass your own (e.g. a PHATE result)
  via `reference`. New vignette comparing it against PCA and t-SNE.
- The FFT t-SNE variants (`approx_type = "fft"` and `"fft_3k"`) now work on
  Windows too. `manifolds-rs` 0.7.0 swapped FFTW for a pure Rust FFT, so the
  Unix-only restriction in `tsne()` and `densne()` is gone.
- Backend bumps: `manifolds-rs` 0.7.0, `bixverse-rs` 0.7.0, `ann-search-rs`
  0.11.0, `evoc-rs` 0.5.0 and `faer` 0.24.

# manifoldsR 0.3.8

## Features

- Various version bumps in the backend for faster FFI, improved k-means 
  clustering.

# manifoldsR 0.3.7

## Features

- Quick-and-dirty Barnes-Hut t-SNE from `manifolds-rs` 0.6.0, after
  [qdtsne](https://github.com/libscran/qdtsne). Use `approx_type = "bh_qd"` in
  `tsne()` and `densne()`. The tree depth is capped via the new `max_depth`
  parameter in `params_tsne()` (default `7L`). Available on all platforms.
- `evoc-rs` bumped to 0.4.2 and `ann-search-rs` to 0.9.3.

# manifoldsR 0.3.6

## Features

- Updates to various Rust packages. `ann-search-rs` enables MacOS accelerate
  for some of the kNN backends and faster k-means.

# manifoldsR 0.3.5

## Features

- The new tSNE optimiser using the FFT 3-kernel interpolation is wired in.

# manifoldsR 0.3.4

## Features

- Faster FFT-accelerated tSNE from latest `manifolds-rs` release.

# manifoldsR 0.3.3

## Features

- Wired in [ForceAtlas2](https://doi.org/10.1371/journal.pone.0098679) from
  [manifolds-rs](https://docs.rs/manifolds-rs).

# manifoldsR 0.3.2

## Features

- Parameters all wrapped via [devforge](https://github.com/GregorLueg/devforge).

# manifoldsR 0.3.1

## Features

- Version updates on the backend to enable avx2 and avx512 instructions by 
  default.

# manifoldsR 0.3.0

Major release

## Features

- A lot of the backend code in Rust changed. This gives in parts substantially
  faster kNN searches from [ann-search-rs](https://docs.rs/ann-search-rs)
  (`"v0.8.1"`).

## Breaking change

- The kNN searches not always return Euclidean distance and not squared 
  Euclidean distance to simplify. Be aware that this is a *breaking change* if
  you have old kNN graphs that used the Euclidean distance!


# manifoldsR 0.2.11

## Features

- Faster graph generations for PHATE, UMAP and tSNE from `manifolds-rs`.
- Various updates on the Rust backend.

# manifoldsR 0.2.10

## Fix

- Register the extendr panic hook. A panic in the Rust code now surfaces as an R
  error instead of taking down the R session.

# manifoldsR 0.2.9

## Features

- Faster spectral initialisation from `manifolds-rs`.

# manifoldsR 0.2.8

## Features

- Implementations of dens-map and dens-sne, density-preserving versions of
  UMAP and tSNE, see [Narayan et al.](https://www.nature.com/articles/s41587-020-00801-7)

# manifoldsR 0.2.7

## Features

- Updates on `manifolds-rs`, `evoc-rs`, `ann-search-rs` and `bixverse-rs`.

# manifoldsR 0.2.6

## Features

- Substantially faster tSNE implementations for both the `"bh"` and `"fft"`
  version.

# manifoldsR 0.2.5

## Features

- Various version bumps to recent Rust crates.

## Bug fixes

- The PacMAP optimisation was broken in the original Rust crate. This has
  been fixed now. The k parameter disappeared for PacMAP! This is a breaking
  change.
- Chosing `"ivf"` as a knn search method would have errored out due to wrong
  checkmate assertions.

# manifoldsR 0.2.4

## Features

- More control over floating point operations to avoid catastrophic cancellation
  on large data sets across all algorithms. This is controlled via the
  `use_high_precision = NULL` parameter. `NULL` will default to sensible 
  defaults, but fine-grained control if you know what you are doing.

# manifoldsR 0.2.3

## Features

- Updates to various Rust crates
- More control over verbosity over the functions.
- Improved tSNE on large scale: `late_exag_factor` added that can be used on
  large data sets to increase repulsion on the later epochs. Also, speed 
  improvements for both versions of tSNE.
- Faster PHATE (or rather fast again - k-means clustering iterations reduced
  here to avoid unncessary iterations).

## Bug fixes

- Numerical stability problem solved for very large data sets with 
  FFT-accelerated tSNE

# manifoldsR 0.2.2

## Features

- Diffusion maps implemented.
- Update to extendr `0.9.0` backends.
- Documentation and vignette updates

# manifoldsR 0.2.1

## Features

- Version bump for `ann-search-rs` which exposes a new exact nearest neighbour
  algorithm - updates to defaults, vignettes and documentation.

# manifoldsR 0.2.0

Scope of the package was a bit extended and now offers also some of the very
fast clustering methods that power aspects of the approximate nearest neighbour
searches (k-means) + EVõC clustering.

## Features

- [EVõC clustering](https://github.com/TutteInstitute/evoc) implemented from the 
  brilliant Leland McInnes.
- k-means clustering from `ann-search-rs` in a full version and as a mini-batch
  version for memory constrained scenarios.

# manifoldsR 0.1.3

## Features

- Version bump to latest `ann-search-rs` version

# manifoldsR 0.1.2

## Features

- Version bump to latest `manifolds-rs` version

# manifoldsR 0.1.1

## Features

- PaCMAP implemented
- Faster kNN searches for IVF and Annoy thanks to better `ann-search-rs`

# manifoldsR 0.1.0

## Features

- Implements UMAP, tSNE and PHATE based on Rust-accelerated methods.
- Provides synthetic data for testing and exploration purposes.
- Has an interface to various (approximate) nearest neighbour searches.
