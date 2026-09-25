# Rust-based ForceAtlas2 on a pre-computed graph

Lays out any undirected graph with ForceAtlas2, for example an SNN graph
or a graph from another package. Edge weights come from the `weight`
edge attribute; without one, every edge weighs `1`. Self-loops are
dropped. Only the optimisation parameters in `fa2_params` are used; the
graph and initialisation ones do not apply here.

## Usage

``` r
forceatlas2_from_graph(
  graph,
  init = NULL,
  fa2_params = params_fa2(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
)
```

## Arguments

- graph:

  An undirected `igraph` object without multi-edges. Use
  `igraph::as_undirected(mode = "collapse")` or
  [`igraph::simplify()`](https://r.igraph.org/reference/simplify.html)
  to get there. If present, the `weight` edge attribute needs to be
  finite and non-negative.

- init:

  Optional numerical matrix of dimensions `vcount(graph) x 2`. The
  initial layout, e.g. a UMAP of the same samples. If `NULL`, a random
  layout is used. Defaults to `NULL`.

- fa2_params:

  Named list. ForceAtlas2 parameters, see
  [`params_fa2()`](https://gregorlueg.github.io/manifoldsR/reference/params_fa2.md).

- seed:

  Integer. Random seed for reproducibility. Defaults to `42L`.

- use_high_precision:

  Optional boolean. Gives fine-grained control over `fp32` vs `fp64`
  usage.

- .verbose:

  Logical. Controls verbosity. Defaults to `TRUE`.

## Value

A numerical matrix with dimensions `vcount(graph) x 2` containing the
ForceAtlas2 layout, rows in vertex order.

## References

Jacomy, et al., PLoS ONE, 2014
