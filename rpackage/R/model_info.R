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
read_model_info <- function(x, pdb = NULL, ...) {
  model_info <- read_info_json(x, path = "models/info", pdb = pdb, ...)
  class(model_info) <- "pdb_model_info"
  model_info
}

#' @export
print.pdb_model_info <- function(x, ...) {
  cat0("Model: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}
