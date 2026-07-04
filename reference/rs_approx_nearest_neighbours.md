# Wrapper around some nearest neighbour searches integrated into manifold-rs

**\[experimental\]** This is an interface into various (approximate)
nearest neighbour searches implemented in the Rust crate
`ann-search-rs`. They designed for incredible fast in-memory searches
for kNN generation.

## Usage

``` r
rs_approx_nearest_neighbours(data, k, ann_method, ann_params, seed, verbose)
```

## Arguments

- data:

  Numeric matrix. Shape of samples x n_dim for which to get the
  (approximate) nearest neighbours

- k:

  Integer. Number of neighbours to return

- ann_method:

  String. Which of the methods to use. One of
  `c("hsnw", "balltree", "annoy", "nndescent")`

- ann_params:

  Named list. Contains the nearest neighbour parameters.

- seed:

  Integer. Seed for reproducibility

- verbose:

  Integer. If `0L` -\> silent or `1L` for normal verbosity; `2L` for
  detailed verbosity.

## Value

A list with the following elements

- indices - flat representation of the indices.

- dist - flat representaitons of the distances.

- k - number of neighbours.

- n - number of samples.
