#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

#' Cap the thread pool under R CMD check --as-cran
#'
#' @description
#' CRAN flags examples and tests whose CPU time exceeds 2.5x elapsed, and the
#' default Rayon pool takes every core. `_R_CHECK_LIMIT_CORES_` is set by
#' `--as-cran`, so two threads it is. This works because Rayon builds its
#' global pool lazily on first use and reads `RAYON_NUM_THREADS` then. A value
#' the user already set is left alone.
#'
#' @param libname,pkgname Passed by R, unused.
#'
#' @noRd
.onLoad <- function(libname, pkgname) {
  limit <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_"))
  capped <- nzchar(limit) && limit != "false"
  if (capped && !nzchar(Sys.getenv("RAYON_NUM_THREADS"))) {
    Sys.setenv(RAYON_NUM_THREADS = "2")
  }
}
