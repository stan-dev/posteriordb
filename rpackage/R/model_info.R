#' Access data and model information
#'
#' @param po a \code{posterior} object.
#'
#' @export
model_info <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  po$model_info
}

# read model info from the data base
read_model_info <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  model_info_path <- model_info_file_path(po$model_name, po$pdb$path)
  model_info <- jsonlite::read_json(model_info_path)
  model_info$name <- po$model_name
  model_info$added_date <- as.Date(model_info$added_date)
  class(model_info) <- "pdb_model_info"
  model_info
}

model_info_file_path <- function(name, base_dir) {
  file.path(base_dir, "content", "models", "info", paste0(name, ".info.json"))
}

#' @export
print.pdb_model_info <- function(x, ...) {
  cat0("Model: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}
