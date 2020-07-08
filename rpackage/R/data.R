#' Posterior Data Sets
#'
#' @param x an object to access data from.
#' @param pdb a \code{pdb} object.
#' @param info a \code{pdb_data_info} object.
#' @param ... Currently not used.
#'
#' @export
get_data <- function(x, ...) {
  UseMethod("get_data")
}

#' @rdname get_data
#' @export
get_data.pdb_posterior <- function(x, ...) {
  get_data(x$data_name, pdb = pdb(x), ...)
}

#' @rdname get_data
#' @export
get_data.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  sdfp <- data_file_path(x, pdb = pdb)
  dat <- jsonlite::read_json(sdfp, simplifyVector = TRUE)
  class(dat) <- c("pdb_data", "list")
  info(dat) <- data_info(x, pdb)
  pdb(dat) <- pdb
  assert_data(dat)
  dat
}

#' @rdname get_data
#' @export
get_data.pdb_data_info <- function(x, pdb = pdb_default(), ...){
  get_data(x$name, pdb)
}

#' @rdname get_data
#' @export
get_data.list <- function(x, info, ...){
  checkmate::assert_class(info, "pdb_data_info")
  class(x) <- c("pdb_data", "list")
  info(x) <- info
  assert_data(x)
  x
}

#' @rdname get_data
#' @export
pdb_data <- get_data

#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
data_file_path <- function(x, ...) {
  UseMethod("data_file_path")
}

#' @inheritParams model_code_file_path
#' @export
data_file_path.pdb_posterior <- function(x, ...) {
  fp <- pdb_cached_local_file_path(pdb = pdb(x), path = x$data_info$data_file, unzip = TRUE)
  checkmate::assert_file_exists(fp)
  fp
}

#' @inheritParams model_code_file_path
#' @export
data_file_path.character <- function(x, pdb = pdb_default(), ...) {
  checkmate::assert_string(x)
  fn <- paste0(x, ".json")
  fp <- pdb_cached_local_file_path(pdb = pdb, path = file.path("data", "data", fn), unzip = TRUE)
  checkmate::assert_file_exists(fp)
  fp
}

#' @inheritParams model_code_file_path
#' @export
data_file_path.pdb_data_info <- function(x, pdb = pdb_default(), ...) {
  data_file_path(x$name, pdb = pdb, ...)
}

#' @rdname data_file_path
#' @export
stan_data_file_path <- function(x, ...) {
  data_file_path(x, ...)
}

#' @rdname data_file_path
#' @export
stan_data <- function(x) {
  get_data(x)
}

#' Assert the data format
#' @noRd
#' @keywords internal
assert_data <- function(x){
  checkmate::assert_list(x)
  checkmate::assert_class(x, "pdb_data")
  checkmate::assert_named(x, type = "unique")
  checkmate::assert_class(info(x), "pdb_data_info")
}

#' @export
print.pdb_data <- function(x, ...) {
  attr(x, "info") <- NULL
  x <- unclass(x)
  NextMethod("print")
}
