#' @rdname model_info
#' @export
data_info <- function(x, ...) {
  UseMethod("data_info")
}

#' @rdname model_info
#' @export
data_info.pdb_posterior <- function(x, ...) {
  x$data_info
}

#' @rdname model_info
#' @export
data_info.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  read_data_info(x, pdb)
}

#' @rdname model_info
#' @export
data_info.list <- function(x, pdb = NULL, ...) {
  class(x) <- "pdb_data_info"
  assert_data_info(x)
  x
}

#' @rdname model_info
#' @export
pdb_data_info <- data_info



# read data info from the data base
read_data_info <- function(x, pdb, ...) {
  data_info <- read_info_json(x, path = "data/info", pdb = pdb, ...)
  class(data_info) <- "pdb_data_info"
  assert_data_info(data_info)
  data_info
}

#' @export
print.pdb_data_info <- function(x, ...) {
  cat0("Data: ", x$name, "\n")
  cat0(x$title, "\n")
  invisible(x)
}

assert_data_info <- function(x){
  checkmate::assert_names(names(x),
                          subset.of = c("name", "data_file", "title", "added_by", "added_date", "references", "description", "urls", "keywords"),
                          must.include = c("name", "data_file", "title", "added_by", "added_date"))
  checkmate::assert_string(x$name)
  checkmate::assert_string(x$data_file)
  checkmate::assert_string(x$title)
  checkmate::assert_string(x$added_by)
  checkmate::assert_date(x$added_date)

  checkmate::assert_character(x$references, null.ok = TRUE)
  checkmate::assert_string(x$description, null.ok = TRUE)
  checkmate::assert_character(x$urls, null.ok = TRUE)
  checkmate::assert_character(x$keywords, null.ok = TRUE)
}
