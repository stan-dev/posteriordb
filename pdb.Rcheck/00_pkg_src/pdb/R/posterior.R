#' Access a posterior in the posterior database
#' 
#' @param name a posterior name that exist in the posterior database
#' @param pdbo a \code{pdb} posterior database object.
#' @export
posterior <- function(name, pdbo = pdb()){
  checkmate::assert_class(pdbo, "pdb")
  checkmate::assert_character(name)
  checkmate::assert_choice(name, names(pdbo))
  pfn <- posterior_file_path(name, pdbo)
  po <- jsonlite::read_json(pfn)
  class(po) <- c("posterior", "list")
  po$name <- name
  po$pdb <- pdbo
  assert_posterior(po)
  po
}

assert_posterior <- function(x){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_list(x)  
  checkmate::assert_names(names(x), must.include = c("model", "data", "name", "pdb"))  
  checkmate::assert_list(x$model, min.len = 1)
}
