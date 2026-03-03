# Generate a new NearestNeighbours

Generate a new NearestNeighbours

## Usage

``` r
generate_nearest_neigbours_class(indices, dist, k, n)
```

## Arguments

- indices:

  Integer. Nearest neigbours in flat storage format. Need to be sorted!

- dist:

  Numeric. Nearest neighbour distances in flat storarge format. Need to
  be sorted!

- k:

  Integer. Number of k-neighbours per sample.

- n:

  Integer. Number of samples.

## Value

Initialised `NearestNeighbours` class.
