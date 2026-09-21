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
