#' Access model and data information
#' 
#' @param po a \code{posterior} object.
#' @export
model_info <- function(po){
  checkmate::assert_class(po, "posterior")
  model_info_file <- paste0(remove_file_extension(po$model$stan), ".info.json")
  jsonlite::read_json(model_info_file)
}

#' @rdname model_info
#' @export
data_info <- function(po){
  checkmate::assert_class(po, "posterior")
  data_info_file <- paste0(remove_file_extension(po$data), ".info.json")
  jsonlite::read_json(data_info_file)
}

