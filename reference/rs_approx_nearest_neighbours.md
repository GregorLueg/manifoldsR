# Wrapper around some nearest neighbour searches integrated into manifold-rs

Wrapper around some nearest neighbour searches integrated into
manifold-rs

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

  Boolean. Controls verbosity of the function.

## Value

A list with the following elements

- indices - flat representation of the indices.

- dist - flat representaitons of the distances.

- k - number of neighbours.

- n - number of samples.
