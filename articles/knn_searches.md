# Nearest neighbour searches

## Nearest neighbour searches in manifoldsR

kNN graphs are the core of different manifold learning methods. This
vignette gives you an intro in the provided methods, the advantages and
disadvantages of the different methods. The wrappers can be also used to
avoid recomputing the kNN graph if you wish to test different
parameters.

``` r
library(manifoldsR)
```

``` r
# number neighbours
k <- 10L

# number samples
n_samples <- 1000L
```

### Synthetic data

``` r
cluster_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = n_samples
)
```

### Exhaustive search

This is simples search type… It uses an exhaustive search index under
the hood with SIMD acceleration. On small data sets, this one might in
times be even faster than the approximate searches we will discuss
subsequently.

``` r
exhaustive <- generate_knn_graph(
  data = cluster_data$data,
  k = k,
  knn_method = "exhaustive"
)

exhaustive
#> NearestNeighbours
#>   n_samples:    1000 
#>   k_neighbours: 10
```

There is a set of getters for these classes, see below. An important
note is that the indices are 0-based (from Rust), so if you wish to use
them in R, you need to be aware of this.

``` r
# flat representation of the indices
indices_flat <- get_idx_flat(exhaustive)

# as N x idx nearest neigbours matrix
indices_mat <- get_idx_mat(exhaustive)
```

The distances can also be extracted:

``` r
# flat representation of the distances
dist_flat <- get_dist_flat(exhaustive)

# as N x idx nearest neigbours matrix
dist_mat <- get_dist_mat(exhaustive)
```

### Approximate searches

This package is designed to deal with large datasets and leverages under
the hood the [`ann-search-rs`
crate](https://github.com/GregorLueg/ann-search-rs) which provides
various approximate nearest neighbour searches. The 4 methods exposed in
this package are (+ the exhaustive version above):

| Method    | Features                                                                                 | Class       | Use case                                        |
|-----------|------------------------------------------------------------------------------------------|-------------|-------------------------------------------------|
| BallTree  | Simple method, good for small data sets (≤ 100,000)                                      | Tree-based  | Small data sets, small dimensionality           |
| Annoy     | Classic in single cell, scales well to data sets of up to 500,000                        | Tree-based  | Large data sets, small dimensionality           |
| HNSW      | Powerful on large datasets (≥ 500,000), slightly slower index build type, fast queries   | Graph-based | Large data sets, small to large dimensionality  |
| NNDescent | Another graph-based version, good all-rounder when certain sizes are reached (≥ 100,000) | Graph-based | Medium data sets, small to large dimensionality |

manifoldsR defaults to `HNSW`, but you can play around with the
parameters & methods. The package was written with massive scale in
mind, but if you are looking at smaller data sets (like in the
vignettes), `BallTree` does the job (fast).

#### Speed

Let’s just have a look on how they perform on different sizes

``` r
microbenchmark::microbenchmark(
  exhaustive = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "exhaustive",
      .verbose = FALSE
    )
  },
  annoy = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "annoy",
      .verbose = FALSE
    )
  },
  hnsw = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "hnsw",
      .verbose = FALSE
    )
  },
  balltree = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "balltree",
      .verbose = FALSE
    )
  },
  nndescent = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "nndescent",
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive  5.027665  5.027665  5.027665  5.027665  5.027665  5.027665     1
#>       annoy 19.340309 19.340309 19.340309 19.340309 19.340309 19.340309     1
#>        hnsw 34.565969 34.565969 34.565969 34.565969 34.565969 34.565969     1
#>    balltree  3.632351  3.632351  3.632351  3.632351  3.632351  3.632351     1
#>   nndescent 16.878695 16.878695 16.878695 16.878695 16.878695 16.878695     1
```

On small datasets, the exhaustive search beats everything. We need to
build the indices in the other methods, a cost that only makes sense
when we have sufficient samples to do this. Otherwise, modern CPUs with
SIMD can do the necessary `O(N^2)` in no time on smaller datasets. What
about 50k cells?

``` r
benchmark_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 50000L
)

microbenchmark::microbenchmark(
  exhaustive = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "exhaustive",
      .verbose = FALSE
    )
  },
  annoy = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "annoy",
      .verbose = FALSE
    )
  },
  hnsw = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "hnsw",
      .verbose = FALSE
    )
  },
  balltree = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "balltree",
      .verbose = FALSE
    )
  },
  nndescent = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "nndescent",
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: seconds
#>        expr      min       lq     mean   median       uq      max neval
#>  exhaustive 8.272245 8.272245 8.272245 8.272245 8.272245 8.272245     1
#>       annoy 4.752647 4.752647 4.752647 4.752647 4.752647 4.752647     1
#>        hnsw 3.950733 3.950733 3.950733 3.950733 3.950733 3.950733     1
#>    balltree 1.410431 1.410431 1.410431 1.410431 1.410431 1.410431     1
#>   nndescent 2.232046 2.232046 2.232046 2.232046 2.232046 2.232046     1
```

We start observing the first pattern, that the approximate nearest
neighbour searches are faster than the exhaustive search. The delta
becomes more pronounced with more samples:

``` r
benchmark_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 100000L
)

# this will take some time...
microbenchmark::microbenchmark(
  exhaustive = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "exhaustive",
      .verbose = FALSE
    )
  },
  annoy = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "annoy",
      .verbose = FALSE
    )
  },
  hnsw = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "hnsw",
      .verbose = FALSE
    )
  },
  balltree = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "balltree",
      .verbose = FALSE
    )
  },
  nndescent = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "nndescent",
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: seconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive 32.657034 32.657034 32.657034 32.657034 32.657034 32.657034     1
#>       annoy 13.731270 13.731270 13.731270 13.731270 13.731270 13.731270     1
#>        hnsw  8.844401  8.844401  8.844401  8.844401  8.844401  8.844401     1
#>    balltree  4.593687  4.593687  4.593687  4.593687  4.593687  4.593687     1
#>   nndescent  5.766403  5.766403  5.766403  5.766403  5.766403  5.766403     1
```

#### Precision

In the end, these are approximate methods. So, we need to understand how
good they are at recovering the true neighbours. A typical metric is
`Recall@k` neighbours. Let’s just have a look at the smaller data sets
here:

``` r
samples <- 25000L

benchmark_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = samples
)

exhaustive <- generate_knn_graph(
  data = benchmark_data$data,
  k = k,
  knn_method = "exhaustive"
)

indices <- c("hnsw", "annoy", "nndescent", "balltree")

for (idx in indices) {
  idx_i <- generate_knn_graph(
    data = benchmark_data$data,
    k = k,
    knn_method = idx,
    .verbose = FALSE
  )
  
  recall_i <- sum(get_idx_flat(exhaustive) == get_idx_flat(idx_i)) / 
    (k * samples)

  print(
    sprintf("ANN method %s achieves a Recall of %.3f.", idx, recall_i)
  )
}
#> [1] "ANN method hnsw achieves a Recall of 0.986."
#> [1] "ANN method annoy achieves a Recall of 1.000."
#> [1] "ANN method nndescent achieves a Recall of 0.992."
#> [1] "ANN method balltree achieves a Recall of 0.980."
```

As you can see, all of these methods are able to (mostly) identify the
right neighbours. If you wish to understand more how these methods work,
how they compare, etc., please check it out
[here](https://github.com/GregorLueg/ann-search-rs).
