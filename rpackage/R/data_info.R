#' @rdname model_info
#' @export
data_info <- function(po) {
  checkmate::assert_class(po, "posterior")
  po$data_info
}

# read data info from the data base
read_data_info <- function(po) {
  checkmate::assert_class(po, "posterior")
  data_info_path <- data_info_file_path(po$data_name, po$pdb$path)
  data_info <- jsonlite::read_json(data_info_path)
  data_info$name <- po$data_name
  data_info$added_date <- as.Date(data_info$added_date)
  class(data_info) <- "data_info"
  data_info
}

data_info_file_path <- function(name, base_dir) {
  file.path(base_dir, "content", "data", "info", paste0(name, ".info.json"))
}

#' @export
print.data_info <- function(x, ...) {
  cat0("Data: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}
