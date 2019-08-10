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
  
  model_info_path <- model_info_file_path(po$model_name, pdbo$path)
  po$model_info <- jsonlite::read_json(model_info_path)
  
  data_info_path <- data_info_file_path(po$data_name, pdbo$path)
  po$data_info <- jsonlite::read_json(data_info_path)
  po$name <- name
  po$pdb <- pdbo
  assert_posterior(po)
  po
}

model_info_file_path <- function(name, base_dir) {
  path <- file.path(base_dir, "models", paste0(name, ".info.json"))
  path
}

data_info_file_path <- function(name, base_dir) {
  path <- file.path(base_dir, "datasets", paste0(name, ".info.json"))
  path
}

assert_posterior <- function(x){
  checkmate::assert_class(x, "posterior")
  checkmate::assert_list(x)  
  checkmate::assert_names(names(x), must.include = c("model_name", "data_name", "model_info", "data_info", "name", "pdb"))  
  checkmate::assert_list(x$model_info, min.len = 1)
}
