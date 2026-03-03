# checkmate extensions ---------------------------------------------------------

## branching -------------------------------------------------------------------

#' Check cell trajectory parameters
#'
#' @description Checkmate extension for checking the cell trajectory
#' parameters.
#'
#' @param x The list to check. Must be a named list with the following
#' elements:
#' \itemize{
#'  \item `parent` - Integer vector. Parent branch index for each branch.
#'  Use `NA` for the root branch. Indices are zero-based.
#'  \item `split_at` - Numeric vector. Fraction along the parent branch where
#'  the branch splits off. Must be between 0 and 1.
#'  \item `length` - Numeric vector. Length of each branch.
#' }
#' All three vectors must be of equal length.
#'
#' @return `TRUE` if the check was successful, otherwise an error message.
#'
#' @keywords internal
checkCellTrajectories <- function(x) {
  res <- checkmate::checkList(x)
  if (!isTRUE(res)) {
    return(res)
  }
  res <- checkmate::checkNames(
    names(x),
    must.include = c("parent", "split_at", "length")
  )
  if (!isTRUE(res)) {
    return(res)
  }
  if (!is.integer(x$parent) && !all(is.na(x$parent))) {
    return("'parent' must be an integer vector")
  }
  if (!checkmate::qtest(x$split_at, "N+")) {
    return("'split_at' must be a numeric vector")
  }
  if (!checkmate::qtest(x$length, "N+")) {
    return("'length' must be a numeric vector")
  }
  if (
    length(unique(c(length(x$parent), length(x$split_at), length(x$length)))) !=
      1L
  ) {
    return("'parent', 'split_at' and 'length' must all be of equal length")
  }
  return(TRUE)
}

#' Assert cell trajectory parameters
#'
#' @description Checkmate extension for asserting the cell trajectory
#' parameters.
#'
#' @inheritParams checkCellTrajectories
#'
#' @param .var.name Name of the checked object to print in assertions. Defaults
#' to the heuristic implemented in checkmate.
#' @param add Collection to store assertion messages. See
#' [checkmate::makeAssertCollection()].
#'
#' @return Invisibly returns the checked object if the assertion is successful.
#'
#' @keywords internal
assertCellTrajectories <- checkmate::makeAssertionFunction(
  checkCellTrajectories
)

## nearest neighbours ----------------------------------------------------------

#' Check nearest neighbour parameters
#'
#' @description Checkmate extension for checking the nearest neighbour
#' parameters.
#'
#' @param x The list to check.
#'
#' @return `TRUE` if the check was successful, otherwise an error message.
#'
#' @keywords internal
checkNnParams <- function(x) {
  res <- checkmate::checkList(x)
  if (!isTRUE(res)) {
    return(res)
  }
  res <- checkmate::checkNames(
    names(x),
    must.include = c(
      "dist_metric",
      "n_tree",
      "search_budget",
      "m",
      "ef_construction",
      "ef_search",
      "diversify_prob",
      "delta",
      "ef_budget",
      "bt_budget"
    )
  )
  if (!isTRUE(res)) {
    return(res)
  }
  rules <- list(
    "dist_metric" = list(type = "choice", choices = c("cosine", "euclidean")),
    "n_tree" = list(type = "fixed", rule = "I1"),
    "search_budget" = list(type = "nullable_int"),
    "m" = list(type = "fixed", rule = "I1"),
    "ef_construction" = list(type = "fixed", rule = "I1"),
    "ef_search" = list(type = "fixed", rule = "I1"),
    "diversify_prob" = list(type = "fixed", rule = "N1"),
    "delta" = list(type = "fixed", rule = "N1"),
    "ef_budget" = list(type = "nullable_int"),
    "bt_budget" = list(type = "fixed", rule = "N1")
  )
  res <- purrr::imap_lgl(x, \(val, name) {
    spec <- rules[[name]]
    if (spec$type == "choice") {
      checkmate::testChoice(val, spec$choices)
    } else if (spec$type == "nullable_int") {
      is.null(val) || checkmate::qtest(val, "I1")
    } else {
      checkmate::qtest(val, spec$rule)
    }
  })
  if (!isTRUE(all(res))) {
    broken_elem <- names(res)[which(!res)][1]
    return(
      sprintf(
        paste(
          "The following element `%s` in nearest neighbour params does not",
          "dist_metric must be one of 'cosine' or 'euclidean',",
          "conform to the expected format. dist_metric must be a string,",
          "n_tree/m/ef_construction/ef_search must be integers,",
          "search_budget/ef_budget must be integers or NULL,",
          "and diversify_prob/delta/bt_budget must be numerics."
        ),
        broken_elem
      )
    )
  }
  return(TRUE)
}

#' Assert nearest neighbour parameters
#'
#' @description Checkmate extension for asserting the nearest neighbour
#' parameters.
#'
#' @inheritParams checkNnParams
#'
#' @param .var.name Name of the checked object to print in assertions. Defaults
#' to the heuristic implemented in checkmate.
#' @param add Collection to store assertion messages. See
#' [checkmate::makeAssertCollection()].
#'
#' @return Invisibly returns the checked object if the assertion is successful.
#'
#' @keywords internal
assertNnParams <- checkmate::makeAssertionFunction(checkNnParams)

## umap ------------------------------------------------------------------------

#' Check UMAP parameters
#'
#' @description Checkmate extension for checking the UMAP parameters.
#'
#' @param x The list to check.
#'
#' @return `TRUE` if the check was successful, otherwise an error message.
#'
#' @keywords internal
checkUmapParams <- function(x) {
  res <- checkmate::checkList(x)
  if (!isTRUE(res)) {
    return(res)
  }

  res <- checkmate::checkNames(
    names(x),
    must.include = c(
      "local_connectivity",
      "bandwidth",
      "mix_weight",
      "lr",
      "n_epochs",
      "neg_sample_rate",
      "gamma",
      "optimiser",
      "init",
      "randomised"
    )
  )
  if (!isTRUE(res)) {
    return(res)
  }

  rules <- list(
    "local_connectivity" = list(type = "fixed", rule = "N1"),
    "bandwidth" = list(type = "fixed", rule = "N1"),
    "mix_weight" = list(type = "fixed", rule = "N1"),
    "lr" = list(type = "fixed", rule = "N1"),
    "n_epochs" = list(type = "nullable_int"),
    "neg_sample_rate" = list(type = "fixed", rule = "I1"),
    "gamma" = list(type = "fixed", rule = "N1"),
    "optimiser" = list(
      type = "choice",
      choices = c("sgd", "adam", "adam_parallel")
    ),
    "init" = list(type = "choice", choices = c("spectral", "pca", "random")),
    "randomised" = list(type = "fixed", rule = "B1")
  )

  res <- purrr::imap_lgl(x, \(val, name) {
    spec <- rules[[name]]
    if (spec$type == "choice") {
      checkmate::testChoice(val, spec$choices)
    } else if (spec$type == "nullable_int") {
      is.null(val) || checkmate::qtest(val, "I1")
    } else {
      checkmate::qtest(val, spec$rule)
    }
  })

  if (!isTRUE(all(res))) {
    broken_elem <- names(res)[which(!res)][1]
    return(sprintf(
      paste(
        "Element `%s` in UMAP params does not conform.",
        "local_connectivity/bandwidth/mix_weight/lr/gamma must be numeric,",
        "neg_sample_rate must be an integer,",
        "n_epochs must be a positive integer or NULL,",
        "optimiser must be one of 'sgd'/'adam'/'adam_parallel',",
        "init must be one of 'spectral'/'pca'/'random',",
        "and randomised must be logical."
      ),
      broken_elem
    ))
  }

  return(TRUE)
}

#' Assert UMAP parameters
#'
#' @description Checkmate extension for asserting the UMAP parameters.
#'
#' @inheritParams checkUmapParams
#'
#' @param .var.name Name of the checked object to print in assertions. Defaults
#' to the heuristic implemented in checkmate.
#' @param add Collection to store assertion messages. See
#' [checkmate::makeAssertCollection()].
#'
#' @return Invisibly returns the checked object if the assertion is successful.
#'
#' @keywords internal
assertUmapParams <- checkmate::makeAssertionFunction(checkUmapParams)

## tsne ------------------------------------------------------------------------

#' Check t-SNE parameters
#'
#' @description Checkmate extension for checking the t-SNE parameters.
#'
#' @param x The list to check.
#'
#' @return `TRUE` if the check was successful, otherwise an error message.
#'
#' @keywords internal
checkTsneParams <- function(x) {
  res <- checkmate::checkList(x)
  if (!isTRUE(res)) {
    return(res)
  }
  res <- checkmate::checkNames(
    names(x),
    must.include = c(
      "lr",
      "n_epochs",
      "early_exag_iter",
      "early_exag_factor",
      "theta",
      "n_interp_points",
      "init",
      "randomised"
    )
  )
  if (!isTRUE(res)) {
    return(res)
  }
  rules <- list(
    "lr" = list(type = "fixed", rule = "N1"),
    "n_epochs" = list(type = "fixed", rule = "I1[1,)"),
    "early_exag_iter" = list(type = "fixed", rule = "I1[1,)"),
    "early_exag_factor" = list(type = "fixed", rule = "N1"),
    "theta" = list(type = "fixed", rule = "N1[0,1]"),
    "n_interp_points" = list(type = "fixed", rule = "I1[1,)"),
    "init" = list(type = "choice", choices = c("spectral", "pca", "random")),
    "randomised" = list(type = "fixed", rule = "B1")
  )
  res <- purrr::imap_lgl(x, \(val, name) {
    spec <- rules[[name]]
    if (spec$type == "choice") {
      checkmate::testChoice(val, spec$choices)
    } else {
      checkmate::qtest(val, spec$rule)
    }
  })
  if (!isTRUE(all(res))) {
    broken_elem <- names(res)[which(!res)][1]
    return(sprintf(
      paste(
        "Element `%s` in t-SNE params does not conform.",
        "lr/early_exag_factor/theta must be numeric,",
        "n_epochs/early_exag_iter/n_interp_points must be positive integers,",
        "theta must be between 0 and 1,",
        "init must be one of 'spectral'/'pca'/'random',",
        "and randomised must be logical."
      ),
      broken_elem
    ))
  }
  return(TRUE)
}

#' Assert t-SNE parameters
#'
#' @description Checkmate extension for asserting the t-SNE parameters.
#'
#' @inheritParams checkTsneParams
#'
#' @param .var.name Name of the checked object to print in assertions. Defaults
#' to the heuristic implemented in checkmate.
#' @param add Collection to store assertion messages. See
#' [checkmate::makeAssertCollection()].
#'
#' @return Invisibly returns the checked object if the assertion is successful.
#'
#' @keywords internal
assertTsneParams <- checkmate::makeAssertionFunction(checkTsneParams)

## phate -----------------------------------------------------------------------

#' Check PHATE parameters
#'
#' @description Checkmate extension for checking the PHATE parameters.
#'
#' @param x The list to check.
#'
#' @return `TRUE` if the check was successful, otherwise an error message.
#'
#' @keywords internal
checkPhateParams <- function(x) {
  res <- checkmate::checkList(x)
  if (!isTRUE(res)) {
    return(res)
  }

  res <- checkmate::checkNames(
    names(x),
    must.include = c(
      "decay",
      "bandwidth_scale",
      "t_max",
      "t_custom",
      "gamma",
      "n_landmarks",
      "landmark_method",
      "n_svd",
      "mds_method",
      "graph_symmetry"
    )
  )
  if (!isTRUE(res)) {
    return(res)
  }

  nullable_int <- function(v) is.null(v) || checkmate::qtest(v, "I1[1,)")
  nullable_num <- function(v) is.null(v) || checkmate::qtest(v, "N1(0,)")

  rules <- list(
    "decay" = function(v) checkmate::qtest(v, "N1(0,)"),
    "bandwidth_scale" = nullable_num,
    "t_max" = function(v) checkmate::qtest(v, "I1[1,)"),
    "t_custom" = nullable_int,
    "gamma" = function(v) checkmate::qtest(v, "N1"),
    "n_landmarks" = nullable_int,
    "landmark_method" = function(v) {
      checkmate::testChoice(v, c("spectral", "random", "density"))
    },
    "n_svd" = nullable_int,
    "mds_method" = function(v) {
      checkmate::testChoice(v, c("sgd_dense", "classic"))
    },
    "graph_symmetry" = function(v) {
      checkmate::testChoice(v, c("additive", "multiplicative", "mnn", "none"))
    }
  )

  res <- purrr::imap_lgl(x, \(val, name) rules[[name]](val))

  if (!isTRUE(all(res))) {
    broken_elem <- names(res)[which(!res)][1]
    return(sprintf(
      paste(
        "Element `%s` in PHATE params does not conform.",
        "decay must be a positive numeric,",
        "bandwidth_scale must be a positive numeric or NULL,",
        "t_max must be a positive integer,",
        "t_custom/n_landmarks/n_svd must be positive integers or NULL,",
        "gamma must be numeric,",
        "landmark_method must be one of 'spectral'/'random'/'min_max',",
        "mds_method must be one of 'sgd_dense'/'classic',",
        "and graph_symmetry must be one of 'additive'/'multiplicative'/'mnn'/'none'."
      ),
      broken_elem
    ))
  }

  return(TRUE)
}

#' Assert PHATE parameters
#'
#' @description Checkmate extension for asserting the PHATE parameters.
#'
#' @inheritParams checkPhateParams
#'
#' @param .var.name Name of the checked object to print in assertions. Defaults
#' to the heuristic implemented in checkmate.
#' @param add Collection to store assertion messages. See
#' [checkmate::makeAssertCollection()].
#'
#' @return Invisibly returns the checked object if the assertion is successful.
#'
#' @keywords internal
assertPhateParams <- checkmate::makeAssertionFunction(checkPhateParams)
