# forceatlas2 ------------------------------------------------------------------

## param combination -----------------------------------------------------------

#' Internal helper to prepare the ForceAtlas2 parameters
#'
#' @param knn_method String. Method to use to generate the kNN graph.
#' @param nn_params Named list. The nearest neighbour search parameters.
#' @param fa2_params Named list. The ForceAtlas2-specific parameters.
#'
#' @return Returns the list of final parameters.
#'
#' @export
#'
#' @keywords internal
.prepare_fa2_params <- function(knn_method, nn_params, fa2_params) {
  # checks
  checkmate::assertChoice(
    knn_method,
    c(
      "kmknn",
      "balltree",
      "hnsw",
      "annoy",
      "nndescent",
      "exhaustive",
      "ivf"
    )
  )
  assertNnParams(nn_params)
  assertFa2Params(fa2_params)

  final_params <- c(nn_params, fa2_params)
  final_params[["knn_method"]] <- knn_method

  final_params
}

## main functions --------------------------------------------------------------

#' Rust-based ForceAtlas2
#'
#' @description Lays out the kNN graph of the data with ForceAtlas2, the way
#' scanpy's `draw_graph` does: the kNN graph is turned into the UMAP fuzzy
#' union graph and every edge pulls, every node pair pushes (`1/d`, with masses
#' `1 + degree`), plus gravity towards the origin. Repulsion runs on a
#' Barnes-Hut tree. Already have a graph? Use [forceatlas2_from_graph()].
#'
#' @param data Numerical matrix or data frame. The data to embed of shape
#' samples x features. Will be coerced to a matrix.
#' @param knn Optional `NearestNeighbours` class. If provided, the k-nearest
#' neighbour search is skipped and this one is used. Defaults to `NULL`.
#' @param k Integer. Number of nearest neighbours. Defaults to `15L`.
#' @param knn_method Character. (Approximate) Nearest neighbour method to use.
#' One of `"kmknn"`, `"hnsw"`, `"annoy"`, `"nndescent"`, `"balltree"`, `"ivf"`
#' or `"exhaustive"`. Defaults to `"kmknn"`.
#' @param nn_params Named list. Nearest neighbour search parameters, see
#' [params_nn()].
#' @param fa2_params Named list. ForceAtlas2 parameters, see [params_fa2()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions samples x 2 containing the
#' ForceAtlas2 layout.
#'
#' @references Jacomy, et al., PLoS ONE, 2014
#'
#' @export
forceatlas2 <- function(
  data,
  knn = NULL,
  k = 15L,
  knn_method = c(
    "kmknn",
    "balltree",
    "hnsw",
    "annoy",
    "nndescent",
    "exhaustive",
    "ivf"
  ),
  nn_params = params_nn(),
  fa2_params = params_fa2(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
) {
  # transformation
  if (is.data.frame(data)) {
    data <- as.matrix(data)
  }
  knn_method <- match.arg(knn_method)

  checkmate::assert_matrix(
    data,
    mode = "numeric",
    any.missing = FALSE,
    min.rows = 2,
    min.cols = 1
  )
  checkmate::assert(
    checkmate::testNull(knn),
    checkmate::testClass(knn, "NearestNeighbours")
  )
  checkmate::qassert(k, "I1[2,)")
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(seed, "I1")

  final_fa2_params <- .prepare_fa2_params(
    knn_method = knn_method,
    nn_params = nn_params,
    fa2_params = fa2_params
  )

  res <- if (!is.null(knn)) {
    if (.verbose) {
      message("Using provided kNN graph.")
    }
    rs_forceatlas2_from_knn(
      embd = data,
      knn_data = knn,
      k = k,
      fa2_params = final_fa2_params,
      seed = seed,
      use_high_precision = use_high_precision,
      verbose = parse_verbosity(.verbose)
    )
  } else {
    rs_forceatlas2(
      embd = data,
      k = k,
      fa2_params = final_fa2_params,
      seed = seed,
      use_high_precision = use_high_precision,
      verbose = parse_verbosity(.verbose)
    )
  }

  res
}

#' Rust-based ForceAtlas2 on a pre-computed graph
#'
#' @description Lays out any undirected graph with ForceAtlas2, for example an
#' SNN graph or a graph from another package. Edge weights come from the
#' `weight` edge attribute; without one, every edge weighs `1`. Self-loops are
#' dropped. Only the optimisation parameters in `fa2_params` are used; the
#' graph and initialisation ones do not apply here.
#'
#' @param graph An undirected `igraph` object without multi-edges. Use
#' `igraph::as_undirected(mode = "collapse")` or `igraph::simplify()` to get
#' there. If present, the `weight` edge attribute needs to be finite and
#' non-negative.
#' @param init Optional numerical matrix of dimensions `vcount(graph) x 2`.
#' The initial layout, e.g. a UMAP of the same samples. If `NULL`, a random
#' layout is used. Defaults to `NULL`.
#' @param fa2_params Named list. ForceAtlas2 parameters, see [params_fa2()].
#' @param seed Integer. Random seed for reproducibility. Defaults to `42L`.
#' @param use_high_precision Optional boolean. Gives fine-grained control over
#' `fp32` vs `fp64` usage.
#' @param .verbose Logical. Controls verbosity. Defaults to `TRUE`.
#'
#' @return A numerical matrix with dimensions `vcount(graph) x 2` containing
#' the ForceAtlas2 layout, rows in vertex order.
#'
#' @references Jacomy, et al., PLoS ONE, 2014
#'
#' @export
forceatlas2_from_graph <- function(
  graph,
  init = NULL,
  fa2_params = params_fa2(),
  seed = 42L,
  use_high_precision = NULL,
  .verbose = TRUE
) {
  checkmate::assertClass(graph, "igraph")
  if (igraph::is_directed(graph)) {
    stop(
      "ForceAtlas2 needs an undirected graph. ",
      "Use igraph::as_undirected(graph, mode = \"collapse\")."
    )
  }
  if (igraph::any_multiple(graph)) {
    stop(
      "The graph has multi-edges. Use igraph::simplify() to merge them."
    )
  }
  n <- igraph::vcount(graph)
  checkmate::assertNumber(n, lower = 2)
  checkmate::assert(
    checkmate::testNull(init),
    checkmate::testMatrix(
      init,
      mode = "numeric",
      any.missing = FALSE,
      nrows = n,
      ncols = 2
    )
  )
  assertFa2Params(fa2_params)
  checkmate::qassert(.verbose, c("B1", "I1[0, 2]"))
  checkmate::qassert(use_high_precision, c("0", "B1"))
  checkmate::qassert(seed, "I1")

  if (!is.null(init)) {
    storage.mode(init) <- "double"
  }

  edges <- igraph::as_edgelist(graph, names = FALSE)
  weight <- igraph::E(graph)$weight
  if (is.null(weight)) {
    weight <- rep(1, nrow(edges))
  }
  checkmate::assertNumeric(
    weight,
    lower = 0,
    finite = TRUE,
    any.missing = FALSE
  )

  rs_forceatlas2_from_graph(
    from = as.integer(edges[, 1]),
    to = as.integer(edges[, 2]),
    weight = as.numeric(weight),
    n = as.integer(n),
    init = init,
    fa2_params = fa2_params,
    seed = seed,
    use_high_precision = use_high_precision,
    verbose = parse_verbosity(.verbose)
  )
}
