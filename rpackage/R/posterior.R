#' Access a posterior in the posterior database
#'
#' @param name a posterior name that exist in the posterior database
#' @param pdb a \code{pdb} posterior database object.
#' @export
posterior <- function(name, pdb = pdb_default()) {
  checkmate::assert_string(name)
  checkmate::assert_class(pdb, "pdb")
  po <- read_info_json(name, "posteriors", pdb)
  po$pdb <- pdb
  class(po) <- "pdb_posterior"
  po$model_info <- read_model_info(po)
  po$data_info <- read_data_info(po)
  assert_pdb_posterior(po)
  po
}
#' @rdname posterior
#' @export
pdb_posterior <- posterior

#' @export
print.pdb_posterior <- function(x, ...) {
  cat0("Posterior\n\n")
  print(x$data_info)
  cat0("\n")
  print(x$model_info)
  invisible(x)
}

assert_pdb_posterior <- function(x) {
  checkmate::assert_class(x, "pdb_posterior")
  checkmate::assert_list(x)
  must.include <- c(
    "name", "model_name", "data_name", "gold_standard_name", "dimensions",
    "model_info", "data_info",
    "pdb", "added_by", "added_date"
  )
  checkmate::assert_names(names(x), must.include = must.include)
  checkmate::assert_list(x$dimensions)
  checkmate::assert_named(x$dimensions)
  checkmate::assert_class(x$added_date, "Date")
  checkmate::assert_class(x$data_info$added_date, "Date")
  checkmate::assert_class(x$model_info$added_date, "Date")
  checkmate::assert_list(x$model_info, min.len = 1)
  invisible(x)
}
