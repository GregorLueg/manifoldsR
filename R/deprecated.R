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
