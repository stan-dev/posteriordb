#' Access model and data information
#' 
#' @param po a \code{posterior} object.
#' @export
model_info <- function(po){
  checkmate::assert_class(po, "posterior")
  po$model_info
}

#' @rdname model_info
#' @export
data_info <- function(po){
  checkmate::assert_class(po, "posterior")
  po$data_info
}

