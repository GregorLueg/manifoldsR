# Calculate the cluster inertia

Calculate the cluster inertia

## Usage

``` r
calc_inertia(x, data)

# S3 method for class 'KMeansCluster'
calc_inertia(x, data)
```

## Arguments

- x:

  `KMeansCluster` class.

- data:

  Numerical matrix. The original data used to generate the k-means
  clusters. Shape of samples x features

## Value

The cluster inertia

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
calc_inertia(km, d$data)
#> [1] 220044.2
```
