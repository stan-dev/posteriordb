#' Access data and model information
#'
#' @param x a object to access information for.
#' @param pdb a \code{pdb} object.
#' @param ... further arguments to methods.
#'
#' @export
model_info <- function(x, ...) {
  UseMethod("model_info")
}

#' @rdname model_info
#' @export
pdb_model_info <- model_info

#' @rdname model_info
#' @export
model_info.pdb_posterior <- function(x, ...) {
  x$model_info
}

#' @rdname model_info
#' @export
model_info.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  read_model_info(x, pdb)
}

#' @rdname model_info
#' @export
model_info.list <- function(x, pdb = NULL, ...) {
  class(x) <- "pdb_model_info"
  assert_model_info(x)
  x
}

# read model info from the data base
read_model_info <- function(x, pdb, ...) {
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
                          subset.of = c("name", "model_implementations", "title", "prior", "added_by", "added_date", "references", "description", "urls", "keywords"),
                          must.include = c("name", "model_implementations", "title", "added_by", "added_date"))
  checkmate::assert_string(x$name)
  checkmate::assert_names(names(x$model_implementations), subset.of = supported_frameworks())
  for(i in seq_along(x$model_implementations)){
    checkmate::assert_names(names(x$model_implementations[[i]]), must.include = "model_code", subset.of = c("model_code", "likelihood_code"))
  }
  checkmate::assert_string(x$title)
  checkmate::assert_string(x$added_by)
  checkmate::assert_date(x$added_date)

  checkmate::assert_string(x$description, null.ok = TRUE)

  checkmate::assert_character(x$references, null.ok = TRUE)
  checkmate::assert_character(x$urls)
  checkmate::assert_character(x$keywords, null.ok = TRUE)
}
