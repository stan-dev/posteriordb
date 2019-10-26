#' @rdname model_info
#' @export
data_info <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  po$data_info
}
#' @rdname model_info
#' @export
pdb_data_info <- data_info

# read data info from the data base
read_data_info <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  data_info_path <- pdb_cached_local_file_path(po$pdb, file.path("data", "info", paste0(po$data_name, ".info.json")))
  data_info <- jsonlite::read_json(data_info_path)
  data_info$name <- po$data_name
  data_info$added_date <- as.Date(data_info$added_date)
  class(data_info) <- "pdb_data_info"
  data_info
}

#' @export
print.pdb_data_info <- function(x, ...) {
  cat0("Data: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}
