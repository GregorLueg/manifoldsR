# Wrapper function to generate ForceAtlas2 parameters

The graph, initialisation and optimisation knobs for ForceAtlas2.
`local_connectivity`, `bandwidth`, `init` and `randomised` only apply
when the graph is built from the data via
[`forceatlas2()`](https://gregorlueg.github.io/manifoldsR/reference/forceatlas2.md);
[`forceatlas2_from_graph()`](https://gregorlueg.github.io/manifoldsR/reference/forceatlas2_from_graph.md)
ignores them.

## Usage

``` r
params_fa2(
  local_connectivity = 1,
  bandwidth = 1e-05,
  n_epochs = 500L,
  scaling_ratio = 2,
  gravity = 1,
  strong_gravity = FALSE,
  lin_log = FALSE,
  dissuade_hubs = FALSE,
  edge_weight_influence = 1,
  jitter_tolerance = 1,
  theta = 1.2,
  init = c("spectral", "pca", "random"),
  randomised = FALSE
)
```

## Arguments

- local_connectivity:

  Numeric. Number of nearest neighbours assumed to be at distance zero.
  Defaults to `1.0`.

- bandwidth:

  Numeric. Convergence tolerance for smooth kNN distance binary search.
  Defaults to `1e-05`.

- n_epochs:

  Integer. Number of optimisation epochs. Defaults to `500L`.

- scaling_ratio:

  Numeric. Repulsion strength. Larger values spread the layout. Defaults
  to `2.0`.

- gravity:

  Numeric. Pull towards the origin. Keeps disconnected components from
  drifting off. Defaults to `1.0`.

- strong_gravity:

  Boolean. Distance-independent gravity, scaled by `scaling_ratio`.
  Defaults to `FALSE`.

- lin_log:

  Boolean. Logarithmic attraction (LinLog). Gives tighter communities.
  Defaults to `FALSE`.

- dissuade_hubs:

  Boolean. Divide the attraction by the node mass. Pushes hubs to the
  periphery. Defaults to `FALSE`.

- edge_weight_influence:

  Numeric. Exponent applied to the edge weights. `0` ignores the
  weights. Defaults to `1.0`.

- jitter_tolerance:

  Numeric. Tolerated swinging. Larger is faster but less precise.
  Defaults to `1.0`.

- theta:

  Numeric. Barnes-Hut opening parameter on Gephi's scale. `0` gives the
  exact repulsion. Defaults to `1.2`.

- init:

  String. Embedding initialisation method. One of
  `c("spectral", "pca", "random")`. Defaults to `"spectral"`.

- randomised:

  Boolean. Use randomised SVD for PCA initialisation. Defaults to
  `FALSE`.

## Value

A named list with the following elements:

- local_connectivity - Numeric. Number of nearest neighbours assumed to
  be at distance zero. Defaults to `1.0`.

- bandwidth - Numeric. Convergence tolerance for smooth kNN distance
  binary search. Defaults to `1e-05`.

- n_epochs - Integer. Number of optimisation epochs. Defaults to `500L`.

- scaling_ratio - Numeric. Repulsion strength. Larger values spread the
  layout. Defaults to `2.0`.

- gravity - Numeric. Pull towards the origin. Keeps disconnected
  components from drifting off. Defaults to `1.0`.

- strong_gravity - Boolean. Distance-independent gravity, scaled by
  `scaling_ratio`. Defaults to `FALSE`.

- lin_log - Boolean. Logarithmic attraction (LinLog). Gives tighter
  communities. Defaults to `FALSE`.

- dissuade_hubs - Boolean. Divide the attraction by the node mass.
  Pushes hubs to the periphery. Defaults to `FALSE`.

- edge_weight_influence - Numeric. Exponent applied to the edge weights.
  `0` ignores the weights. Defaults to `1.0`.

- jitter_tolerance - Numeric. Tolerated swinging. Larger is faster but
  less precise. Defaults to `1.0`.

- theta - Numeric. Barnes-Hut opening parameter on Gephi's scale. `0`
  gives the exact repulsion. Defaults to `1.2`.

- init - String. Embedding initialisation method. One of
  `c("spectral", "pca", "random")`. Defaults to `"spectral"`.

- randomised - Boolean. Use randomised SVD for PCA initialisation.
  Defaults to `FALSE`.

## References

Jacomy, et al., PLoS ONE, 2014
