# manifoldsR 0.2.2

## Features

- Diffusion maps implemented.
- Update to extendr `0.9.0` backends.

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
