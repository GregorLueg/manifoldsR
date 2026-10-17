#!/usr/bin/env sh
# Writes src/rust/vendor.tar.xz for a CRAN tarball. Run before R CMD build.
# The tarball stays out of git. Needs `cargo install cargo-vendor-filterer`.
#
# Plain `cargo vendor` takes every target and every cfg, which pulls in
# criterion, plotters and web-sys via rdst's cfg(bench) deps and every
# windows-* import lib. Filtering to the CRAN platforms halves the tarball.
set -eu

cd "$(dirname "$0")/../src/rust"
rm -rf vendor vendor.tar.xz

cargo vendor-filterer \
  --platform=x86_64-unknown-linux-gnu \
  --platform=aarch64-unknown-linux-gnu \
  --platform=x86_64-apple-darwin \
  --platform=aarch64-apple-darwin \
  --platform=x86_64-pc-windows-gnu \
  --platform=aarch64-pc-windows-gnullvm \
  --exclude-crate-path='*#tests' \
  --exclude-crate-path='*#benches' \
  --exclude-crate-path='*#examples' \
  --exclude-crate-path='*#docs' \
  vendor > /dev/null

# windows-sys 0.42 (faer -> spindle -> atomic-wait) ships every Win32 binding,
# 2.5 MB compressed. atomic-wait enables only the features kept below and each
# module sits behind its own cfg(feature), so the rest never compiles. Needs jq.
ws=vendor/windows-sys-0.42.0
if [ -d "$ws" ]; then
  keep='^src/Windows/Win32/(mod\.rs|Foundation/|System/(mod\.rs|Threading/|WindowsProgramming/))'
  find "$ws/src/Windows/Win32" -mindepth 1 -maxdepth 1 \
    ! -name mod.rs ! -name Foundation ! -name System -exec rm -rf {} +
  find "$ws/src/Windows/Win32/System" -mindepth 1 -maxdepth 1 \
    ! -name mod.rs ! -name Threading ! -name WindowsProgramming -exec rm -rf {} +
  jq -c --arg keep "$keep" \
    '.files |= with_entries(select((.key | startswith("src/Windows/Win32/") | not) or (.key | test($keep))))' \
    "$ws/.cargo-checksum.json" > "$ws/.cargo-checksum.json.tmp"
  mv "$ws/.cargo-checksum.json.tmp" "$ws/.cargo-checksum.json"
fi

tar -cJ --no-xattrs -f vendor.tar.xz vendor
rm -rf vendor
ls -lh vendor.tar.xz
