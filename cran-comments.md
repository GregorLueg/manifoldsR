## Submission

First submission.

## Rust

The package wraps the Rust crates 'manifolds-rs', 'ann-search-rs' and
'evoc-rs' via 'extendr'. It follows the CRAN guidance for Rust packages:

- All crates are vendored in `src/rust/vendor.tar.xz` (xz compressed) and the
  build runs `cargo build --offline -j 2`, so nothing is downloaded at install.
- `CARGO_HOME` points into `src/.cargo` during the build and is removed
  afterwards, so nothing is written to the user's home directory.
- The rustc and cargo versions are printed by `configure` before compilation.
- Authors and licences of all vendored crates are in `inst/AUTHORS` and
  referenced from the `Authors@R` and `Copyright` fields.
- The helper binary that regenerates the R wrappers only builds during
  development (under roxygen2), never at install, which keeps link paths short
  on Windows.
- Rayon's thread pool is capped at two threads when `_R_CHECK_LIMIT_CORES_` is
  set, unless the user already set `RAYON_NUM_THREADS`.

The tarball is 7.9 MB, almost all of it the vendored crates (`vendor.tar.xz`
is 7.7 MB after dropping crates that only compile on platforms CRAN does not
build for, and unused Win32 bindings in 'windows-sys').

## R CMD check results

0 errors | 0 warnings | 1 note

- New submission.
- Possibly misspelled words in DESCRIPTION: McInnes, van der Maaten, Narayan
  and Jacomy are author names; UMAP, SNE, densMAP, PHATE, PaCMAP, EVoC and
  ForceAtlas are method names; "neighbour" is British spelling.

The installed size is 17.7 MB, of which `libs` is 16.9 MB: the statically
linked Rust library.
