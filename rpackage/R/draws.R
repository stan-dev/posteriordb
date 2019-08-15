
#' @export
draws <-function(x){
  UseMethod("draws")
}

#' @export
draws.posterior_fit <- function(x){
  as.data.frame(x$posterior_draws)
}
