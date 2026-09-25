# Nearest neighbour searches

## Nearest neighbour searches in manifoldsR

kNN graphs are the core of different manifold learning methods. This
vignette gives you an intro in the provided methods, plus the advantages
and disadvantages of the different methods. The wrappers can be also
used to avoid recomputing the kNN graph if you wish to test different
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

We will generate some synthetic data and test the different methods out.

``` r

cluster_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = n_samples
)
```

### Exhaustive search

This is simplest search type… It uses an exhaustive search index under
the hood with SIMD acceleration over a flat structure for cache
locality. On small data sets, this one might in times be even faster
than the approximate searches we will discuss subsequently.

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
note is that the indices are *0-based (from Rust)*, so if you wish to
use them in R, you need to be aware of this!

``` r

# flat representation of the indices
indices_flat <- get_idx_flat(exhaustive)

# as N x idx nearest neigbours matrix
indices_mat <- get_idx_mat(exhaustive)
```

The distances can also be extracted easily:

``` r

# flat representation of the distances
dist_flat <- get_dist_flat(exhaustive)

# as N x idx nearest neigbours matrix
dist_mat <- get_dist_mat(exhaustive)
```

An alternative, exact version is the [KmKnn (k-means for k-nearest
neighbour)](https://ieeexplore.ieee.org/document/6033373). It leverages
k-means and triangle inequality to reduce the number of searches - a
(very) fast, exact index that works well on low-dimensional data that
has strong structure.

``` r

kmknn <- generate_knn_graph(
  data = cluster_data$data,
  k = k,
  knn_method = "kmknn"
)

kmknn
#> NearestNeighbours
#>   n_samples:    1000 
#>   k_neighbours: 10
```

``` r

all(get_idx_flat(kmknn) == get_idx_flat(exhaustive))
#> [1] TRUE
```

### Approximate searches

This package is designed to deal with large datasets and leverages under
the hood the [`ann-search-rs`
crate](https://github.com/GregorLueg/ann-search-rs) which provides
various approximate nearest neighbour searches. The 4 methods exposed in
this package are (+ the exhaustive version above):

| Method | Features | Class | Use case |
|----|----|----|----|
| BallTree | Simple method, good for small data sets (≤ 100,000) | Tree-based | Small data sets, small dimensionality |
| Annoy | Classic in single cell, scales well to data sets of up to 500,000 | Tree-based | Large data sets, small dimensionality |
| HNSW | Powerful on large datasets (≥ 500,000), slightly slower index build type, fast queries. The implementation here uses a benign race condition during index building. | Graph-based | Large data sets, small to large dimensionality |
| NNDescent | Another graph-based version, good all-rounder when certain sizes are reached (≥ 100,000) | Graph-based | Medium data sets, small to large dimensionality |
| IVF | A fast cluster-based index powering libraries like FAISS. | Cluster-based | Large data sets, any dimensionality. You can squeeze out aggressively speed with the n_probe parameter if need be. Be careful to set n_list pending your data structure. If you have few well defined data clusters, it is better to set it lower for this method. |

manifoldsR defaults to `kMkNN`, but you can play around with the
parameters & methods. The package was written with massive scale in
mind, but if you are looking at smaller data sets with clear structure
and low dimensionality (like in this vignettes), `kMkNN` does the job
(fast). If you have high dimensional data and/or massive amounts of
samples, some of the other methods will shine.

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
  kmknn = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "kmknn",
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
      nn_params = params_nn(extract_knn = TRUE),
      .verbose = FALSE
    )
  },
  ivf = {
    generate_knn_graph(
      data = cluster_data$data,
      k = k,
      knn_method = "ivf",
      nn_params = params_nn(),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive  3.305564  3.305564  3.305564  3.305564  3.305564  3.305564     1
#>       kmknn  4.009159  4.009159  4.009159  4.009159  4.009159  4.009159     1
#>       annoy 21.695311 21.695311 21.695311 21.695311 21.695311 21.695311     1
#>        hnsw 14.626763 14.626763 14.626763 14.626763 14.626763 14.626763     1
#>    balltree  3.027331  3.027331  3.027331  3.027331  3.027331  3.027331     1
#>   nndescent 29.492471 29.492471 29.492471 29.492471 29.492471 29.492471     1
#>         ivf  3.997573  3.997573  3.997573  3.997573  3.997573  3.997573     1
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
  kmknn = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "kmknn",
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
  ivf = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "ivf",
      nn_params = params_nn(n_probe = 25L),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive 3006.5699 3006.5699 3006.5699 3006.5699 3006.5699 3006.5699     1
#>       kmknn 1499.2888 1499.2888 1499.2888 1499.2888 1499.2888 1499.2888     1
#>       annoy 2396.6277 2396.6277 2396.6277 2396.6277 2396.6277 2396.6277     1
#>        hnsw 1604.9080 1604.9080 1604.9080 1604.9080 1604.9080 1604.9080     1
#>    balltree  984.1435  984.1435  984.1435  984.1435  984.1435  984.1435     1
#>   nndescent 1298.0774 1298.0774 1298.0774 1298.0774 1298.0774 1298.0774     1
#>         ivf 1398.0691 1398.0691 1398.0691 1398.0691 1398.0691 1398.0691     1
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
  kmknn = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "kmknn",
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
      nn_params = params_nn(extract_knn = TRUE),
      .verbose = FALSE
    )
  },
  ivf = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "ivf",
      nn_params = params_nn(n_probe = 25L),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: seconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive 11.932022 11.932022 11.932022 11.932022 11.932022 11.932022     1
#>       kmknn  4.334100  4.334100  4.334100  4.334100  4.334100  4.334100     1
#>       annoy  6.286760  6.286760  6.286760  6.286760  6.286760  6.286760     1
#>        hnsw  4.127951  4.127951  4.127951  4.127951  4.127951  4.127951     1
#>    balltree  4.138534  4.138534  4.138534  4.138534  4.138534  4.138534     1
#>   nndescent  2.793984  2.793984  2.793984  2.793984  2.793984  2.793984     1
#>         ivf  3.456439  3.456439  3.456439  3.456439  3.456439  3.456439     1
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

indices <- c("hnsw", "annoy", "nndescent", "balltree", "ivf", "kmknn")

for (idx in indices) {
  idx_i <- generate_knn_graph(
    data = benchmark_data$data,
    k = k,
    nn_params = params_nn(extract_knn = TRUE, n_probe = 25L),
    knn_method = idx,
    .verbose = FALSE
  )

  recall_i <- sum(get_idx_flat(exhaustive) == get_idx_flat(idx_i)) /
    (k * samples)

  print(
    sprintf("ANN method %s achieves a Recall of %.3f.", idx, recall_i)
  )
}
#> [1] "ANN method hnsw achieves a Recall of 0.998."
#> [1] "ANN method annoy achieves a Recall of 1.000."
#> [1] "ANN method nndescent achieves a Recall of 1.000."
#> [1] "ANN method balltree achieves a Recall of 0.982."
#> [1] "ANN method ivf achieves a Recall of 0.967."
#> [1] "ANN method kmknn achieves a Recall of 1.000."
```

As you can see, all of these methods are able to (mostly) identify the
right neighbours (in the right order!). If you wish to understand more
how these methods work, how they compare, etc., please check this
[out](https://github.com/GregorLueg/ann-search-rs).
