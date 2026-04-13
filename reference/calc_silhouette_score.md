# Calculates the Silhouette score of a given clustering

If the membership has only one group, the function will return `NaN` for
`mean_silhouette` and `silhouette_scores`.

## Usage

``` r
calc_silhouette_score(data, membership)
```

## Arguments

- data:

  Numerical matrix. Samples x features. The matrix that was used to
  generate the clustering.

- membership:

  Integer vector. Membership/assignment of the clustering algorithm.

## Value

A list with the following items:

- mean_silhouette - The average Silhouette scores across all the data
  points.

- silhouette_scores - The individual Silhouette scores of all the data
  points.
