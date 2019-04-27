#' Access a posterior in the posterior database
#' 
#' @param x a file path to a posterior json, or a posterior_name (require i.e. internet access)
#' @export
posterior <- function(x){
  checkmate::assert_file_exists(x)
  post_json <- jsonlite::read_json(x)
  class(post_json) <- c("posterior", "list")
  assert_posterior(post_json)
  post_json
}

assert_posterior <- function(x){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_list(x)  
  checkmate::assert_names(names(x), must.include = c("model", "data"))  
  checkmate::assert_file_exists(paste0(x$data, ".zip"))
  checkmate::assert_list(x$model, min.len = 1)
}
