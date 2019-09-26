#' Constructor for \code{posterior_fit} objects
#'
#' @param path A file path to a JSON file containing a posterior fit object
#'
posterior_fit <- function(path) {
  out <- jsonlite::read_json(path, simplifyVector = TRUE)
  must.include <- c("posterior_draws", "cfg")
  checkmate::assert_names(names(out), must.include = must.include)
  out$posterior_draws <- as.data.frame(out$posterior_draws)
  class(out) <- "posterior_fit"
  out
}
