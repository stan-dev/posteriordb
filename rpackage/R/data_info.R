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
read_data_info <- function(x, pdb = NULL, ...) {
  checkmate::assert_class(x, "pdb_posterior")
  data_info <- read_info_json(x, path = "data/info", pdb = pdb, ...)
  class(data_info) <- "pdb_data_info"
  assert_data_info(model_info)
  data_info
}

#' @export
print.pdb_data_info <- function(x, ...) {
  cat0("Data: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}
