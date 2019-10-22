#' Posterior Data Sets
#'
#' @param x a \code{posterior} object to access data from.
#' @param ... Currently not used.
#'
#' @export
get_data <- function(x, ...) {
  UseMethod("get_data")
}

#' @rdname get_data
#' @export
get_data.pdb_posterior <- function(x, ...) {
  sdfp <- data_file_path(x)
  dat <- jsonlite::read_json(sdfp, simplifyVector = TRUE)
  dat
}

#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
data_file_path <- function(x, tempdir = TRUE) {
  checkmate::assert_class(x, "pdb_posterior")
  ffp <- file.path(x$pdb$path, paste0(x$data_info$data_file, ".zip"))
  checkmate::assert_file_exists(ffp)
  tfp <- data_temp_file_path(x)
  copy_and_unzip(ffp, tfp)
  tfp
}

data_temp_dir <- function() {
  file.path(tempdir(), "posteriors", "data")
}

data_file_name <- function(x) {
  basename(x$data_info$data_file)
}

data_temp_file_path <- function(x) {
  file.path(data_temp_dir(), data_file_name(x))
}

#' @rdname data_file_path
#' @export
stan_data_file_path <- function(x) {
  data_file_path(x)
}

#' @rdname data_file_path
#' @export
stan_data <- function(x) {
  get_data(x)
}

#' @rdname data_file_path
#' @export
stan_data <- function(x) {
  get_data(x)
}
