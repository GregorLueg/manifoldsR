# ForceAtlas2 on a pre-computed graph

**\[experimental\]** Leverages the ForceAtlas2 implementation in
manifolds-rs and lays out a caller-supplied undirected graph. Each edge
is passed once; the Rust side adds the reverse direction.

## Usage

``` r
rs_forceatlas2_from_graph(
  from,
  to,
  weight,
  n,
  init,
  fa2_params,
  seed,
  use_high_precision,
  verbose
)
```

## Arguments

- from:

  Integer vector. 1-based source vertex of each edge.

- to:

  Integer vector. 1-based target vertex of each edge.

- weight:

  Numeric vector. Weight of each edge.

- n:

  Integer. Number of vertices.

- init:

  Optional numerical matrix of dimensions n x 2. The initial layout. If
  `NULL`, a random layout is used.

- fa2_params:

  Named list. List that contains the ForceAtlas2 optimisation
  parameters.

- seed:

  Integer. Seed for reproducibility.

- use_high_precision:

  Optional logical. Controls `fp32` vs `fp64`. If `NULL` will use
  sensible default thresholding.

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

The ForceAtlas2 embedding, n x 2.
