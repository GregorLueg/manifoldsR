# Get cluster assignments

Get cluster assignments

## Usage

``` r
membership(x)

# S3 method for class 'KMeansCluster'
membership(x)
```

## Arguments

- x:

  A `KMeansCluster` object.

## Value

Integer vector of length samples with cluster assignments (1-indexed).

## Examples

``` r
d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
km <- kmeans_cluster(d$data, k = 4L, .verbose = FALSE)
table(membership(km))
#> 
#>   0   1   2   3 
#> 242 121 114  23 
```
