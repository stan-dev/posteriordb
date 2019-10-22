#' Gold standard posterior draws
#'
#' @param x a \code{posterior} object to access the gold standard for.
#' @param ... Currently not used.
#'
#' @export
gold_standard <- function(x, ...) {
  UseMethod("gold_standard")
}

#' @rdname gold_standard
#' @export
gold_standard.pdb_posterior <- function(x, ...) {
  posterior_fit(gold_standard_file_path(x))
}

#' Extract data for posterior
#'
#' @inheritParams model_code_file_path
#' @export
gold_standard_file_path <- function(x, tempdir = TRUE) {
  checkmate::assert_class(x, "pdb_posterior")
  ffp <- file.path(x$pdb$path, paste0(x$gold_standard, ".zip"))
  if (!checkmate::test_file_exists(ffp)) {
    stop2("There is currently no gold standard for this posterior.")
  }
  tfp <- gold_standard_temp_file_path(x)
  copy_and_unzip(from = ffp, to = tfp)
  tfp
}

gold_standard_temp_dir <- function() {
  file.path(tempdir(), "posteriors", "gold_standards")
}

gold_standard_file_name <- function(x) {
  basename(x$gold_standard)
}

gold_standard_temp_file_path <- function(x) {
  file.path(gold_standard_temp_dir(), gold_standard_file_name(x))
}
