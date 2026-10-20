# Get cluster centroids

Get cluster centroids

## Usage

``` r
get_centroids(x)

# S3 method for class 'KMeansCluster'
get_centroids(x)
```

## Arguments

- x:

  A `KMeansCluster` object.

## Value

Numeric matrix of shape k x features.

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
dim(get_centroids(km))
#> [1]  4 32
```
