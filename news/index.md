# Changelog

## manifoldsR 0.3.0

Major release

### Features

- A lot of the backend code in Rust changed. This gives in parts
  substantially faster kNN searches from
  [ann-search-rs](https://crates.io/crates/ann-search-rs) (`"v0.8.1"`).

### Breaking change

- The kNN searches not always return Euclidean distance and not squared
  Euclidean distance to simplify. Be aware that this is a *breaking
  change* if you have old kNN graphs that used the Euclidean distance!

## manifoldsR 0.2.11

### Features

- Faster graph generations for PHATE, UMAP and tSNE from `manifolds-rs`.
- Various updates on the Rust backend.

## manifoldsR 0.2.10

### Fix

- Register the extendr panic hook. A panic in the Rust code now surfaces
  as an R error instead of taking down the R session.

## manifoldsR 0.2.9

### Features

- Faster spectral initialisation from `manifolds-rs`.

## manifoldsR 0.2.8

### Features

- Implementations of dens-map and dens-sne, density-preserving versions
  of UMAP and tSNE, see [Narayan et
  al.](https://www.nature.com/articles/s41587-020-00801-7)

## manifoldsR 0.2.7

### Features

- Updates on `manifolds-rs`, `evoc-rs`, `ann-search-rs` and
  `bixverse-rs`.

## manifoldsR 0.2.6

### Features

- Substantially faster tSNE implementations for both the `"bh"` and
  `"fft"` version.

## manifoldsR 0.2.5

### Features

- Various version bumps to recent Rust crates.

### Bug fixes

- The PacMAP optimisation was broken in the original Rust crate. This
  has been fixed now. The k parameter disappeared for PacMAP! This is a
  breaking change.
- Chosing `"ivf"` as a knn search method would have errored out due to
  wrong checkmate assertions.

## manifoldsR 0.2.4

### Features

- More control over floating point operations to avoid catastrophic
  cancellation on large data sets across all algorithms. This is
  controlled via the `use_high_precision = NULL` parameter. `NULL` will
  default to sensible defaults, but fine-grained control if you know
  what you are doing.

## manifoldsR 0.2.3

### Features

- Updates to various Rust crates
- More control over verbosity over the functions.
- Improved tSNE on large scale: `late_exag_factor` added that can be
  used on large data sets to increase repulsion on the later epochs.
  Also, speed improvements for both versions of tSNE.
- Faster PHATE (or rather fast again - k-means clustering iterations
  reduced here to avoid unncessary iterations).

### Bug fixes

- Numerical stability problem solved for very large data sets with
  FFT-accelerated tSNE

## manifoldsR 0.2.2

### Features

- Diffusion maps implemented.
- Update to extendr `0.9.0` backends.
- Documentation and vignette updates

## manifoldsR 0.2.1

### Features

- Version bump for `ann-search-rs` which exposes a new exact nearest
  neighbour algorithm - updates to defaults, vignettes and
  documentation.

## manifoldsR 0.2.0

Scope of the package was a bit extended and now offers also some of the
very fast clustering methods that power aspects of the approximate
nearest neighbour searches (k-means) + EVõC clustering.

### Features

- [EVõC clustering](https://github.com/TutteInstitute/evoc) implemented
  from the brilliant Leland McInnes.
- k-means clustering from `ann-search-rs` in a full version and as a
  mini-batch version for memory constrained scenarios.

## manifoldsR 0.1.3

### Features

- Version bump to latest `ann-search-rs` version

## manifoldsR 0.1.2

### Features

- Version bump to latest `manifolds-rs` version

## manifoldsR 0.1.1

### Features

- PaCMAP implemented
- Faster kNN searches for IVF and Annoy thanks to better `ann-search-rs`

## manifoldsR 0.1.0

### Features

- Implements UMAP, tSNE and PHATE based on Rust-accelerated methods.
- Provides synthetic data for testing and exploration purposes.
- Has an interface to various (approximate) nearest neighbour searches.
