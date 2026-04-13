# Get the cluster membership at the best persistence score

Get the cluster membership at the best persistence score

## Usage

``` r
best_membership(x)

# S3 method for class 'Evoc'
best_membership(x)
```

## Arguments

- x:

  An `Evoc` object.

## Value

A named list with elements `labels` (integer vector of cluster
assignments, `-1` for noise), `membership` (numeric vector of
strengths), `layer` (which layer index was selected), and `persistence`
(the score).
