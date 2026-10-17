# deprecated function calls ----------------------------------------------------

#' @rdname new_nearest_neighbour
#'
#' @export
generate_nearest_neigbours_class <- function(indices, dist, k, n) {
  lifecycle::deprecate_warn(
    "0.2.0",
    "generate_nearest_neigbours_class()",
    "new_nearest_neighbour()"
  )
  new_nearest_neighbour(indices = indices, dist = dist, k = k, n = n)
}

#' Deprecated functions in manifoldsR
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#' These names carried typos and were renamed in 0.5.0. Each forwards to its
#' replacement after a deprecation warning.
#' \itemize{
#'  \item `params_swiss_role()` -> [params_swiss_roll()]
#'  \item `params_swiss_role_biased()` -> [params_swiss_roll_biased()]
#'  \item `rs_data_swiss_role()` -> [rs_data_swiss_roll()]
#'  \item `rs_data_biased_swiss_role()` -> [rs_data_biased_swiss_roll()]
#'  \item `rs_intertia()` -> [rs_inertia()]
#' }
#'
#' @param ... Passed on to the replacement.
#'
#' @returns Whatever the replacement returns.
#'
#' @name manifoldsR-deprecated
#' @keywords internal
NULL

#' @rdname manifoldsR-deprecated
#'
#' @export
params_swiss_role <- function(...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "params_swiss_role()",
    "params_swiss_roll()"
  )
  params_swiss_roll(...)
}

#' @rdname manifoldsR-deprecated
#'
#' @export
params_swiss_role_biased <- function(...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "params_swiss_role_biased()",
    "params_swiss_roll_biased()"
  )
  params_swiss_roll_biased(...)
}

#' @rdname manifoldsR-deprecated
#'
#' @export
rs_data_swiss_role <- function(...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "rs_data_swiss_role()",
    "rs_data_swiss_roll()"
  )
  rs_data_swiss_roll(...)
}

#' @rdname manifoldsR-deprecated
#'
#' @export
rs_data_biased_swiss_role <- function(...) {
  lifecycle::deprecate_warn(
    "0.5.0",
    "rs_data_biased_swiss_role()",
    "rs_data_biased_swiss_roll()"
  )
  rs_data_biased_swiss_roll(...)
}

#' @rdname manifoldsR-deprecated
#'
#' @export
rs_intertia <- function(...) {
  lifecycle::deprecate_warn("0.5.0", "rs_intertia()", "rs_inertia()")
  rs_inertia(...)
}
