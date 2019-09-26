#' Extract posterior draws
#'
#' @param x an object to extract draws from.
#'
#' @export
posterior_draws <- function(x) {
  UseMethod("posterior_draws")
}

#' @export
posterior_draws.posterior_fit <- function(x) {
  x$posterior_draws
}
