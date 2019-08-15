#' Constructor for posterior_fit objects
#' 
#' @param x an object to convert to a \code{posterior_fit}.
#' 
posterior_fit <- function(x){
  checkmate::assert_names(names(x), must.include = c("posterior_draws", "cfg"))
  class(x) <- "posterior_fit"
  x
}
