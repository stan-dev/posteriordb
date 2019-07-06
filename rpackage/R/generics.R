posterior_file_path <-function(x, pdbo = NULL){
  UseMethod("posterior_file_path")
}

#' @export
posterior_file_path.character <- function(x, pdbo = NULL){
  checkmate::assert_choice(x, names(pdbo))
  checkmate::assert_class(pdbo, "pdb")
  file.path(pdbo$path, "posteriors", paste0(x, ".json"))
}

#' @export
posterior_file_path.posterior <- function(x, pdbo = NULL){
  checkmate::assert_class(pdbo, "pdb", null.ok = TRUE)
  file.path(x$pdb$path, "posteriors", paste0(x$name, ".json"))
}
