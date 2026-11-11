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

# as N x idx nearest neighbours matrix
indices_mat <- get_idx_mat(exhaustive)
```

The distances can also be extracted easily:

``` r

# flat representation of the distances
dist_flat <- get_dist_flat(exhaustive)

# as N x idx nearest neighbours matrix
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

Let’s just have a look on how the different kNN methods perform on
different sizes.

``` r

cluster_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = 1000L
)

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
#>  exhaustive  3.460949  3.460949  3.460949  3.460949  3.460949  3.460949     1
#>       kmknn  4.051307  4.051307  4.051307  4.051307  4.051307  4.051307     1
#>       annoy 23.977074 23.977074 23.977074 23.977074 23.977074 23.977074     1
#>        hnsw 26.016299 26.016299 26.016299 26.016299 26.016299 26.016299     1
#>    balltree  2.759599  2.759599  2.759599  2.759599  2.759599  2.759599     1
#>   nndescent  5.895572  5.895572  5.895572  5.895572  5.895572  5.895572     1
#>         ivf  4.332866  4.332866  4.332866  4.332866  4.332866  4.332866     1
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
      nn_params = params_nn(n_probes = 25L),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive 3786.5955 3786.5955 3786.5955 3786.5955 3786.5955 3786.5955     1
#>       kmknn 1144.6005 1144.6005 1144.6005 1144.6005 1144.6005 1144.6005     1
#>       annoy 2902.7966 2902.7966 2902.7966 2902.7966 2902.7966 2902.7966     1
#>        hnsw 2801.9854 2801.9854 2801.9854 2801.9854 2801.9854 2801.9854     1
#>    balltree  955.7548  955.7548  955.7548  955.7548  955.7548  955.7548     1
#>   nndescent  379.6754  379.6754  379.6754  379.6754  379.6754  379.6754     1
#>         ivf  968.1487  968.1487  968.1487  968.1487  968.1487  968.1487     1
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
      .verbose = FALSE
    )
  },
  ivf = {
    generate_knn_graph(
      data = benchmark_data$data,
      k = k,
      knn_method = "ivf",
      nn_params = params_nn(n_probes = 25L),
      .verbose = FALSE
    )
  },
  times = 1L # single comparison for speed
)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>  exhaustive 15197.739 15197.739 15197.739 15197.739 15197.739 15197.739     1
#>       kmknn  3883.159  3883.159  3883.159  3883.159  3883.159  3883.159     1
#>       annoy  7433.831  7433.831  7433.831  7433.831  7433.831  7433.831     1
#>        hnsw  7573.029  7573.029  7573.029  7573.029  7573.029  7573.029     1
#>    balltree  3485.894  3485.894  3485.894  3485.894  3485.894  3485.894     1
#>   nndescent   863.582   863.582   863.582   863.582   863.582   863.582     1
#>         ivf  2512.772  2512.772  2512.772  2512.772  2512.772  2512.772     1
```

#### Precision

In the end, these are approximate methods. So, we need to understand how
good they are at recovering the true neighbours. Two metrics:

- `Recall@k`: the fraction of the true `k` neighbours that the method
  found, regardless of order.
- Mean distance ratio: distance to the approximate neighbour divided by
  the distance to the true neighbour at the same rank, averaged over
  everything. 1.0 means perfect. It tells you how *wrong* the misses
  are.

Let’s have a look at 25k samples:

``` r

samples <- 25000L

benchmark_data <- manifold_synthetic_data(
  type = "cluster",
  n_samples = samples
)

exhaustive <- generate_knn_graph(
  data = benchmark_data$data,
  k = k,
  knn_method = "exhaustive",
  .verbose = FALSE
)

true_idx <- get_idx_mat(exhaustive)
true_dist <- get_dist_mat(exhaustive)

indices <- c("hnsw", "annoy", "nndescent", "balltree", "ivf", "kmknn")

precision <- purrr::map(indices, \(idx) {
  knn_i <- generate_knn_graph(
    data = benchmark_data$data,
    k = k,
    nn_params = params_nn(n_probes = 25L),
    knn_method = idx,
    .verbose = FALSE
  )
  idx_i <- get_idx_mat(knn_i)

  hits <- purrr::map_int(seq_len(samples), \(i) {
    length(intersect(true_idx[i, ], idx_i[i, ]))
  })

  data.frame(
    method = idx,
    recall = sum(hits) / (k * samples),
    dist_ratio = mean(get_dist_mat(knn_i) / true_dist)
  )
})

knitr::kable(
  do.call(rbind, precision),
  digits = 4,
  col.names = c("Method", "Recall@k", "Mean distance ratio")
)
```

| Method    | Recall@k | Mean distance ratio |
|:----------|---------:|--------------------:|
| hnsw      |   0.9998 |              1.0000 |
| annoy     |   1.0000 |              1.0000 |
| nndescent |   0.9651 |              1.0011 |
| balltree  |   0.9942 |              1.0002 |
| ivf       |   0.9920 |              1.0003 |
| kmknn     |   1.0000 |              1.0000 |

NNDescent has the lowest recall here, but the distance ratio tells the
real story: the neighbours it misses are basically as close as the true
ones. The synthetic data has very tight clusters, so plenty of points
sit at near identical distances and swapping one for another costs
nothing. For manifold learning that is exactly the kind of miss you
don’t care about. If you wish to understand more how these methods work,
how they compare, etc., please check this
[out](https://github.com/GregorLueg/ann-search-rs).
