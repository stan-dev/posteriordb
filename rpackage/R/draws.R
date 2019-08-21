#' Extract posterior draws
#'
#' @param x an object to extract  draws from.
#'
#' @export
draws <-function(x){
  UseMethod("draws")
}

#' @export
draws.posterior_fit <- function(x){
  as.data.frame(x$posterior_draws)
}
