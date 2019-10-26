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
gold_standard_file_path <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  if(is.null(x$gold_standard)) stop2("There is currently no gold standard for this posterior.")
  gsfp <- pdb_cached_local_file_path(x$pdb, x$gold_standard, unzip = TRUE)
  gsfp
}

gold_standard_file_name <- function(x) {
  basename(x$gold_standard)
}
