#' Access data and model information
#'
#' @param po a \code{posterior} object.
#'
#' @export
model_info <- function(x, ...) {
  UseMethod("model_info")
}

#' @rdname model_info
#' @export
model_info.pdb_posterior <- function(x, ...) {
  po$model_info
}

#' @rdname model_info
#' @export
model_info.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  read_model_info(x, pdb)
}

# read model info from the data base
read_model_info <- function(x, pdb = NULL, ...) {
  model_info <- read_info_json(x, path = "models/info", pdb = pdb, ...)
  class(model_info) <- "pdb_model_info"
  assert_model_info(model_info)
  model_info
}

#' @export
print.pdb_model_info <- function(x, ...) {
  cat0("Model: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}


assert_model_info <- function(x){
  checkmate::assert_names(names(x),
                          subset.of = c("name", "model_code", "title", "added_by", "added_date", "references", "description", "urls", "keywords"),
                          must.include = c("name", "model_code", "title", "added_by", "added_date"))
  checkmate::assert_string(x$name)
  checkmate::assert_list(x$model_code)
  checkmate::assert_names(names(x$model_code), subset.of = c("stan"))
  checkmate::assert_string(x$title)
  checkmate::assert_string(x$added_by)
  checkmate::assert_date(x$added_date)

  checkmate::assert_list(x$references, null.ok = TRUE)
  checkmate::assert_string(x$description, null.ok = TRUE)
  checkmate::assert_list(x$urls, null.ok = TRUE)
  checkmate::assert_list(x$keywords, null.ok = TRUE)
}
